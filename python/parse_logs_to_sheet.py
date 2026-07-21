import os
import io
import json
import datetime
import time
from dotenv import load_dotenv
from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
from googleapiclient.http import MediaIoBaseDownload
import google.generativeai as genai
import PIL.Image

# Load environment variables
load_dotenv()
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
MAX_IMAGES_TO_PROCESS = os.getenv("MAX_IMAGES_TO_PROCESS")

if not GEMINI_API_KEY:
    print("WARNING: GEMINI_API_KEY not found in .env file. Please add it.")
    exit(1)

genai.configure(api_key=GEMINI_API_KEY)

# Scopes needed for Drive read/write and Sheets write/create
SCOPES = [
    'https://www.googleapis.com/auth/spreadsheets',
    'https://www.googleapis.com/auth/drive'
]

#this is the folder for raw scans
FOLDER_ID = '1egtJj6maZVFxhI0WZW76eXKf3OBtooK7'

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
                raise FileNotFoundError("Missing credentials.json.")
            flow = InstalledAppFlow.from_client_secrets_file('credentials.json', SCOPES)
            creds = flow.run_local_server(port=0)
        with open('token_rw.json', 'w') as token:
            token.write(creds.to_json())
            
    drive_service = build('drive', 'v3', credentials=creds)
    sheets_service = build('sheets', 'v4', credentials=creds)
    return drive_service, sheets_service

def download_file(drive_service, file_id, file_name):
    """Downloads a file from Google Drive temporarily to c:\temp."""
    request = drive_service.files().get_media(fileId=file_id)
    fh = io.BytesIO()
    downloader = MediaIoBaseDownload(fh, request)
    done = False
    while done is False:
        status, done = downloader.next_chunk()
    fh.seek(0)
    
    # Ensure c:\temp exists
    temp_dir = r'c:\temp'
    os.makedirs(temp_dir, exist_ok=True)
    local_path = os.path.join(temp_dir, file_name)
    
    with open(local_path, 'wb') as f:
        f.write(fh.read())
    return local_path

def process_image_with_gemini(image_path):
    """Uses Gemini API to extract log fields into a structured JSON."""
    model = genai.GenerativeModel('gemini-3.5-flash')
    
    prompt = """
    Analyze this handwritten form and extract the requested fields. 
    Return the response as a valid JSON object. Do not include markdown formatting like ```json in the output, just the raw JSON object.
    
    First, determine the type of the form. It will be either an "Influence Spends Log" or a "Research Log".
    If it is neither, set form_type to "Unknown".
    If a field is empty or unreadable, set its value to an empty string "".

    The JSON schema must strictly follow this structure:
    {
      "form_type": "Research Log" | "Influence Spends Log" | "Unknown",
      "research_log": {
        "lead_researcher_player_name": "",
        "lead_researcher_character_name": "",
        "assistants": ["", ""],
        "lores_applied": ["", ""],
        "story_staff": "",
        "research_question_notes": ""
      },
      "influence_spends_log": [
        {
          "player_name": "",
          "character_name": "",
          "action": "",
          "details": "",
          "story_staff": ""
        }
      ]
    }

    Notes:
    - For "Research Log", "assistants" and "lores_applied" should be arrays of strings. Try to capture all listed items. Lead Researcher Character Name is typically to the right of Player Name.
    - The top box "Research question, Notes, and Additional Information here" goes into "research_question_notes".
    - For "Influence Spends Log", there may be 0 to 4 possible entries. Extract each filled-out entry as an object in the array. 
    - "Action" is from the box titled "Action (Influence Type: Action)".
    - "Details" is the large box with Details in the top left corner.
    - "Story Staff" is the box with "Story Staff:" in the left of the box.
    """
    
    img = PIL.Image.open(image_path)
    
    max_retries = 5
    backoff_time = 16
    for attempt in range(max_retries):
        try:
            response = model.generate_content([prompt, img])
            text = response.text.strip()
            if text.startswith("```json"):
                text = text[7:]
            if text.endswith("```"):
                text = text[:-3]
            text = text.strip()
            data = json.loads(text)
            return data
        except Exception as e:
            error_str = str(e)
            if "429" in error_str:
                print(f"Rate limit hit (429) for {image_path}. Retrying in {backoff_time} seconds... (Attempt {attempt + 1} of {max_retries})")
                time.sleep(backoff_time)
                backoff_time *= 2
            else:
                print(f"Error parsing Gemini response for {image_path}: {e}")
                return None
                
    print(f"Failed to process {image_path} after {max_retries} attempts.")
    return None

def create_and_setup_spreadsheet(drive_service, sheets_service, folder_id):
    """Creates a new spreadsheet in the specified folder, formats tabs, and returns spreadsheetId."""
    # Create new spreadsheet
    date_str = datetime.datetime.now().strftime("%Y-%m-%d %H:%M")
    spreadsheet = {
        'properties': {'title': f'Parsed Logs {date_str}'}
    }
    spreadsheet = sheets_service.spreadsheets().create(body=spreadsheet, fields='spreadsheetId').execute()
    sheet_id = spreadsheet.get('spreadsheetId')
    
    # Move spreadsheet to the specific folder
    try:
        file = drive_service.files().get(fileId=sheet_id, fields='parents').execute()
        previous_parents = ",".join(file.get('parents', []))
        drive_service.files().update(
            fileId=sheet_id,
            addParents=folder_id,
            removeParents=previous_parents,
            fields='id, parents'
        ).execute()
    except Exception as e:
        print(f"Warning: Could not move spreadsheet to folder: {e}")
    
    # Batch update to set up sheets and headers
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
        spreadsheetId=sheet_id,
        body={'requests': requests}
    ).execute()
    
    # Get the ID of the newly added sheet to format its header
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
            
    sheets_service.spreadsheets().batchUpdate(
        spreadsheetId=sheet_id,
        body={'requests': format_requests}
    ).execute()
    
    return sheet_id

