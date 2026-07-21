import os
import re
import time
from dotenv import load_dotenv
from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build

# ---------------------------------------------------------
# Configuration
# ---------------------------------------------------------
INPUT_SHEET_ID = '1rRqLTACdCv7mGYP6rrZS2kWxrDkJj0jX6FNvyUdS8JI'   # REPLACE WITH STEP 2 SHEET ID
OUTPUT_FOLDER_ID = '14bRyZftDXsUoXP41OIIRcJRnUZfoCzAk'       # REPLACE WITH THE ID OF THE FOLDER FOR DOCS
STAFF_NAME_FILTER = 'scott'                                  # FILTER ROWS BY THIS NAME IN STAFF (CLEAN) COLUMN

# Scopes needed for Drive (read/write), Sheets (read), and Docs (write)
SCOPES = [
    'https://www.googleapis.com/auth/spreadsheets.readonly',
    'https://www.googleapis.com/auth/drive',
    'https://www.googleapis.com/auth/documents'
]

def get_google_services():
    """Authenticates and returns Drive, Sheets, and Docs services."""
    creds = None
    if os.path.exists('token_rw.json'):
        creds = Credentials.from_authorized_user_file('token_rw.json', SCOPES)
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            if not os.path.exists('credentials.json'):
                raise FileNotFoundError("Missing credentials.json. Please ensure credentials are present.")
            flow = InstalledAppFlow.from_client_secrets_file('credentials.json', SCOPES)
            creds = flow.run_local_server(port=0)
        with open('token_rw.json', 'w') as token:
            token.write(creds.to_json())
            
    drive_service = build('drive', 'v3', credentials=creds)
    sheets_service = build('sheets', 'v4', credentials=creds)
    docs_service = build('docs', 'v1', credentials=creds)
    return drive_service, sheets_service, docs_service

def execute_with_retry(request):
    """Executes a Google API request with exponential backoff for rate limits."""
    max_retries = 6
    backoff = 2
    for attempt in range(max_retries):
        try:
            return request.execute()
        except Exception as e:
            err_str = str(e).lower()
            if 'rate_limit_exceeded' in err_str or '429' in err_str or 'quota' in err_str or 'too many requests' in err_str:
                print(f"Rate limit hit. Waiting {backoff} seconds before retry (Attempt {attempt + 1}/{max_retries})...")
                time.sleep(backoff)
                backoff *= 2
            else:
                raise e
    print("Failed after maximum retries due to rate limiting.")
    raise Exception("Rate limit exceeded maximum retries.")

def extract_url_from_formula(formula):
    """Extracts the URL from a =HYPERLINK("url", "text") formula."""
    if not formula:
        return None
    match = re.search(r'=HYPERLINK\("([^"]+)"', formula, re.IGNORECASE)
    if match:
        return match.group(1)
    return None

def extract_file_id_from_url(url):
    """Extracts the Google Drive file ID from a standard Drive URL."""
    if not url:
        return None
    # match /file/d/ID/view
    match = re.search(r'/file/d/([a-zA-Z0-9_-]+)/', url)
    if match:
        return match.group(1)
    # match ?id=ID
    match = re.search(r'[?&]id=([a-zA-Z0-9_-]+)', url)
    if match:
        return match.group(1)
    return None

def create_google_doc(docs_service, drive_service, title, output_folder_id):
    """Creates a new Google Doc and moves it to the target folder."""
    body = {'title': title}
    doc = execute_with_retry(docs_service.documents().create(body=body))
    doc_id = doc.get('documentId')
    
    # Move the doc
    try:
        file_meta = execute_with_retry(drive_service.files().get(fileId=doc_id, fields='parents'))
        prev_parents = ",".join(file_meta.get('parents', []))
        execute_with_retry(drive_service.files().update(
            fileId=doc_id,
            addParents=output_folder_id,
            removeParents=prev_parents,
            fields='id, parents'
        ))
    except Exception as e:
        print(f"Warning: Could not move doc '{title}' to folder: {e}")
        
    return doc_id

