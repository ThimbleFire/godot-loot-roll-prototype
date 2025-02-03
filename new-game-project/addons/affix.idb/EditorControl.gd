@tool
class_name EditorController extends Control

var tree: Tree
var root: TreeItem
var texture_delete: Texture2D = preload("res://addons/affix.idb/btn_delete.png")
var texture: Texture2D = preload("res://addons/affix.idb/btn_new.png")
var database: SQLite
	
func _enter_tree() -> void:
	database = SQLite.new()
	database.open_db()
	tree = $Tree
	root = tree.create_item()
	
	add_tree_header("Items")
	add_tree_header("Monsters")
	add_tree_header("LootTables")
	add_tree_header("TableEntries")
	add_tree_header("ItemEntries")
	
func _exit_tree() -> void:
	tree.clear()
	database.close_db()
	pass
	
func add_tree_header(title:String) -> void:
	var treeItem: TreeItem = tree.create_item(root)
	treeItem.set_text(0, title)
	treeItem.set_icon(0, texture)
	treeItem.set_text_alignment(0, HORIZONTAL_ALIGNMENT_LEFT)
	treeItem.set_custom_bg_color(0, Color(0.25, 0.26, 0.298))
	treeItem.set_custom_bg_color(1, Color(0.25, 0.26, 0.298))
	populate_table_entries(treeItem)
	treeItem.set_collapsed_recursive(true)

# this is cool but it's not scaleable, we should consider reverting back to having individual functions setting up tables
func populate_table_entries(treeItem: TreeItem) -> void:
	var category_name = treeItem.get_text(0)
	var query = "SELECT * FROM " + category_name
	database.query(query)

	for row in database.query_result:
		var ch = treeItem.create_child()
		ch.add_button(1, texture_delete)
		ch.set_text(0, str(row["id"]))
		ch.set_metadata(0, row)
		for key in row.keys():  # Loop through column names (keys)
			var field = ch.create_child()
			field.set_text(0, key)  # Set column name
			# don't allow editing for foreign key ids
			var is_id = key.ends_with("id")
			match typeof(row[key]):
				TYPE_INT:
					field.set_text(1, str(row[key]))
				TYPE_FLOAT:
					field.set_text(1, str(row[key]))
				TYPE_STRING:
					field.set_text(1, row[key])
				TYPE_BOOL:
					field.set_checked(1, row[key])
			if not is_id:
				field.set_editable(1, true)  
				field.set_custom_bg_color(1, Color(0.113, 0.133, 0.16))
	
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
	var dictionary = await popup.button_pressed
	popup.queue_free()
