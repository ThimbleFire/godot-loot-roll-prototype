@tool 
extends OptionButton

var database: SQLite
var root: TreeItem
var meta_dict = {}

var texture_delete = preload("res://addons/affix.idb/btn_delete.png")
var texture_add = preload("res://addons/affix.idb/btn_new.png")

var selected_monster

func _enter_tree() -> void:	
	database = SQLite.new()
	database.open_db()
	
	
func _exit_tree() -> void:
	database.close_db()

func _on_txtMonsterSearch_text_changed(new_text: String) -> void:
	clear()
	if new_text == "":
		return
	database.query_with_bindings("SELECT * FROM Monsters WHERE name LIKE ?", ["%"+new_text+"%"])
	for monster_name in database.query_result:
		add_item(monster_name["name"])

func _on_item_selected(index: int) -> void:
	var selected_name: String = get_item_text(index)
	database.query_with_bindings("SELECT * FROM Monsters WHERE name = ?", [selected_name])
	selected_monster = database.query_result.front()
	compile_database_view(selected_name)
	pass

func compile_database_view(selected_name) -> void:
	var option_button: OptionButton = $"../../VBoxContainer3/OptionButton"
	option_button.clear()
	var tree = $"../../Tree"
	tree.clear()
	root = tree.create_item()
	tree.set_column_title(0, "item_id")
	tree.set_column_title(1, "name")
	tree.set_column_title(2, "quantity")
	tree.set_column_title(3, "probability")
	
	database.query_with_bindings("SELECT * FROM TableEntries WHERE monster_table_id = ?", [selected_monster["id"]])

	for loot_table in database.query_result:
		var table_tree: TreeItem = root.create_child()
		table_tree.set_text(0, loot_table["name"] + " table id:" + str(loot_table["id"]))
		database.query_with_bindings("SELECT * FROM ItemEntries WHERE loot_table_id = ?", [loot_table["loot_table_id"]])
		for item in database.query_result:
			var itemTree: TreeItem = table_tree.create_child()
			database.query_with_bindings("SELECT name FROM Items WHERE id = ?", [item["item_id"]])
			itemTree.set_text(0, str(item["item_id"]))
			itemTree.set_text(1, database.query_result.front()["name"])
			itemTree.set_text(2, str(item["quantity"]) + "x")
			itemTree.set_text(3, str(item["probability"]))
		option_button.add_item(loot_table["name"])
	
func _on_btn_down_remove_table() -> void:
	var option_button: OptionButton = $"../../VBoxContainer3/OptionButton"
	var table_name = option_button.get_item_text(option_button.selected)
	database.query_with_bindings("DELETE FROM TableEntries WHERE name = ? AND monster_table_id = ?", [table_name, selected_monster["id"]])
	compile_database_view(selected_monster["name"])
	
func _on_txtAddLootTableSearch_text_changed(new_text: String) -> void:
	var option_button: OptionButton = $"../../VBoxContainer2/OptionButton"
	option_button.clear()
	database.query_with_bindings("SELECT name FROM LootTables WHERE name LIKE ?", ["%"+new_text+"%"])
	for loot_table in database.query_result:
		option_button.add_item(loot_table["name"])
		
func _on_btn_down_add_table() -> void:
	var option_button: OptionButton = $"../../VBoxContainer2/OptionButton"
	var table_name = option_button.get_item_text(option_button.selected)
	database.query_with_bindings("SELECT * FROM LootTables WHERE name = ?", [table_name])
	var product: Dictionary = database.query_result.front()
	product["monster_table_id"] = selected_monster["id"]
	product["loot_table_id"] = product["id"]
	product.erase("id")
	
	database.insert_row("TableEntries", product)
	compile_database_view(selected_monster["name"])
	pass
	
	
