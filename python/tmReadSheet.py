''' 
fn tmReadSheet (xlspath)
            get all sheets from workbook, and their names
            identify the four targeted sheets -- character, progression, history, emergency
            read in each sheet into separate dataframes -- generate empty dataframes for missing sheets
            return a list of dataframes 0: character, 1:progression, 2: history, 3:emergency, 4: everything in one dataframe for exception tracking?
'''
import pandas as pd
import os
from dotenv import load_dotenv


def tmReadSheet(excelFilePath):
    dictAllSheets = pd.read_excel(io=excelFilePath, na_values='Missing', header=None, sheet_name=None)
    listAllSheetsDataframeSheets = dictAllSheets.keys()
    dfCharacter=pd.DataFrame()
    dfProgression=pd.DataFrame()
    dfHistory=pd.DataFrame()
    dfEmergency=pd.DataFrame()
    if 'CHARACTER' in list(map(str.upper,listAllSheetsDataframeSheets)):
        dfCharacter=pd.read_excel(io=excelFilePath, na_values='Missing', header=None, sheet_name=list(map(str.upper,listAllSheetsDataframeSheets)).index('CHARACTER'))
        dfCharacter.columns = [f'col{col}' for col in dfCharacter.columns]
    if 'PROGRESSION' in list(map(str.upper,listAllSheetsDataframeSheets)):
        dfProgression=pd.read_excel(io=excelFilePath, na_values='Missing', header=None, sheet_name=list(map(str.upper,listAllSheetsDataframeSheets)).index('PROGRESSION'))
        dfProgression.columns = [f'col{col}' for col in dfProgression.columns]
    if 'HISTORY' in list(map(str.upper,listAllSheetsDataframeSheets)):
        dfHistory=pd.read_excel(io=excelFilePath, na_values='Missing', header=None, sheet_name=list(map(str.upper,listAllSheetsDataframeSheets)).index('HISTORY'))
        dfHistory.columns = [f'col{col}' for col in dfHistory.columns]
    if 'EMERGENCY' in list(map(str.upper,listAllSheetsDataframeSheets)):
        dfEmergency=pd.read_excel(io=excelFilePath, na_values='Missing', header=None, sheet_name=list(map(str.upper,listAllSheetsDataframeSheets)).index('EMERGENCY'))
        dfEmergency.columns = [f'col{col}' for col in dfEmergency.columns]
    return [dfCharacter,dfProgression,dfHistory,dfEmergency,dictAllSheets]

if __name__ == "__main__":
    load_dotenv(dotenv_path=r'C:\sheetReader\.env')
    sheetsDirectory=os.getenv('sheetsDirectory')
    excelFilePath=f'{sheetsDirectory}/Aaron Vandhana (Aeloss).xlsx'
    print(excelFilePath)
    dictAllSheets = tmReadSheet(excelFilePath)[4]
    print(dictAllSheets.keys()) # Prints all sheet names
    
    