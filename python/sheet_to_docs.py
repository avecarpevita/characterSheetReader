import os.path
from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError

# If modifying these scopes, delete the file token.json.
SCOPES = [
    'https://www.googleapis.com/auth/spreadsheets.readonly',
    'https://www.googleapis.com/auth/documents',
    'https://www.googleapis.com/auth/drive'
]

# User Provided Constants
SPREADSHEET_ID = '19VZwF2njHWbxIYWbOCLYxl2Ce1gGERW1snRIsjHhZpI'
DESTINATION_FOLDER_ID = '1HzcPlJe6ymNqzL5ldMO4XU7PEepjYTwk'

def get_services():
    """Authenticates and returns the Sheets, Docs, and Drive services using User Credentials."""
    creds = None
    # The file token.json stores the user's access and refresh tokens, and is
    # created automatically when the authorization flow completes for the first time.
    if os.path.exists('token.json'):
        creds = Credentials.from_authorized_user_file('token.json', SCOPES)
        
    # If there are no (valid) credentials available, let the user log in.
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            if not os.path.exists('credentials.json'):
                raise FileNotFoundError("Missing credentials.json. Please download the OAuth 2.0 Client ID JSON and rename it to credentials.json.")
            flow = InstalledAppFlow.from_client_secrets_file('credentials.json', SCOPES)
            creds = flow.run_local_server(port=0)
            
        # Save the credentials for the next run
        with open('token.json', 'w') as token:
            token.write(creds.to_json())

    try:
        sheets_service = build('sheets', 'v4', credentials=creds)
        docs_service = build('docs', 'v1', credentials=creds)
        drive_service = build('drive', 'v3', credentials=creds)
        return sheets_service, docs_service, drive_service
    except HttpError as err:
        print(err)
        return None, None, None

def get_sheet_data(sheets_service, spreadsheet_id):
    """Retrieves all data from the first tab of the spreadsheet."""
    # First get the spreadsheet to find the name of the first sheet
    sheet_metadata = sheets_service.spreadsheets().get(spreadsheetId=spreadsheet_id).execute()
    sheets = sheet_metadata.get('sheets', '')
    first_sheet_name = sheets[0].get("properties", {}).get("title", "Sheet1")
    
    # Read the data from the first sheet
    result = sheets_service.spreadsheets().values().get(
        spreadsheetId=spreadsheet_id, range=first_sheet_name).execute()
    values = result.get('values', [])
    return values

def create_doc_and_move(docs_service, drive_service, title, folder_id):
    """Creates a Google Doc directly in the specified folder using the Drive API."""
    file_metadata = {
        'name': title,
        'mimeType': 'application/vnd.google-apps.document',
        'parents': [folder_id]
    }
    
    file = drive_service.files().create(
        body=file_metadata,
        fields='id'
    ).execute()
    
    return file.get('id')

def insert_table_into_doc(docs_service, document_id, doc_title, headers, row):
    """Inserts a 2-column table into the Google Doc and populates it with headers and row data."""
    # 1. Insert Title and Table Structure
    title_text = f"{doc_title}\n"
    requests_1 = [
        {
            'insertText': {
                'location': {'index': 1},
                'text': title_text
            }
        },
        {
            'insertTable': {
                'rows': len(headers),
                'columns': 2,
                # The table is inserted right after the title_text
                'location': {'index': 1 + len(title_text)}
            }
        }
    ]
    docs_service.documents().batchUpdate(documentId=document_id, body={'requests': requests_1}).execute()
    
    # 2. Get the newly updated document structure to find the table cell indices
    doc = docs_service.documents().get(documentId=document_id).execute()
    content = doc.get('body').get('content')
    
    table_element = None
    for element in content:
        if 'table' in element:
            table_element = element['table']
            break
            
    if not table_element:
        print("Failed to find table in document.")
        return
        
    # 3. Build insertText requests for each cell
    requests_2 = []
    
    # We iterate backwards through the rows and cells so that inserting text doesn't 
    # shift the indices of the cells we haven't written to yet!
    for r_idx in range(len(headers) - 1, -1, -1):
        header_name = str(headers[r_idx]) if r_idx < len(headers) else ""
        cell_value = str(row[r_idx]) if r_idx < len(row) else ""
        
        # Get cell start indices
        table_row = table_element['tableRows'][r_idx]
        
        # Column 1 (Value)
        col1_cell = table_row['tableCells'][1]
        if cell_value:
            requests_2.append({
                'insertText': {
                    'location': {'index': col1_cell['startIndex'] + 1},
                    'text': cell_value
                }
            })
        
        # Column 0 (Header)
        col0_cell = table_row['tableCells'][0]
        if header_name:
            requests_2.append({
                'insertText': {
                    'location': {'index': col0_cell['startIndex'] + 1},
                    'text': header_name
                }
            })
            requests_2.append({
                'updateTextStyle': {
                    'range': {
                        'startIndex': col0_cell['startIndex'] + 1,
                        'endIndex': col0_cell['startIndex'] + 1 + len(header_name)
                    },
                    'textStyle': {'bold': True},
                    'fields': 'bold'
                }
            })
            
    if requests_2:
        docs_service.documents().batchUpdate(documentId=document_id, body={'requests': requests_2}).execute()

def main():
    try:
        sheets_service, docs_service, drive_service = get_services()
        
        print(f"Reading data from Spreadsheet ID: {SPREADSHEET_ID}...")
        values = get_sheet_data(sheets_service, SPREADSHEET_ID)
        
        if not values:
            print('No data found in the spreadsheet.')
            return
            
        headers = values[0]
        rows = values[1:]
        
        # Find the column indices for 'action' and 'characterName'
        try:
            # We lowercase the headers for easier matching, in case of capitalization differences
            lower_headers = [str(h).lower().strip() for h in headers]
            
            # Find the indices (fallback to -1 if not found to avoid crashing, but warn)
            action_idx = lower_headers.index('action') if 'action' in lower_headers else -1
            char_name_idx = lower_headers.index('charactername') if 'charactername' in lower_headers else -1
            ticket_num_idx = lower_headers.index('ticketnum') if 'ticketnum' in lower_headers else -1
            
            if action_idx == -1 or char_name_idx == -1:
                print("Warning: Could not find 'action' or 'characterName' columns exactly.")
                print(f"Available headers: {headers}")
                print("Will fallback to using available columns for naming...")
        except ValueError:
            pass

        print(f"Found {len(rows)} rows to process.")
        
        for i, row in enumerate(rows):
            # 1. Determine Title
            action_val = row[action_idx] if action_idx != -1 and action_idx < len(row) else f"Row{i+1}"
            char_val = row[char_name_idx] if char_name_idx != -1 and char_name_idx < len(row) else "Unknown"
            ticket_val = row[ticket_num_idx] if ticket_num_idx != -1 and ticket_num_idx < len(row) else ""
            ticket_val = f"ticket# {ticket_val}"
            
            doc_title_parts = [p for p in [action_val, char_val, ticket_val] if p]
            doc_title = " -- ".join(doc_title_parts).strip()
            
            if not doc_title:
                doc_title = f"Document Row {i+2}"
                
            print(f"[{i+1}/{len(rows)}] Creating document: '{doc_title}'...")
            
            # 2. Create Document, move it, and insert the formatted table
            doc_id = create_doc_and_move(docs_service, drive_service, doc_title, DESTINATION_FOLDER_ID)
            insert_table_into_doc(docs_service, doc_id, doc_title, headers, row)
            
        print("Success! All documents have been created.")

    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == '__main__':
    main()