def make_file_public(drive_service, file_id):
    """Temporarily makes a file public so Google Docs API can fetch the image."""
    try:
        permission = {'type': 'anyone', 'role': 'reader'}
        res = execute_with_retry(drive_service.permissions().create(
            fileId=file_id,
            body=permission,
            fields='id'
        ))
        return res.get('id')
    except Exception as e:
        print(f"Warning: Failed to make file public for embedding: {e}")
        return None

def remove_permission(drive_service, file_id, permission_id):
    """Removes the temporary public permission."""
    try:
        execute_with_retry(drive_service.permissions().delete(
            fileId=file_id,
            permissionId=permission_id
        ))
    except Exception as e:
        print(f"Warning: Failed to remove temporary permission: {e}")

def populate_doc(docs_service, drive_service, doc_id, headers, row_data, image_url, file_id=None):
    """Populates the doc with an image and a pivoted table of row data."""
    image_inserted = False
    
    # 1. Try to insert Image at the top
    if file_id:
        print(f"    Temporarily making image {file_id} public to embed...")
        permission_id = make_file_public(drive_service, file_id)
        if permission_id:
            time.sleep(2) # Wait for permission to propagate
            public_image_uri = f"https://drive.google.com/uc?id={file_id}"
            image_requests = [
                {
                    'insertInlineImage': {
                        'location': {'index': 1},
                        'uri': public_image_uri,
                        'objectSize': {'width': {'magnitude': 400, 'unit': 'PT'}}
                    }
                },
                {
                    'insertText': {
                        'location': {'index': 1},
                        'text': "\n\n"
                    }
                }
            ]
            try:
                execute_with_retry(docs_service.documents().batchUpdate(documentId=doc_id, body={'requests': image_requests}))
                image_inserted = True
                print("    Image embedded successfully.")
            except Exception as e:
                print(f"    Could not embed image: {e}")
            
            remove_permission(drive_service, file_id, permission_id)

    # 2. Get current end index
    doc = execute_with_retry(docs_service.documents().get(documentId=doc_id))
    content = doc.get('body').get('content')
    end_index = content[-1].get('endIndex') - 1
    
    if not image_inserted and image_url:
         # Fallback to link text
         reqs = [{'insertText': {'location': {'index': end_index}, 'text': f"Image Link: {image_url}\n\n"}}]
         execute_with_retry(docs_service.documents().batchUpdate(documentId=doc_id, body={'requests': reqs}))
         doc = execute_with_retry(docs_service.documents().get(documentId=doc_id))
         content = doc.get('body').get('content')
         end_index = content[-1].get('endIndex') - 1

    # 3. Insert Table
    num_rows = len(headers)
    if num_rows == 0:
        return
        
    table_requests = [
        {
            'insertTable': {
                'rows': num_rows,
                'columns': 2,
                'location': {'index': end_index}
            }
        }
    ]
    execute_with_retry(docs_service.documents().batchUpdate(documentId=doc_id, body={'requests': table_requests}))
    
    # 4. Fetch doc again to get table cell indices
    doc = execute_with_retry(docs_service.documents().get(documentId=doc_id))
    content = doc.get('body').get('content')
    
    table = None
    for element in reversed(content):
        if 'table' in element:
            table = element['table']
            break
            
    if table:
        text_requests = []
        for r_idx, table_row in enumerate(table.get('tableRows', [])):
            if r_idx >= num_rows:
                break
            cells = table_row.get('tableCells', [])
            if len(cells) >= 2:
                # Left column (Header)
                left_cell_start = cells[0]['startIndex'] + 1
                header_text = str(headers[r_idx])
                if header_text:
                    text_requests.append({
                        'insertText': {
                            'location': {'index': left_cell_start},
                            'text': header_text
                        }
                    })
                
                # Right column (Value)
                right_cell_start = cells[1]['startIndex'] + 1
                val_text = str(row_data[r_idx])
                if val_text:
                    text_requests.append({
                        'insertText': {
                            'location': {'index': right_cell_start},
                            'text': val_text
                        }
                    })
        
        # Sort requests in reverse index order so insertions don't offset subsequent indices
        text_requests.sort(key=lambda x: x['insertText']['location']['index'], reverse=True)
        if text_requests:
            execute_with_retry(docs_service.documents().batchUpdate(documentId=doc_id, body={'requests': text_requests}))

