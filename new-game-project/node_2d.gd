extends Node

func _ready():
	var goblin = Goblin.new("Goblin")
	
	for i in range(0, 10):
		var item = goblin.roll_loot()
		print("on kill %d: Looted: %s (x%d)" % [i, item.name, item.quantity])
