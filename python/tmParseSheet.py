'''
- [ ] export into .json blobs
        This will be piecemeal as new elements are desired.  
        e.g. at first, it will be player name, character name, cp and events, to answer simple play and cp questions
    tmParseSheet.py
        fn tmParseSheet(xlspath)
            call tmReadSheet, and store dataframes in local context -- 0: character, 1:progression, 2: history, 3:emergency
        fn tmPlayerName(dfCharacter)
            returns playerName
        --ad infinatum with the other pieces or slices
        fn tmCharacterSkills(dfCharacter)
            returns list of skills & spends -- no data validation here
        fn tmCharacterGames(dfGames)
            returns list of games and cp earned
        fn tmCharacterCorruption(dfCorruption)
            returns list of corruption events
- [ ] everything NOT included in the .json is exported to an .exceptions file
    Ideally this is a pipe-delimited dump, with column header, of the un-parsed cells on each tab
'''
import pandas as pd
import tmReadSheet
import json
import os
from dotenv import load_dotenv

def tmPlayerName(dfCharacter):
    #returns player name (usually found in 2nd column, 2nd row)
    return str(dfCharacter.query("col0 == 'Player:'").iat[0,1])

def tmCharacterName(dfCharacter):
    #returns character name (usually found in 5th column, 2nd row)
    return str(dfCharacter.query("col4 == 'Character:'").iat[0,5])

def tmEmail(dfCharacter):
    #returns email (usually found in 2nd column, 3nd row)
    return str(dfCharacter.query("col0 == 'Email:'").iat[0,1])

def tmBloodline(dfCharacter):
    if dfCharacter.query("col4 == 'Bloodline:'").empty is False:
        return dfCharacter.query("col4 == 'Bloodline:'").iat[0,5]
    if dfCharacter.query("col4 == 'Race:'").empty is False:
        return dfCharacter.query("col4 == 'Race:'").iat[0,5]
    else:
        return ''

def tmCulture(dfCharacter):
    culture = str(dfCharacter.query("col0 == 'Culture:'").iat[0,1])
    if culture != culture or culture == "nan":
        return ''
    else:
        return culture

def tmReligion(dfCharacter):
    religion = str(dfCharacter.query("col0 == 'Religion:'").iat[0,1])
    if religion != religion or religion == "nan": 
        return ''
    else:
        return religion
    
def tmCharacterPoints(dfCharacter):
    #returns a dictionary of total, spent, unspent
    totalCP = int(dfCharacter.query("col1 == 'Total CP:'").iat[0,2])
    spentCP = int(dfCharacter.query("col1 == 'Spent CP:'").iat[0,2])
    unspentCP = totalCP-spentCP
    return {'totalCP':totalCP, 'spentCP': spentCP, 'unspentCP': unspentCP}

def tmCorruption(dfCharacter):
    #could be under Corruption or Taint
    
    if dfCharacter.query("col4 == 'Corruption:'").empty is False:
        return int(dfCharacter.query("col4 == 'Corruption:'").iat[0,5])
    if dfCharacter.query("col4 == 'Taint:'").empty is False:
        return int(dfCharacter.query("col4 == 'Taint:'").iat[0,5])
    else:
        return None

def tmTethers(dfCharacter):
    if dfCharacter.query("col4 == 'Tethers:'").empty is False:
        return int(dfCharacter.query("col4 == 'Tethers:'").iat[0,5])
    else:
        return None


def tmHealth(dfCharacter):
    return int(dfCharacter.query("col6 == 'HP:'").iat[0,7])

def tmMana(dfCharacter):
    #could be blank
    manaCell = dfCharacter.query("col6 == 'Mana:'").iat[0,7]
    if manaCell!=manaCell:  #detects for NaN
        return 0
    else:   
        return int(manaCell)
    
def tmEvents(dfProgression):
    #list of cp event dictionaries
    #eventName, eventDate, cpEarned, ipToCp, foodCp
    #there are two formats, legacy and current
    #legacy format is 4 columns -- "reason", "date", "cpEarned", "ipToCP" -- with an additional row for food entries
    #current format is 5 columns --"reason", "date", "cpEarned", "ipToCP", "food"
    #first step is to determine format -- if thereare any non-numeric values in column E after row 1, then it is legacy
    isLegacyFormat = True
    #reversing the list to read from the bottom up to handle legacy food
    lol = dfProgression.values.tolist()
    isLegacy = True
    if "food" in str(lol[0][4]).lower() or "tag" in str(lol[0][4]).lower():
        isLegacy=False
    returnList = []
    legacyFoodRow=[]
    reverseLol = lol[1:2000][::-1]
    eventName=""
    eventDate=""
    cpEarned=0
    ipToCp=0
    foodCp=0
    for row in (reverseLol[0:2000]):
        #print(row)
        returnDict={}
        if isinstance(row[0],str) and not "credit" in str(row[0]).lower():
            if isLegacy:
                #is this a food row to be appended to the row above
                if "food" in str(row[0]).lower():
                    legacyFoodRow=row
                else:
                    eventName = row[0]
                    eventDate = str(row[1])
                    cpEarned = row[2]
                    ipToCp = row[3]
                    if len(legacyFoodRow)>3:
                        foodCp = legacyFoodRow[2]   
                        legacyFoodRow=[]
                    else:
                        foodCp = 0  
            else:   #not legacy
                eventName = row[0]
                eventDate = str(row[1])
                cpEarned = row[2]
                ipToCp = row[3]
                foodCp = row[4]

            eventDate=str(eventDate[0:10])
            if eventDate=="nan":    eventDate=""
            if not str(cpEarned).isnumeric():   cpEarned=0
            if not str(ipToCp).isnumeric():   ipToCp=0
            if not str(foodCp).isnumeric():   foodCp=0 

            if len(legacyFoodRow)==0:
                returnDict = {
                            "eventName": eventName
                            ,"eventDate": eventDate
                            ,"cpEarned": cpEarned
                            ,"ipToCp": ipToCp
                            ,"foodCp": foodCp
                    }                
                returnList.append(returnDict)
    
    return returnList            
    
