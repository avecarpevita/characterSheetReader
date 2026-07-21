import os
import datetime
import pyodbc
from dotenv import load_dotenv
from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
from thefuzz import process

# ---------------------------------------------------------
# Configuration
# ---------------------------------------------------------
INPUT_SPREADSHEET_ID = '1P7n54bfJ1h_5yFuRb4GFXdQS9rDkaH_oz5cydNfdYbo'  # REPLACE THIS WITH THE ID FROM STEP 1
MATCH_THRESHOLD = 60

# Scopes needed for Drive read/write and Sheets read/write
SCOPES = [
    'https://www.googleapis.com/auth/spreadsheets',
    'https://www.googleapis.com/auth/drive'
]

def get_google_services():
    """Authenticates and returns Drive and Sheets services."""
    creds = None
    if os.path.exists('token_rw.json'):
        creds = Credentials.from_authorized_user_file('token_rw.json', SCOPES)
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            if not os.path.exists('credentials.json'):
                raise FileNotFoundError("Missing credentials.json. Please run step 1 or ensure credentials are present.")
            flow = InstalledAppFlow.from_client_secrets_file('credentials.json', SCOPES)
            creds = flow.run_local_server(port=0)
        with open('token_rw.json', 'w') as token:
            token.write(creds.to_json())
            
    drive_service = build('drive', 'v3', credentials=creds)
    sheets_service = build('sheets', 'v4', credentials=creds)
    return drive_service, sheets_service

def fetch_db_characters():
    """Fetches characters from the database and returns a mapping for fuzzy matching."""
    load_dotenv()
    server = os.getenv('server')
    database = os.getenv('database')
    
    if not server or not database:
        raise ValueError("Missing 'server' or 'database' in .env file.")
        
    conn_str = (
        "DRIVER={ODBC Driver 17 for SQL Server};"
        f"SERVER={server};"
        f"DATABASE={database};"
        "Trusted_Connection=yes;"
    )
    
    cnxn = pyodbc.connect(conn_str)
    cursor = cnxn.cursor()
    cursor.execute("SELECT characterName, playerName, characterid FROM tm.dbo.rawCPData")
    
    db_data = {}
    for row in cursor.fetchall():
        char_name = str(row.characterName).strip() if row.characterName else ""
        player_name = str(row.playerName).strip() if row.playerName else ""
        char_id = row.characterid
        
        search_key = f"{player_name} - {char_name}".strip()
        if search_key == "-":
            continue
            
        db_data[search_key] = char_id
        
    cursor.close()
    cnxn.close()
    
    return db_data

def process_sheet_data(rows, db_data, file_links):
    """Processes sheet data, maps image URLs, and performs fuzzy matching."""
    if not rows:
        return []
        
    processed = []
    
    # Process header
    header = rows[0]
    header.extend(["characterId", "best playerName - characterName match"])
    processed.append(header)
    
    for row in rows[1:]:
        # Ensure row has enough columns (Google sheets might truncate trailing empty cols)
        # Pad row to match expected length up to the original headers
        while len(row) < len(header) - 2:
            row.append("")
            
        # Extract fields
        filename = row[0]
        player_name = row[1]
        char_name = row[2]
        
        # Hyperlink the filename
        if filename in file_links:
            url = file_links[filename]
            row[0] = f'=HYPERLINK("{url}", "{filename}")'
            
        # Fuzzy match
        search_str = f"{player_name} - {char_name}".strip()
        best_match = None
        best_score = 0
        char_id = ""
        
        if search_str and search_str != "-":
            # ExtractOne returns a tuple: (matched_string, score)
            match_result = process.extractOne(search_str, db_data.keys())
            if match_result:
                best_match, best_score = match_result
                
        if best_score > MATCH_THRESHOLD:
            char_id = db_data[best_match]
        else:
            best_match = ""
            char_id = ""
            
        row.append(str(char_id))
        row.append(best_match)
        
        processed.append(row)
        
    return processed

