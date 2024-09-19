extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	stringManip()

func combineNullAsDict():
	var emptyDict = null
	var data = {"var1": "1", "var2": ""}
	
	data["var1"] += str(", ", emptyDict["var1"])
	data["var2"] += str(", ", emptyDict["var2"])
func arrSizeWithMixedSlots():
	var arr = [0, null, 2, 3]
	print(str("this array has a size of: ", arr.size()))
func stringManip():
	var str = "123abc"
	print(str)
	print(str.lstrip("123"))
	print(str.rstrip("abc"))
	print(str.left(4))
	
	str = ";;;1"
	print(str)
	str = str.lstrip(";") #strips all semicolons
	print(str)
func angles():
	var player = Vector2(2,.5)
	var corners = [Vector2(1,1), Vector2(0,1), Vector2(0,0), Vector2(1,0)]
	var target = Vector2(0,.5)
	
	var angle = target.angle_to_point(player)
	if abs(angle - PI) < 0.0001:
		angle = PI
	#print(angle)
	if angle < 0:
		angle = 2*PI + angle
	
	var cornerAngles = []
	for i in 4:
		cornerAngles += [target.angle_to_point(corners[i])]
		#print(cornerAngles[i])
		if cornerAngles[i] < 0:
			cornerAngles[i] = 2*PI + cornerAngles[i] 
	
	for i in 3:
		while cornerAngles[i] >= cornerAngles[i+1]:
			cornerAngles[i+1] += PI
	
	var face = "Right"
	for i in 4:
		if cornerAngles[i] < angle:
			match i:
				0:
					face = "Down"
				1:
					face = "Left"
				2:
					face = "Up"
				3:
					face = "Right"
	
	print(cornerAngles)
	print(angle)
	print(face)
func waiting():
	print("charge left")
	await Input.is_action_just_pressed("ui_down")
	print("start charge left")
func testEmptyVector():
	var x = 0
	var y = 0
	var vec = Vector2(x, y)
	print(vec)
	if vec.is_zero_approx():
		print(0)
func testEmptyForLoop():
	#var things = null #error
	#var things = [] #works and prints nothing
	#var things = get_children() #works and prints nothing
	#for thing in things:
	#	print("there was a thing")
	var numthings = get_child_count()
	print(numthings)
	for num in numthings:
		print(get_child(num))
	
	numthings = []
	print(numthings)
	for num in numthings:
		print(num)
func getNodeNameID():
	var nam = name.lstrip("Testnode_")
	print(nam)
	return nam
func convertToVector2i():
	var vec = Vector2i(10, 20)
	print(vec)
	
	var packedArr = str(vec).split(",")
	print(packedArr)
	
	var num1 = packedArr[0].to_int()
	var num2 = packedArr[1].to_int()
	print(num1)
	print(num2)
func whatIsQueryFilter():
	var array = [{"a": 1, "b": 2}, {"a": 1, "b": 3}]
	var newArr = array.filter(func(r):return r["a"]==1)
	print(array)
	print(newArr)
func getSetTextures():
	var node1 = get_node("../sender")
	var node2 = get_node("../receiver")
	
	var nodeTexture = node1.get_texture()
	node2.set_texture(nodeTexture)
func returnNull():
	print("nothing")
	#no return or return both produce <null>
func puttingDictionaryIntoDictionary():
	var dict1 = {"a": 1, "b": 2}
	var dict2 = {"c": 3, "d": 4}
	
	dict1["dict2"] = dict2
	
	print(dict1)
	print(dict1["dict2"]["c"])
func combineArrays():
	var arr1 = [1]
	var arr2 = [2]
	
	print(arr1 + arr2)
	print(arr1 + [3])
func combineDictionaries():
	var dict1 = {"a": 1, "b": 2}
	var dict2 = {"c": 3, "d": 4}
	dict1.merge(dict2)
	print(dict1)
	
	dict1 = {"a": 1, "b": 2}
	dict2 = {"c": 3, "d": 4}
	dict1.merge({str("npc", 0): dict2})
	print(dict1)
func getSibling():
	var node = get_node("../Sibling")
	print(node.name)
func dictionaryOfDictionaries():
	var dictionary = {}
	var dic1 = {"a": 1, "b": 1}
	var dicone = {"a": 3, "b": 3}
	var dic2 = {"a": 2, "b": 2}
	var dictwo = {"a": 4, "b": 4}
	
	dictionary["one"] = []
	#dictionary["one"].append(dic1)
	dictionary["one"].append(dicone)
	
	dictionary["two"] = []
	dictionary["two"] += [dic2]
	dictionary["two"] += [dictwo]
	
	print(dictionary)
	print(dictionary["one"])
	print(dictionary["one"][0])
	print(dictionary["one"][0]["a"])
	
	for i in dictionary["one"].size():
		if dictionary["one"][i]["a"] == 3:
			dictionary["one"].remove_at(i)
			break
	print(dictionary)
	print(dictionary["one"] == [])
func dictionaryOfArrays():
	var dictionary = {}
	var array1 = ["a", "b"]
	var arrayone = ["c", "d"]
	var array2 = ["1", "2"]
	var arraytwo = ["3", "4"]
	
	dictionary["one"] = []
	dictionary["one"] += array1
	dictionary["one"] += arrayone
	
	dictionary["two"] = []
	dictionary["two"] += array2
	dictionary["two"] += arraytwo
	
	print(dictionary)
func arraySize():
	var array = [1, 2, 3, 4]
	print(array.size())
func plantGrowthFrame():
	var maxFrame = 4
	var growthTime = 4
	
	var formula
	var fformula = 0
	
	for currentGrowthStage in growthTime+1:
		if currentGrowthStage == 0:
			formula = 0
		elif currentGrowthStage == growthTime+1:
			formula = maxFrame
		else:
			fformula = (1.0*maxFrame-1) * currentGrowthStage / growthTime
			formula = (maxFrame-1) * currentGrowthStage / growthTime
			if formula == 0:
				formula = 1
			elif formula == maxFrame:
				formula = maxFrame - 1
			else:
				formula += 1
		print(str(currentGrowthStage, ": ", formula, " ... ", fformula))
