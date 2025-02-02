@tool
extends Panel

var database: SQLite
var root: TreeItem
var selected_table

func _enter_tree() -> void:	
	database = SQLite.new()
	database.open_db()
	
func _exit_tree() -> void:
	database.close_db()
	
func _on_line_edit_text_changed(new_text: String) -> void:
	var btnSearchTable: OptionButton = $OptionButton
	btnSearchTable.clear()
	if new_text == "":
		return
	database.query_with_bindings("SELECT * FROM LootTables WHERE name LIKE ?", ["%"+new_text+"%"])
	for table_name in database.query_result:
		btnSearchTable.add_item(table_name["name"])

func _on_option_button_item_selected(index: int) -> void:
	compile_database_view()
	
func compile_database_view() -> void:
	var tree = $Tree
	tree.clear()
	tree.set_column_title(0, "item_id")
	tree.set_column_title(1, "name")
	tree.set_column_title(2, "quantity")
	tree.set_column_title(3, "probability")
	root = tree.create_item()
	
	var btnSearchTable: OptionButton = $OptionButton
	var selected_name: String = btnSearchTable.text
	database.query_with_bindings("SELECT * FROM LootTables WHERE name = ?", [selected_name])
	selected_table = database.query_result.front()
	database.query_with_bindings("SELECT * FROM ItemEntries WHERE loot_table_id = ?", [selected_table["id"]])
	root.set_text(0, selected_name + " table id:" + str(selected_table["id"]))
	for item in database.query_result:
		var itemTree: TreeItem = root.create_child()
		database.query_with_bindings("SELECT name FROM Items WHERE id = ?", [item["item_id"]])
		itemTree.set_text(0, str(item["item_id"]))
		itemTree.set_text(1, database.query_result.front()["name"])
		itemTree.set_text(2, str(item["quantity"]) + "x")
		itemTree.set_text(3, str(item["probability"]))

func _on_item_add_filter_text_changed(new_text: String) -> void:
	var btn_item_lookup: OptionButton = $"Add_Margin/Add/Item Lookup/OptionButton"
	btn_item_lookup.clear()
	if new_text == "":
		return
	database.query_with_bindings("SELECT * FROM Items WHERE name LIKE ?", ["%"+new_text+"%"])
	for item_name in database.query_result:
		btn_item_lookup.add_item(item_name["name"])

func _on_btn_pressed_add_item_to_table() -> void:
	var btn_item_lookup: OptionButton = $"Add_Margin/Add/Item Lookup/OptionButton"
	database.query_with_bindings("SELECT * FROM Items WHERE name = ?", [btn_item_lookup.text])
	var table = database.query_result.front()
	var item: Dictionary = { 
		"loot_table_id": selected_table["id"], 
		"item_id": table["id"],
		"probability": $Add_Margin/Add/Probability/SpinBox.value, 
		"quantity": $Add_Margin/Add/Quantity/SpinBox.value 
	}
	database.insert_row("ItemEntries", item)
	compile_database_view()