def main():
    if INPUT_SPREADSHEET_ID == 'your-input-spreadsheet-id-here':
        print("ERROR: Please update INPUT_SPREADSHEET_ID in the script before running.")
        return
        
    print("Connecting to SQL Server...")
    db_data = fetch_db_characters()
    print(f"Loaded {len(db_data)} character records from DB.")
    
    print("Authenticating with Google APIs...")
    drive_service, sheets_service = get_google_services()
    
    print(f"Fetching input spreadsheet: {INPUT_SPREADSHEET_ID}...")
    spreadsheet = sheets_service.spreadsheets().get(spreadsheetId=INPUT_SPREADSHEET_ID).execute()
    original_title = spreadsheet.get('properties', {}).get('title', 'Parsed Logs')
    
    # Get parent folder of the input spreadsheet
    file_meta = drive_service.files().get(fileId=INPUT_SPREADSHEET_ID, fields='parents').execute()
    parents = file_meta.get('parents', [])
    if not parents:
        print("Could not find parent folder for the input spreadsheet.")
        return
        
    parent_folder_id = parents[0]
    
    # Get all files in parent folder to map filenames to links
    print(f"Mapping image links from folder ID: {parent_folder_id}...")
    file_links = {}
    page_token = None
    query = f"'{parent_folder_id}' in parents and trashed=false"
    while True:
        results = drive_service.files().list(
            q=query,
            fields="nextPageToken, files(name, webViewLink)",
            pageSize=1000,
            pageToken=page_token
        ).execute()
        
        for f in results.get('files', []):
            file_links[f.get('name')] = f.get('webViewLink')
            
        page_token = results.get('nextPageToken')
        if not page_token:
            break
            
    print(f"Found {len(file_links)} files in the folder.")
    
    # Fetch sheet data
    print("Reading data from input spreadsheet...")
    
    try:
        research_result = sheets_service.spreadsheets().values().get(
            spreadsheetId=INPUT_SPREADSHEET_ID, range="Research Logs!A:Z").execute()
        research_rows = research_result.get('values', [])
    except Exception:
        research_rows = []
        
    try:
        influence_result = sheets_service.spreadsheets().values().get(
            spreadsheetId=INPUT_SPREADSHEET_ID, range="Influence Spends Logs!A:Z").execute()
        influence_rows = influence_result.get('values', [])
    except Exception:
        influence_rows = []
        
    # Process Data
    print("Processing Research Logs...")
    processed_research = process_sheet_data(research_rows, db_data, file_links)
    
    print("Processing Influence Spends Logs...")
    processed_influence = process_sheet_data(influence_rows, db_data, file_links)
    
    # Create Output Spreadsheet
    new_title = f"v2 {original_title}"
    print(f"Creating new spreadsheet '{new_title}'...")
    
    new_spreadsheet = {
        'properties': {'title': new_title}
    }
    created_ss = sheets_service.spreadsheets().create(body=new_spreadsheet, fields='spreadsheetId').execute()
    new_sheet_id = created_ss.get('spreadsheetId')
    
    # Move new sheet to the same folder
    try:
        ss_meta = drive_service.files().get(fileId=new_sheet_id, fields='parents').execute()
        prev_parents = ",".join(ss_meta.get('parents', []))
        drive_service.files().update(
            fileId=new_sheet_id,
            addParents=parent_folder_id,
            removeParents=prev_parents,
            fields='id, parents'
        ).execute()
    except Exception as e:
        print(f"Warning: Could not move new spreadsheet to folder: {e}")
        
    # Batch update to create tabs and format headers
    requests = []
    
    # 1. Rename Sheet1 to "Research Logs"
    requests.append({
        'updateSheetProperties': {
            'properties': {
                'sheetId': 0,
                'title': 'Research Logs',
                'gridProperties': {'frozenRowCount': 1}
            },
            'fields': 'title,gridProperties.frozenRowCount'
        }
    })
    
    # 2. Add "Influence Spends Logs" sheet
    requests.append({
        'addSheet': {
            'properties': {
                'title': 'Influence Spends Logs',
                'gridProperties': {'frozenRowCount': 1}
            }
        }
    })
    
    response = sheets_service.spreadsheets().batchUpdate(
        spreadsheetId=new_sheet_id,
        body={'requests': requests}
    ).execute()
    
    influence_sheet_id = None
    for reply in response.get('replies', []):
        if 'addSheet' in reply:
            influence_sheet_id = reply['addSheet']['properties']['sheetId']
            
    # Format Headers (Bold)
    format_requests = []
    for s_id in [0, influence_sheet_id]:
        if s_id is not None:
            format_requests.append({
                'repeatCell': {
                    'range': {
                        'sheetId': s_id,
                        'startRowIndex': 0,
                        'endRowIndex': 1
                    },
                    'cell': {
                        'userEnteredFormat': {
                            'textFormat': {'bold': True}
                        }
                    },
                    'fields': 'userEnteredFormat.textFormat.bold'
                }
            })
            
    if format_requests:
        sheets_service.spreadsheets().batchUpdate(
            spreadsheetId=new_sheet_id,
            body={'requests': format_requests}
        ).execute()
        
    # Write data back to new sheet
    if processed_research:
        print("Writing Research Logs...")
        sheets_service.spreadsheets().values().update(
            spreadsheetId=new_sheet_id,
            range="Research Logs!A1",
            valueInputOption='USER_ENTERED',
            body={'values': processed_research}
        ).execute()
        
    if processed_influence:
        print("Writing Influence Spends Logs...")
        sheets_service.spreadsheets().values().update(
            spreadsheetId=new_sheet_id,
            range="Influence Spends Logs!A1",
            valueInputOption='USER_ENTERED',
            body={'values': processed_influence}
        ).execute()
        
    print(f"Successfully created v2 spreadsheet: https://docs.google.com/spreadsheets/d/{new_sheet_id}")

if __name__ == '__main__':
    main()
