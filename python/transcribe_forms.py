import os
import io
import json
import pandas as pd
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

if not GEMINI_API_KEY:
    print("WARNING: GEMINI_API_KEY not found in .env file. Please add it.")
    exit(1)

genai.configure(api_key=GEMINI_API_KEY)

# Use the same scopes to remain compatible with existing token.json
SCOPES = [
    'https://www.googleapis.com/auth/spreadsheets.readonly',
    'https://www.googleapis.com/auth/documents',
    'https://www.googleapis.com/auth/drive'
]

FOLDER_ID = '1WPv1c1IcPQt48N1Y44Qy9UevOa9cizaa'
OUTPUT_CSV = 'transcribed_forms.csv'

def get_drive_service():
    """Authenticates and returns the Drive service using User Credentials."""
    creds = None
    if os.path.exists('token.json'):
        creds = Credentials.from_authorized_user_file('token.json', SCOPES)
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            if not os.path.exists('credentials.json'):
                raise FileNotFoundError("Missing credentials.json.")
            flow = InstalledAppFlow.from_client_secrets_file('credentials.json', SCOPES)
            creds = flow.run_local_server(port=0)
        with open('token.json', 'w') as token:
            token.write(creds.to_json())
    return build('drive', 'v3', credentials=creds)

def download_file(drive_service, file_id, file_name):
    """Downloads a file from Google Drive."""
    request = drive_service.files().get_media(fileId=file_id)
    fh = io.BytesIO()
    downloader = MediaIoBaseDownload(fh, request)
    done = False
    while done is False:
        status, done = downloader.next_chunk()
    fh.seek(0)
    # Save locally to open with PIL later
    with open(file_name, 'wb') as f:
        f.write(fh.read())
    return file_name

def transcribe_image_with_gemini(image_path):
    """Uses Gemini API to extract specific fields from the form image."""
    model = genai.GenerativeModel('gemini-1.5-pro')
    
    prompt = """
    Analyze this handwritten form and extract the requested fields. 
    Return the response as a valid JSON object. Do not include markdown formatting like ```json in the output, just the raw JSON object.
    If a field is empty or unreadable, set its value to an empty string "".
    
    The required JSON keys are:
    - "Lead Researcher Player Name"
    - "Character Name"
    - "Assistants (Characters)"
    - "Library or Research Object Used"
    - "Lores Applied to this topic"
    - "Research Question, Notes and Additional Information Here"
    """
    
    img = PIL.Image.open(image_path)
    response = model.generate_content([prompt, img])
    
    # Try to parse the response as JSON
    try:
        text = response.text.strip()
        if text.startswith("```json"):
            text = text[7:]
        if text.endswith("```"):
            text = text[:-3]
        text = text.strip()
        data = json.loads(text)
        return data
    except Exception as e:
        print(f"Error parsing Gemini response for {image_path}: {e}")
        print("Raw response:", response.text)
        return None

def main():
    print("Authenticating with Google Drive...")
    drive_service = get_drive_service()
    
    print(f"Searching for .jpg files in folder ID: {FOLDER_ID}...")
    query = f"'{FOLDER_ID}' in parents and mimeType='image/jpeg' and trashed=false"
    results = drive_service.files().list(q=query, fields="files(id, name)").execute()
    items = results.get('files', [])
    
    if not items:
        print('No .jpg files found in the folder.')
        return
        
    print(f"Found {len(items)} files. Starting transcription...")
    
    extracted_data = []
    
    for i, item in enumerate(items):
        file_id = item['id']
        file_name = item['name']
        print(f"[{i+1}/{len(items)}] Processing {file_name}...")
        
        # Download temporarily
        local_path = download_file(drive_service, file_id, file_name)
        
        # Transcribe
        data = transcribe_image_with_gemini(local_path)
        if data:
            data['Source File'] = file_name
            extracted_data.append(data)
            
        # Clean up temporary file
        if os.path.exists(local_path):
            os.remove(local_path)
            
    if extracted_data:
        df = pd.DataFrame(extracted_data)
        
        # Reorder columns to put Source File first
        cols = ['Source File'] + [c for c in df.columns if c != 'Source File']
        df = df[cols]
        
        df.to_csv(OUTPUT_CSV, index=False)
        print(f"Successfully transcribed {len(extracted_data)} forms to {OUTPUT_CSV}")
    else:
        print("No data was successfully extracted.")

if __name__ == '__main__':
    main()
