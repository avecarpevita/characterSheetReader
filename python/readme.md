♦ Deliverable #1
read all the sheets, and get all the lores in a list for Olivia
    ALSO, store character name, so I can validate with a load if somebody HAD one of my r. lores before the Dec25 cutoff

♦ Deliverable #2
read all the sheets, and get some numbers for characters played in the last 3 events (counting only the highest cp character)
    # of characters
    median cp
    # of characters sub 150
    150-300
    301-450
    451-600
    600+


♦ Deliverable #1 <detail>
tbl rawLores   
    --a simple dump to merge into for this exercise
sp readCharacterJsonForLores 
    --called by tmProcessAllSheets.py, passing in the json
    

♦ Deliverable #1.5
todo    I will need to have an error log for the runs to catch unparsed characters getting barfed