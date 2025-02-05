@tool
class_name MyPopup extends Window

var tree: Tree
var root: TreeItem
var header: TreeItem
var popup: PopupMenu
var option_button: OptionButton
var instanced_ui_elements = []
var live_id_data = []
var texture: Texture2D = preload("res://addons/affix.idb/btn_new.png")
signal button_pressed

func _enter_tree() -> void:
	option_button = $background/OptionButton
	option_button.clear()
	popup = $PopupMenu
	tree = $background/Panel/Tree
	Pluggy.database.query("SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'")
	for table_name in Pluggy.database.query_result:
		option_button.add_item(table_name["name"])
	_on_option_button_item_selected(0)

func _exit_tree() -> void:
	option_button.clear()

func _on_close_requested() -> void:
	option_button.clear()
	queue_free()

func _on_option_button_item_selected(index: int) -> void:
	# clear the tree
	tree.clear()

	# get the table name
	var table_name: String = option_button.get_item_text(index)
	
	# create the table tree item
	var table_tree_item = create_table_tree_item(table_name)

	# get field names belonging to that table
	Pluggy.database.query("PRAGMA table_info("+table_name+")")
	var table_field_names = Pluggy.database.query_result

	# create an empty row of fields belonging to the `table_tree_item`
	for row in table_field_names:
		# because we're adding we don't include id
		if row["name"] == "id":
			continue
		var treeItem: TreeItem = tree.create_item(table_tree_item)
		treeItem.set_text(0, row["name"])
		if row["name"].ends_with("id"):
			treeItem.set_metadata(1, {"table_name":table_name, "name":row["name"]})
		else:
			treeItem.set_editable(1, true)
		treeItem.set_custom_bg_color(1, Color(0.21, 0.21, 0.3))

func create_table_tree_item(table_name) -> TreeItem:
	root = tree.create_item()
	header = tree.create_item(root)
	header.set_text(0, table_name)
	header.set_icon(0, texture)
	header.set_text_alignment(0, HORIZONTAL_ALIGNMENT_LEFT)
	header.set_custom_bg_color(0, Color(0.25, 0.26, 0.298))
	header.set_custom_bg_color(1, Color(0.25, 0.26, 0.298))
	return header

func _on_tree_cell_selected() -> void:
	var item: TreeItem = tree.get_selected()

	# to ensure we're selecting an applicable row, check to ensure it has metadata
	if item.get_text(0) == "sprite":
		#tree.drop_mode_flags =
		
		return
	if item.get_metadata(1) == null:
		return
	popup.clear(true)

	# get the table name and field name from the selected row
	var table_name = item.get_metadata(1)["table_name"]
	var row_name = item.get_metadata(1)["name"]

	# get all the foreign keys belonging to the table.
	# EXAMPLE `{"name":"ItemEntries", "from":"Items", "to":"id"}` 
	Pluggy.database.query("PRAGMA foreign_key_list(" + table_name + ")")
	var referenced_table = ""
	# iterate through foreign keys to find the one relevant to the selected cell and store its table name
	for row in Pluggy.database.query_result:
		if row["from"] == row_name:
			referenced_table = row["table"]
			break
	
	if referenced_table != "":
		Pluggy.database.query("SELECT * FROM " + referenced_table)
		live_id_data.clear()
		for result in Pluggy.database.query_result:
			popup.add_item(result["name"])
			live_id_data.push_back(result["id"])
			
	var button_rect: Rect2i = tree.get_item_area_rect(item, 1)
	var tree_rect: Rect2i = $background/Panel.get_rect()
	popup.position = self.position + button_rect.position + tree_rect.position
	popup.popup()

func _on_popup_menu_id_pressed(id: int) -> void:
	var selected_tree_item = tree.get_selected()
	if selected_tree_item:
		selected_tree_item.set_text(1, popup.get_item_text(id)) 
		selected_tree_item.set_metadata(1, live_id_data[id])

func _on_button_pressed() -> void:
	var table_name = header.get_text(0)
	var child_count = header.get_child_count()

	# compile a database copy (the difference being this one has a number in place of an id)
	var row_data = {}
	for i in range(0, child_count):
		var item: TreeItem = header.get_child(i)
		var key = item.get_text(0)
		var value = item.get_metadata(1) if item.get_metadata(1) != null else item.get_text(1)
		row_data[key] = value
	
	Pluggy.database.insert_row(table_name, row_data)
	var last_inserted_row = Pluggy.database.last_insert_rowid
	var actual_data = { "id": last_inserted_row }

	actual_data.merge(row_data)
	button_pressed.emit({"table_name": table_name, "row_data": actual_data})

func _on_files_dropped(files: PackedStringArray) -> void:
	if files.is_empty():
		return
	
	# Get the first dropped file (assume it's an image)
	var file_path = files[0]
	if not file_path.ends_with(".png"):  # Adjust for other formats if needed
		print("Only PNG images are supported.")
		return
	
	# Ensure an item is selected in the tree
	var selected_item = tree.get_selected()
	if not selected_item:
		print("No tree item selected.")
		return
	
	var image_packed_byte_array = save_texture_to_BLOB(file_path)
	var texture: Texture2D = load_external_image(file_path)
	tree.get_selected().set_icon(1, texture)
	tree.get_selected().set_metadata(1, image_packed_byte_array)

func load_external_image(path: String) -> ImageTexture:
	var image = Image.new()
	if image.load(path) == OK:
		return ImageTexture.create_from_image(image)
	else:
		print("Failed to load image:", path)
		return null

func save_texture_to_BLOB(image_path: String) -> PackedByteArray:
	var image = Image.new()
	var err = image.load(image_path)
	if err != OK:
		print("Failed to load image:", err)
		return PackedByteArray()
	return image.save_png_to_buffer()
