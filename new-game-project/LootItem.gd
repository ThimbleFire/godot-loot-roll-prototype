class_name LootItem

var name: String
var quantity: int
var value: int  # Higher value = Rarer

func _init(_name, _quantity, _value):
	name = _name
	quantity = _quantity
	value = _value
