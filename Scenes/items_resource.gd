extends Resource

var delimiter = ";"

func convertToArray(string):
	var arr = []
	var packed_arr = string.split(delimiter)
	for i in packed_arr.size():
		arr += [int(packed_arr[i])]
	return arr

func convertToData(nodes):
	var maxSlots = nodes.size()
	var ids = ""
	var quantities = ""
	
	for i in maxSlots:
		var slotData = nodes[i].getData()
		if slotData:
			ids += str(slotData["item_id"])
			quantities += str(slotData["quantity"])
		ids += delimiter
		quantities += delimiter
	ids = ids.left(-1)
	quantities = quantities.left(-1)
	
	var data = {"ids": ids, "quantities": quantities}
	return data
