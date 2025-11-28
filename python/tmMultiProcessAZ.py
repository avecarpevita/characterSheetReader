from multiprocessing import Pool
import os
import tmProcessAllSheets 
from dotenv import load_dotenv

def worker_function(name):
    print(f"Hello, {name} from process ID: {os.getpid()}")

if __name__ == '__main__':
    inputPath=None
    outputPath=None
    startFileName=None
    endFileName=None
    load_dotenv(dotenv_path=r'C:\characterSheetReader\.env')

    inputPath=os.getenv('sheetsDirectory')
    outputPath=inputPath +'/json/'
    server=os.getenv('server')
    database=os.getenv('database')

    print('inputPath                ', inputPath)            
    print('outputPath               ', outputPath)  
    print('startFileName            ', startFileName)  
    print('endFileName              ', endFileName)  
    print('server                   ', server)  
    print('database                 ', database)  


    letters=[]
    #for i in range(26):
        #letters.append(chr(i+65))
    letters.append([inputPath,outputPath,'Gab','Gab', server, database])
    letters.append([inputPath,outputPath,'Hai','Hai', server, database])
    with Pool(processes=4) as pool:
        pool.map(tmProcessAllSheets.processRangeOfSheets,letters)
