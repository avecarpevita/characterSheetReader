import pyodbc
import os
from dotenv import load_dotenv

def execSpReadCharacterJsonForLores(cnxn,characterJson):
    cursor = cnxn.cursor()
    query=f"exec readCharacterJsonForLores @characterJson='{characterJson}'"
    cursor.close()



if __name__ == "__main__":

    load_dotenv(dotenv_path=r'C:\characterSheetReader\.env')
    server=os.getenv('server')
    database=os.getenv('database')

    print(f'server {server}')
    print(f'database {database}')
    conn_str = (
            "DRIVER={ODBC Driver 17 for SQL Server};"  # Or your specific driver name
            f"SERVER={server};"
            f"DATABASE={database};"
            "Trusted_Connection=yes;"
        )
    cnxn = pyodbc.connect(conn_str)
    cursor = cnxn.cursor()
    cursor.execute("truncate table rawLores;select * from rawLores")
    rawLores = cursor.fetchall()
    for rawLore in rawLores:
        print(f"{rawLore.characterName}\t{rawLore.playerName}\t{rawLore.rawLore}")
    

    cursor.execute("truncate table rawLores;select * from rawLores")

    cursor.close()
    cnxn.close()