@tool
class_name EditorController extends Control

var tree: Tree
var root: TreeItem
var database: SQLite
var table_names = []

func _exit_tree() -> void:
	tree.clear()
	database.close_db()
	pass

func _enter_tree() -> void:
	database = SQLite.new()
	database.open_db()
	tree = $Tree
	populate_database_view()
	
func populate_database_view() -> void:
	tree.clear()
	root = tree.create_item()
	
	database.query("SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'")
	table_names = database.query_result
	for table_name in table_names:
		build_table(table_name["name"])
	
func build_table(table_name:String) -> void:
	var table_item: TreeItem = tree.create_item(root)
	table_item.set_text(0, table_name)
	table_item.set_text_alignment(0, HORIZONTAL_ALIGNMENT_LEFT)
	table_item.set_custom_bg_color(0, Color(0.25, 0.26, 0.298))
	table_item.set_custom_bg_color(1, Color(0.25, 0.26, 0.298))
	database.query("SELECT * FROM " + table_name)
	for row_data in database.query_result:
		add_row(table_item, row_data)
	table_item.set_collapsed_recursive(true)

func add_row(table_item: TreeItem, row_data: Dictionary) -> TreeItem:
	var row:TreeItem = table_item.create_child()
	row.add_button(1, preload("res://addons/affix.idb/btn_delete.png"))
	row.set_text(0, str(row_data["id"]))
	row.set_metadata(0, row_data)
	for key in row_data.keys():
		var field = row.create_child()
		field.set_text(0, key)  # Set column name
		field.set_text(1, str(row_data[key]))	
		var is_id = key.ends_with("id")
		if not is_id:
			field.set_editable(1, true)
			field.set_custom_bg_color(1, Color(0.21, 0.21, 0.3))
	
func item_edited() -> void:
	var treeItem: TreeItem = tree.get_edited()
	var dictionary = treeItem.get_parent().get_metadata(0)
	var table_name = treeItem.get_parent().get_parent().get_text(0)
	dictionary[treeItem.get_text(0)] = str(treeItem.get_text(1))
	database.update_rows(table_name, "id = " + str(dictionary["id"]), dictionary)

func _on_tree_button_clicked(item: TreeItem, column: int, id: int, mouse_button_index: int) -> void:
	var table_name = item.get_parent().get_text(0)
	print(item.get_metadata(0))

func _on_btn_add_pressed() -> void:
	var popup:MyPopup = preload("res://addons/affix.idb/popup_window_on_add.tscn").instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
	add_child(popup)
	var content = await popup.button_pressed
	popup.queue_free()
	var index = table_names.find(content["table_name"])
	print(root.get_child(index).get_text(0))