def process_tab(drive_service, sheets_service, docs_service, tab_name, name_template_func):
    print(f"Reading data from '{tab_name}'...")
    try:
        # Fetch with FORMULA to get the hyperlinks, but this makes all cells formulas if they are.
        # So we fetch twice: once for formulas, once for values.
        result_formulas = sheets_service.spreadsheets().values().get(
            spreadsheetId=INPUT_SHEET_ID, range=f"{tab_name}!A:Z", valueRenderOption='FORMULA').execute()
        result_values = sheets_service.spreadsheets().values().get(
            spreadsheetId=INPUT_SHEET_ID, range=f"{tab_name}!A:Z", valueRenderOption='FORMATTED_VALUE').execute()
            
        rows_formulas = result_formulas.get('values', [])
        rows_values = result_values.get('values', [])
    except Exception as e:
        print(f"Error reading {tab_name}: {e}")
        return
        
    if not rows_values or len(rows_values) < 2:
        print(f"No data found in '{tab_name}'.")
        return
        
    headers = rows_values[0]
    
    # Dynamically find column indices
    try:
        staff_col_idx = headers.index("Staff (Clean)")
    except ValueError:
        print(f"Error: Could not find 'Staff (Clean)' column in {tab_name}.")
        return

    # To be safe, we pad rows_values to match headers length
    for idx, row in enumerate(rows_values[1:]):
        # row index is idx + 1
        formula_row = rows_formulas[idx + 1] if idx + 1 < len(rows_formulas) else []
        
        # pad rows
        while len(row) < len(headers):
            row.append("")
        while len(formula_row) < len(headers):
            formula_row.append("")
            
        staff_value = str(row[staff_col_idx]).strip()
        
        # Filter for rows containing the staff name filter
        if STAFF_NAME_FILTER.lower() in staff_value.lower():
            # Determine doc title
            doc_title = name_template_func(headers, row)
            if not doc_title:
                doc_title = f"(WIP) {tab_name} - Row {idx + 2}"
                
            print(f"Processing row {idx + 2}: Creating doc '{doc_title}'")
            
            # Find the image hyperlink (usually in Image Filename)
            image_url = None
            file_id = None
            try:
                img_col_idx = headers.index("Image Filename")
                formula_val = str(formula_row[img_col_idx])
                image_url = extract_url_from_formula(formula_val)
                if image_url:
                    file_id = extract_file_id_from_url(image_url)
            except ValueError:
                pass
                
            # Create Doc
            doc_id = create_google_doc(docs_service, drive_service, doc_title, OUTPUT_FOLDER_ID)
            
            # Populate Doc
            populate_doc(docs_service, drive_service, doc_id, headers, row, image_url, file_id)
            
            # Pace requests to avoid hitting limits as frequently
            time.sleep(2)

def main():
    if INPUT_SHEET_ID == 'your-input-spreadsheet-id-here' or OUTPUT_FOLDER_ID == 'your-output-folder-id-here':
        print("ERROR: Please update INPUT_SHEET_ID and OUTPUT_FOLDER_ID before running.")
        return
        
    print("Authenticating with Google APIs...")
    drive_service, sheets_service, docs_service = get_google_services()
    
    # Process Research Logs
    def research_name_template(headers, row):
        try:
            char_idx = headers.index("Lead Researcher Character Name")
            char_name = str(row[char_idx]).strip()
            return f"(WIP) Research - {char_name}"
        except ValueError:
            return None
            
    process_tab(drive_service, sheets_service, docs_service, "Research Logs", research_name_template)
    
    # Process Influence Spends Logs
    def influence_name_template(headers, row):
        try:
            action_idx = headers.index("Action")
            char_idx = headers.index("Character Name")
            action = str(row[action_idx]).strip()
            char_name = str(row[char_idx]).strip()
            return f"(WIP) {action} - {char_name}"
        except ValueError:
            return None
            
    process_tab(drive_service, sheets_service, docs_service, "Influence Spends Logs", influence_name_template)
    
    print("Step 3 complete!")

if __name__ == '__main__':
    main()
