'''
final state will read all sheets from source folder into .json blobs and ingest into destination pg sql databse
#stage 1 just does the ingest and exports them as text files to a destination 

example call
py tmProcessAllSheets.py "-ic:/characterSheets" "-oc:/characterSheets/json" "-sA" "-eE"
py tmProcessAllSheets.py "-ic:/characterSheets" "-oc:/characterSheets/json" "-sF" "-eJ"
py tmProcessAllSheets.py "-ic:/characterSheets" "-oc:/characterSheets/json" "-sK" "-eO"
py tmProcessAllSheets.py "-ic:/characterSheets" "-oc:/characterSheets/json" "-sP" "-eT"
py tmProcessAllSheets.py "-ic:/characterSheets" "-oc:/characterSheets/json" "-sU" "-eZ"
py python\tmProcessAllSheets.py "-sU" "-eZ"
C:/Users/scott.ross/AppData/Local/Microsoft/WindowsApps/python3.13.exe c:/characterSheetReader/python/tmProcessAllSheets.py "-sA" "-eE"
C:/Users/scott.ross/AppData/Local/Microsoft/WindowsApps/python3.13.exe c:/characterSheetReader/python/tmProcessAllSheets.py "-sF" "-eJ"
C:/Users/scott.ross/AppData/Local/Microsoft/WindowsApps/python3.13.exe c:/characterSheetReader/python/tmProcessAllSheets.py "-sK" "-eO"
C:/Users/scott.ross/AppData/Local/Microsoft/WindowsApps/python3.13.exe c:/characterSheetReader/python/tmProcessAllSheets.py "-sP" "-eT"
C:/Users/scott.ross/AppData/Local/Microsoft/WindowsApps/python3.13.exe c:/characterSheetReader/python/tmProcessAllSheets.py "-sU" "-eZ"
'''
import tmParseSheet
import tmReadSheet
import json
import os
from dotenv import load_dotenv
import sys



def getXlsxInputPath(inputPath,startFileName,endFileName):
    listXlsx=[]
    try:
        files = os.listdir(inputPath)
        for filename in files:
                filePath = os.path.join(inputPath,filename)
                if os.path.isfile(filePath) and filename[-5:]=='.xlsx':
                    listXlsx.append(filePath)
    except FileNotFoundError:
        print(f"Error: Folder '{inputPath}' not found.")                    
    except Exception as e:
        print(f"An error occured: {e}")     
    if startFileName!=None and endFileName!=None:
        workList=[]
        for inputFilePath in listXlsx:      
            if startFileName.upper()[0:1] <= os.path.basename(inputFilePath).upper()[0:1] <= endFileName.upper()[0:1]:
                workList.append(inputFilePath)
        listXlsx=workList
    return listXlsx        

def exportCharacterToJson(inputFilePath,outputFilePath):
    dfCharacter = tmReadSheet.tmReadSheet(inputFilePath)[0]
    dfProgression = tmReadSheet.tmReadSheet(inputFilePath)[1]
    dfHistory = tmReadSheet.tmReadSheet(inputFilePath)[2]
    dfEmergency = tmReadSheet.tmReadSheet(inputFilePath)[3]
    characterJson = tmParseSheet.tmParseSheet(dfCharacter,dfProgression,dfHistory,dfEmergency,inputFilePath)
    with open(outputFilePath, "w") as f:
        f.write(characterJson)
        f.close()
        
def exportCharacterToJsonAndDB(inputFilePath,outputFilePath,cur):
    dfCharacter = tmReadSheet.tmReadSheet(inputFilePath)[0]
    dfProgression = tmReadSheet.tmReadSheet(inputFilePath)[1]
    dfHistory = tmReadSheet.tmReadSheet(inputFilePath)[2]
    dfEmergency = tmReadSheet.tmReadSheet(inputFilePath)[3]
    characterJson = tmParseSheet.tmParseSheet(dfCharacter,dfProgression,dfHistory,dfEmergency,inputFilePath)
    with open(outputFilePath, "w") as f:
        f.write(characterJson)
        f.close()
    sql=f'call loadcharacterjson(\''+characterJson.replace('\n','').replace('\r','').replace('    ','').replace('\'','\'\'')+'\')'   
    try:      
        cur.execute(sql)
    except psycopg2.Error as e:
        print(f"psycopg2 Error ", e)
    #this returns an error on most sheets, so we only write out on sql process errors
    sqlResultOutputFilePath = outputFilePath.replace('.json','.sqllog')
    f2=open(sqlResultOutputFilePath, "w")
    try:
        sqlReturnRows=cur.fetchall()
        if cur.rowcount>0:
            for row in sqlReturnRows:
                f2.write(row)
    except:
        f2.write('no sql errors')
    f2.close() 

###MAIN BLOCK###
if __name__ == "__main__":
    #get the input and output paths from args
    # -i    input folder
    # -o    output folder
    #checkargs
    inputPath=None
    outputPath=None
    startFileName=None
    endFileName=None
    load_dotenv(dotenv_path=r'C:\sheetReader\.env')
    

    
    for i in range(1, len(sys.argv)):
        if sys.argv[i][:2]=="-i":
            inputPath=sys.argv[i][2:len(sys.argv[i])]
            if inputPath[-1:]!="/": 
                inputPath=inputPath+"/"
        if sys.argv[i][:2]=="-o":
            outputPath=sys.argv[i][2:len(sys.argv[i])]
            if outputPath[-1:]!="/": 
                outputPath=outputPath+"/"
        if sys.argv[i][:2]=="-s":
            startFileName=sys.argv[i][2:len(sys.argv[i])]
        if sys.argv[i][:2]=="-e":
            endFileName=sys.argv[i][2:len(sys.argv[i])]
    
    inputPath=os.getenv('sheetsDirectory')
    outputPath=inputPath +'/json/'


    print('inputPath                ', inputPath)            
    print('outputPath               ', outputPath)  
    print('startFileName            ', startFileName)  
    print('endFileName              ', endFileName)  
    
    #get .xlsx files in the inputPath folder        
    listXlsx=getXlsxInputPath(inputPath,startFileName,endFileName)
    print('number of files found    ', len(listXlsx))
    
    processCount=0
    for inputFilePath in listXlsx:
        outputFilePath = outputPath + os.path.basename(inputFilePath)[:len(os.path.basename(inputFilePath))-5] + '.json'
        processCount+=1
        print('#' , str(processCount) , ' ' ,inputFilePath, ' ', outputFilePath)
        exportCharacterToJson(inputFilePath,outputFilePath)
        #exportCharacterToJsonAndDB(inputFilePath,outputFilePath,cur)
    
  
            