def tmSkills(dfCharacter):
    #returns list of skill dictionaries -- rawSkillName, rawCpCost
    #the skill names are ALWAYS in column A [0], and E[4], starting on line 10[9]
    #then paried with a numeric value (it might have an *) in B[1]/F[5] respectively
    lol = dfCharacter.values.tolist()
    #lol[9:1000] returns all rows starting with line 10
    allColumnsRaw=[]
    for cRow in lol[9:1000]:
        allColumnsRaw.append([cRow[0], cRow[1]])
        allColumnsRaw.append([cRow[4], cRow[5]])
    returnList=[]
    for row in allColumnsRaw:
        if str(row[1]).replace('*','').isnumeric():
            returnDict = {
                            "rawSkillName": row[0]
                            ,"rawCPCost": row[1]
                    }             
            returnList.append(returnDict)
    return returnList

def tmParseSheet(dfCharacter,dfProgression,dfHistory,dfEmergency,excelFilePath):
    #returns a json blob
    try:
        dictCharacter = {
            "playerName": tmPlayerName(dfCharacter)
            ,"characterName": tmCharacterName(dfCharacter)
            ,"email": tmEmail(dfCharacter)
            ,"bloodline": tmBloodline(dfCharacter)
            ,"culture": tmCulture(dfCharacter)
            ,"religion": tmReligion(dfCharacter)
            ,"corruption": tmCorruption(dfCharacter)
            ,"tethers": tmTethers(dfCharacter)
            ,"health": tmHealth(dfCharacter)
            ,"mana": tmMana(dfCharacter)
            ,"characterPoints": tmCharacterPoints(dfCharacter)
            ,"events": tmEvents(dfProgression)
            ,"skills": tmSkills(dfCharacter)
            ,"excelFilePath": excelFilePath
        }
    except Exception as e:
        try:
            dictCharacter={"playerName": tmPlayerName(dfCharacter)
                           ,"exceptions": str({e})
                           ,"excelFilePath": excelFilePath
                           }
        except Exception as e2:     #i.e. even the playerName is unavailable
             dictCharacter={"playerName": "unavailable"
                           ,"exceptions": str(e2)
                           ,"excelFilePath": excelFilePath
                           }           
    return json.dumps(dictCharacter,indent=4)

if __name__ == "__main__":
    load_dotenv(dotenv_path=r'C:\sheetReader\.env')
    sheetsDirectory=os.getenv('sheetsDirectory')
    excelFilePath=f'{sheetsDirectory}/Scott Ross (Gaeden) (Staff).xlsx'
    #print(tmPlayerName(tmReadSheet.tmReadSheet(excelFilePath)[0]))
    dfCharacter = tmReadSheet.tmReadSheet(excelFilePath)[0]
    dfProgression = tmReadSheet.tmReadSheet(excelFilePath)[1]
    dfHistory = tmReadSheet.tmReadSheet(excelFilePath)[2]
    dfEmergency = tmReadSheet.tmReadSheet(excelFilePath)[3]

    '''
    print('player ',tmPlayerName(dfCharacter))
    print('character ',tmCharacterName(dfCharacter))
    print('email ',tmEmail(dfCharacter))
    print('bloodline ',tmBloodline(dfCharacter))
    print('culture ',tmCulture(dfCharacter))
    print('religion ',tmReligion(dfCharacter))
    print('corruption ',tmCorruption(dfCharacter))
    print('tethers ',tmTethers(dfCharacter))
    print('health ',tmHealth(dfCharacter))
    print('mana ',tmMana(dfCharacter))
    print('cp ',tmCharacterPoints(dfCharacter))
    '''
    print(tmParseSheet(dfCharacter,dfProgression,dfHistory,dfEmergency,excelFilePath))
    #print (json.dumps(tmSkills(dfCharacter)))
    
    
    