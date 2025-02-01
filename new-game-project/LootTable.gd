class_name LootTable

var items: Array
var rarity: int  # Higher value = Rarer table

func _init(rarity_value):
	items = []
	rarity = rarity_value

func add_item(name, quantity, value):
	items.append(LootItem.new(name, quantity, value))

func roll() -> LootItem:
	if items.size() == 0:
		return null

	var total_weight = 0.0
	var weights = []
	
	for item in items:
		var weight = 1.0 / item.value  # Lower value = Higher weight
		weights.append(weight)
		total_weight += weight
	
	var roll = randf() * total_weight
	var cumulative = 0.0

	for i in range(items.size()):
		cumulative += weights[i]
		if roll < cumulative:
			return items[i]  # Return the selected item
	
	return null
