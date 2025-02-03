@tool
class_name EditorController extends Control

var root: TreeItem
var treeItems: TreeItem
var treeTables: TreeItem
var treeMonsters: TreeItem
var database: SQLite
	
func _enter_tree() -> void:
	database = SQLite.new()
	database.open_db()
	root = $Tree.create_item()
	var texture:Texture = load("res://addons/affix.idb/btn_new.png")
	
	treeItems = add_tree_header("Items", texture)
	populate_table_entries(treeItems)
	
	treeMonsters = add_tree_header("Monsters", texture)
	populate_table_entries(treeMonsters)
	
	treeTables = add_tree_header("LootTables", texture)
	populate_table_entries(treeTables)
	
	var tableEntries = add_tree_header("TableEntries", texture)
	
	
func _exit_tree() -> void:
	$Tree.clear()
	database.close_db()
	pass
	
func add_tree_header(title:String, texture:Texture2D) -> TreeItem:
	var treeItem: TreeItem = $Tree.create_item(root)
	treeItem.set_text(0, title)
	treeItem.set_icon(0, texture)
	treeItem.set_text_alignment(0, HORIZONTAL_ALIGNMENT_LEFT)
	treeItem.set_custom_bg_color(0, Color(0.25, 0.26, 0.298))
	return treeItem

func populate_table_entries(treeItem: TreeItem) -> void:
	var category_name = treeItem.get_text(0)
	var query = "SELECT * FROM " + category_name
	database.query(query)    
	print("Rows found:", database.query_result.size())
	for row in database.query_result:
		for key in row.keys():  # Loop through column names (keys)
			var field = treeItem.create_child()

			field.set_text(0, key)  # Set column name

			field.set_editable(1, true)  
			field.set_custom_bg_color(1, Color(0.113, 0.133, 0.16))
			match typeof(row[key]):
				TYPE_INT:
					field.set_range(1, row[key])
					field.set_range_config(1, 0, 255, 1) 
				TYPE_FLOAT:
					field.set_range(1, row[key])
					field.set_range_config(1, 0, 255, 0.01) 
				TYPE_STRING:
					field.set_text(1, row[key])

# below are signals belonging to Tree. Trying to figure out how to invoke a response when a row's column is changed so we can instruct the database to update.

func check_propagated_to_item(item: TreeItem, column: int) -> void:
	pass

func custom_item_clicked(mouse_button_index: int) -> void:
	# Emitted when an item with TreeItem.CELL_MODE_CUSTOM is clicked with a mouse button.
	pass

func item_edited() -> void:
	pass

func item_selected() -> void:
	pass

func cell_selected() -> void:
	pass
