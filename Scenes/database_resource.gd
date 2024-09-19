extends Resource
#https://github.com/2shady4u/godot-sqlite/blob/master/demo/database.gd

var db
var dbPath = "res://Data/"

func deleteRow(file, table, key, id):
	db = SQLite.new()
	db.path = str(dbPath, file)
	db.open_db()
	db.delete_rows(table, str(key, " = ", id))

#saves to an existing or new row in a table. allows for up to 2 match values
func saveRow(file, table, rowToSave, overwriteKey = "", overwriteID = -1, extraKey = "", extraID = -1):
	db = SQLite.new()
	db.path = str(dbPath, file)
	db.open_db()
	
	if overwriteID == -1:
		db.insert_row(table, rowToSave)
		print("inserted row")
	else:
		var query_conditions = str(overwriteKey, " = '", overwriteID, "'")
		if extraID != -1: #there is an extra id
			query_conditions += str(" AND ", extraKey, " = '", extraID, "'")
		db.update_rows(table, query_conditions, rowToSave)
		print("updated row")

#returns a query based on input. can give 0, 1, or 2 keys
func getQuery(file, table, key1 = "*", key2 = ""):
	db = SQLite.new()
	db.path = str(dbPath, file)
	db.open_db()
	
	if key1 == "*" || key2 == "":
		db.query(str("select ", key1, " from ", table))
	else:
		db.query(str("select ", key1, ", ", key2, " from ", table))
	
	var query = db.query_result
	return query
	
#returns a dictionary given query table + key(s) and entry key + id
func getDictionary(file, table, tableKey, matchKey, matchID):
	var query = getQuery(file, table, tableKey)
	var entry = findEntry(query, matchKey, matchID)
	
	return entry
	
#returns a single value given a query table + key(s), the unique id to filter for, and the key of the desired value
func getValue(file, table, matchKey, matchID, valueKey):
	var query = getQuery(file, table)
	var entry = findEntry(query, matchKey, matchID)
	
	return entry[valueKey]

#returns a dictionary entry given multiple entries in an array
func findEntry(query, matchKey, matchID):
	if query == []:
		return
	var arrMatches = query.filter(func(r):return r[matchKey]==matchID)
	if typeof(arrMatches) == typeof([]):
		arrMatches = arrMatches[0]
	return arrMatches

#returns multiple dictionary entries given multiple entries
func findEntries(query, matchKey, matchID):
	return query.filter(func(r):return r[matchKey]==matchID)
