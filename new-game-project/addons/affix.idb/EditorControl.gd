@tool
class_name EditorController extends Control

enum FieldType {
	TEXT,
	ID,
	FOREIGN_KEY,
	SPRITE }

var tree: Tree
var root: TreeItem
var table_names = []

func _exit_tree() -> void:
	Pluggy.database.close_db()
	tree.clear()
	pass

func _enter_tree() -> void:
	Pluggy.database = SQLite.new()
	Pluggy.database.open_db()
	tree = $Tree
	populate_database_view()
	
func populate_database_view() -> void:
	tree.clear()
	root = tree.create_item()
	
	Pluggy.database.query("SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'")
	for table_name in Pluggy.database.query_result:
		table_names.push_back(table_name["name"])
		build_table(table_name["name"])
	
func build_table(table_name:String) -> void:
	var table_item: TreeItem = tree.create_item(root)
	table_item.set_text(0, table_name)
	table_item.set_text_alignment(0, HORIZONTAL_ALIGNMENT_LEFT)
	table_item.set_custom_bg_color(0, Color(0.25, 0.26, 0.298))
	table_item.set_custom_bg_color(1, Color(0.25, 0.26, 0.298))
	Pluggy.database.query("SELECT * FROM " + table_name)
	if Pluggy.database.query_result.is_empty():
		return
	for row_data in Pluggy.database.query_result:
		add_row(table_item, row_data)
	var keys = Pluggy.database.query_result.front()
	keys = keys.keys()
	table_item.set_metadata(0, keys)
	table_item.set_collapsed_recursive(true)

func add_row(table_item: TreeItem, row_data: Dictionary) -> void:
	var table_name = table_item.get_text(0)
	var row:TreeItem = table_item.create_child()
	row.add_button(1, preload("res://addons/affix.idb/btn_delete.png"))
	row.set_text(0, str(row_data["id"]))
	row.set_metadata(0, row_data)
	for key in row_data.keys():
		var field = row.create_child()
		field.set_text(0, key)
		var field_type: FieldType = FieldType.ID if key == "id" else FieldType.FOREIGN_KEY if key.ends_with("id") else FieldType.SPRITE if key.ends_with("sprite") else FieldType.TEXT

		match field_type:
			FieldType.ID:
				field.set_text(1, str(row_data["id"]))
			FieldType.FOREIGN_KEY:
				Pluggy.database.query("PRAGMA foreign_key_list(" + table_name + ")")
				for fk in Pluggy.database.query_result:
					if fk["from"] == key:
						Pluggy.database.query_with_bindings("SELECT name FROM " + fk["table"] + " WHERE id = ?", [row_data[key]])
						print(Pluggy.database.query_result)
						var id_display_name: String = Pluggy.database.query_result.front()["name"]
						field.set_text(1, id_display_name)
						field.set_metadata(1, row_data[key])
						field.set_tooltip_text(1, "id: " + str(row_data[key]))
						field.set_icon(1, preload("res://addons/affix.idb/ico_key.png"))
			FieldType.SPRITE:
				if row_data[key] != null:
					pass
					#field.set_icon(1, BLOB_to_texture(row_data[key]))
			FieldType.TEXT:
				field.set_editable(1, true)
				field.set_custom_bg_color(1, Color(0.21, 0.21, 0.3))
				field.set_text(1, str(row_data[key]))

func BLOB_to_texture(pba: PackedByteArray) -> ImageTexture:
	var image = Image.new()
	if image.load_png_from_buffer(pba) == OK:
		return ImageTexture.create_from_image(image)
	else:
		print("Failed  to load image from byte array")
		return null
	
func item_edited() -> void:
	var treeItem: TreeItem = tree.get_edited()
	var dictionary = treeItem.get_parent().get_metadata(0)
	var table_name = treeItem.get_parent().get_parent().get_text(0)
	dictionary[treeItem.get_text(0)] = str(treeItem.get_text(1))
	Pluggy.database.update_rows(table_name, "id = " + str(dictionary["id"]), dictionary)

func _on_tree_button_clicked(item: TreeItem, column: int, id: int, mouse_button_index: int) -> void:
	Pluggy.database.foreign_keys = true
	Pluggy.database.query("PRAGMA foreign_keys = ON;")
	var table_name = item.get_parent().get_text(0)
	# loop through all the tables
	for table in table_names:
		# get the tables foreign key list
		Pluggy.database.query("PRAGMA foreign_key_list("+table+")")
		# for each foreign key
		for foreign_key in Pluggy.database.query_result:
			# if that key is used by this table
			if table_name == foreign_key["table"]:
				# get the table
				var table_with_foreign_keys: TreeItem = get_tree_table_by_table_name(table)
				# for each child of the table
				for row in table_with_foreign_keys.get_children():
					# if the child's foreign key value is equal to the key being deleted
					var table_column_name = row.get_metadata(0)[foreign_key["from"]]
					var table_column_value = item.get_metadata(0)["id"]
					if table_column_name == table_column_value:
						table_with_foreign_keys.remove_child(row)
	Pluggy.database.query_with_bindings("DELETE FROM " + table_name + " WHERE id = ?", [str(item.get_metadata(0)["id"])])
	item.get_parent().remove_child(item)

func _on_btn_add_pressed() -> void:
	var popup:MyPopup = preload("res://addons/affix.idb/popup_window_on_add.tscn").instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
	add_child(popup)
	var content = await popup.button_pressed
	popup.queue_free()	
	var table_item = get_tree_table_by_table_name(content["table_name"])
	add_row(table_item, content["row_data"])
	
func get_tree_table_by_table_name(name) -> TreeItem:
	var index = table_names.find(name)
	return root.get_child(index)
