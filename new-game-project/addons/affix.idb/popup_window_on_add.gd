@tool
class_name MyPopup extends Window

var tree: Tree
var root: TreeItem
var header: TreeItem
var database: SQLite
var popup: PopupMenu
var option_button: OptionButton
var instanced_ui_elements = []
var texture: Texture2D = preload("res://addons/affix.idb/btn_new.png")
signal button_pressed
	
func _enter_tree() -> void:
	option_button = $background/OptionButton
	popup = $PopupMenu
	tree = $background/Panel/Tree
	database = SQLite.new()
	database.open_db()
	database.query("SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'")
	for table_name in database.query_result:
		option_button.add_item(table_name["name"])
	
func _exit_tree() -> void:
	database.close_db()
	option_button.clear()
	
func _on_close_requested() -> void:
	queue_free()
	
func _on_option_button_item_selected(index: int) -> void:
	tree.clear()
	var table_name: String = option_button.get_item_text(index)
	root = tree.create_item()
	
	header = tree.create_item(root)
	header.set_text(0, table_name)
	header.set_icon(0, texture)
	header.set_text_alignment(0, HORIZONTAL_ALIGNMENT_LEFT)
	header.set_custom_bg_color(0, Color(0.25, 0.26, 0.298))
	header.set_custom_bg_color(1, Color(0.25, 0.26, 0.298))
	
	database.query("PRAGMA table_info("+table_name+")")
	var table_fields = database.query_result
	
	database.query("PRAGMA foreign_key_list("+table_name+")")
	var table_foreign_keys = database.query_result
	
	for row in table_fields:
		if row["name"] == "id":
			continue
		var treeItem: TreeItem = tree.create_item(header)
		treeItem.set_text(0, row["name"])
		if row["name"].ends_with("id"):
			treeItem.set_metadata(1, {"table_name":table_name, "name":row["name"]})
		else:
			treeItem.set_editable(1, true)
		treeItem.set_custom_bg_color(1, Color(0.21, 0.21, 0.3))
	
func _on_tree_cell_selected() -> void:
	var item: TreeItem = tree.get_selected()
	if item.get_metadata(1) == null:
		return
	popup.clear(true)
	var table_name = item.get_metadata(1)["table_name"]
	var row_name = item.get_metadata(1)["name"]
	database.query("PRAGMA foreign_key_list(" + table_name + ")")
	var referenced_table = ""
	for row in database.query_result:
		if row["from"] == row_name:  # Match the foreign key column
			referenced_table = row["table"]
			break
	
	if referenced_table != "":
		database.query("SELECT name FROM " + referenced_table)
		for result in database.query_result:
			popup.add_item(result["name"])
			
	var button_rect: Rect2i = tree.get_item_area_rect(item, 1)
	var tree_rect: Rect2i = $background/Panel.get_rect()
	popup.position = self.position + button_rect.position + tree_rect.position
	popup.popup()
	
func _on_popup_menu_id_pressed(id: int) -> void:
	var selected_item = popup.get_item_text(id)
	
	var selected_tree_item = tree.get_selected()
	if selected_tree_item:
		selected_tree_item.set_text(1, selected_item)
	
func _on_button_pressed() -> void:
	
	var table_name = header.get_text(0)
	var child_count = header.get_child_count()

	var row_data = {}
	
	for i in range(0, child_count):
		var item: TreeItem = header.get_child(i)
		var key = item.get_text(0)
		var value = item.get_text(1)
		row_data[key] = value
	
	database.insert_row(table_name, row_data)
	
	button_pressed.emit({"table_name": table_name, "row_data": row_data})