def append_rows(sheets_service, sheet_id, range_name, values):
    """Appends rows to the specified range."""
    if not values:
        return
    body = {'values': values}
    sheets_service.spreadsheets().values().append(
        spreadsheetId=sheet_id,
        range=range_name,
        valueInputOption='USER_ENTERED',
        body=body
    ).execute()

def main():
    print("Authenticating with Google Drive and Sheets APIs...")
    # Note: this might pop up a browser for auth since scopes changed
    try:
        drive_service, sheets_service = get_google_services()
    except Exception as e:
        print(f"Authentication failed: {e}")
        return
        
    print(f"Searching for images in folder ID: {FOLDER_ID}...")
    # Search for common image formats
    query = f"'{FOLDER_ID}' in parents and (mimeType='image/jpeg' or mimeType='image/png' or mimeType='image/heic') and trashed=false"
    
    try:
        items = []
        page_token = None
        while True:
            results = drive_service.files().list(
                q=query,
                fields="nextPageToken, files(id, name)",
                pageSize=1000,
                pageToken=page_token
            ).execute()
            items.extend(results.get('files', []))
            page_token = results.get('nextPageToken')
            if not page_token:
                break
    except Exception as e:
        print(f"Failed to query Google Drive: {e}")
        return
        
    if MAX_IMAGES_TO_PROCESS and MAX_IMAGES_TO_PROCESS.isdigit():
        limit = int(MAX_IMAGES_TO_PROCESS)
        items = items[:limit]
        print(f"Limiting to {limit} images based on MAX_IMAGES_TO_PROCESS environment variable.")
        
    if not items:
        print('No image files found in the specified folder.')
        return
        
    print(f"Found {len(items)} files. Starting processing...")
    
    research_rows = []
    influence_rows = []
    
    # Headers
    research_rows.append([
        "Image Filename",
        "Lead Researcher Player Name", 
        "Lead Researcher Character Name", 
        "Assistants", 
        "Lores Applied", 
        "Story Staff Involved", 
        "Research Question/Notes"
    ])
    
    influence_rows.append([
        "Image Filename",
        "Player Name", 
        "Character Name", 
        "Action", 
        "Details", 
        "Story Staff"
    ])
    
    for i, item in enumerate(items):
        file_id = item['id']
        file_name = item['name']
        print(f"[{i+1}/{len(items)}] Processing {file_name}...")
        
        # Download temporarily
        local_path = download_file(drive_service, file_id, file_name)
        
        # Parse with Gemini
        data = process_image_with_gemini(local_path)
        
        if data:
            form_type = data.get("form_type")
            if form_type == "Research Log":
                rl = data.get("research_log", {})
                
                assistants = ", ".join(rl.get("assistants", [])) if isinstance(rl.get("assistants"), list) else rl.get("assistants", "")
                lores = ", ".join(rl.get("lores_applied", [])) if isinstance(rl.get("lores_applied"), list) else rl.get("lores_applied", "")
                
                research_rows.append([
                    file_name,
                    rl.get("lead_researcher_player_name", ""),
                    rl.get("lead_researcher_character_name", ""),
                    assistants,
                    lores,
                    rl.get("story_staff", ""),
                    rl.get("research_question_notes", "")
                ])
                print(" -> Identified as Research Log.")
                print(f"    Player: {rl.get('lead_researcher_player_name', '')} | Character: {rl.get('lead_researcher_character_name', '')}")
                print(f"    Assistants: {assistants}")
                print(f"    Lores: {lores}")
                
            elif form_type == "Influence Spends Log":
                il_list = data.get("influence_spends_log", [])
                print(f" -> Identified as Influence Spends Log with {len(il_list)} entries.")
                for entry in il_list:
                    print(f"    Player: {entry.get('player_name', '')} | Character: {entry.get('character_name', '')} | Action: {entry.get('action', '')}")
                    influence_rows.append([
                        file_name,
                        entry.get("player_name", ""),
                        entry.get("character_name", ""),
                        entry.get("action", ""),
                        entry.get("details", ""),
                        entry.get("story_staff", "")
                    ])
            else:
                print(f" -> Form type unknown for {file_name}.")
                
        # Clean up temporary file
        if os.path.exists(local_path):
            os.remove(local_path)
            
        # Avoid hitting API rate limits too quickly
        time.sleep(5)
        
    # Write to Sheets
    if len(research_rows) > 1 or len(influence_rows) > 1:
        print("Creating Google Spreadsheet...")
        sheet_id = create_and_setup_spreadsheet(drive_service, sheets_service, FOLDER_ID)
        
        print(f"Successfully created spreadsheet: https://docs.google.com/spreadsheets/d/{sheet_id}")
        
        if len(research_rows) > 1:
            print("Writing Research Logs to Sheet...")
            append_rows(sheets_service, sheet_id, "Research Logs!A1", research_rows)
            
        if len(influence_rows) > 1:
            print("Writing Influence Spends Logs to Sheet...")
            append_rows(sheets_service, sheet_id, "Influence Spends Logs!A1", influence_rows)
            
        print("Done!")
    else:
        print("No valid data was extracted. Spreadsheet was not created.")

if __name__ == '__main__':
    main()
