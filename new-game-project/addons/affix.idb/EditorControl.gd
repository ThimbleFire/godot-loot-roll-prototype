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
	
	add_tree_header("Items", texture)	
	add_tree_header("Monsters", texture)	
	add_tree_header("LootTables", texture)	
	add_tree_header("TableEntries", texture)
	add_tree_header("ItemEntries", texture)
	
	
func _exit_tree() -> void:
	$Tree.clear()
	database.close_db()
	pass
	
func add_tree_header(title:String, texture:Texture2D) -> void:
	var treeItem: TreeItem = $Tree.create_item(root)
	treeItem.set_text(0, title)
	treeItem.set_icon(0, texture)
	treeItem.set_text_alignment(0, HORIZONTAL_ALIGNMENT_LEFT)
	treeItem.set_custom_bg_color(0, Color(0.25, 0.26, 0.298))
	populate_table_entries(treeItem)

# this is cool but it's not scaleable, we should consider reverting back to having individual functions setting up tables
func populate_table_entries(treeItem: TreeItem) -> void:
	var category_name = treeItem.get_text(0)
	var query = "SELECT * FROM " + category_name
	database.query(query)    
	print("Rows found:", database.query_result.size())

	for row in database.query_result:
		var ch = treeItem.create_child()

		for key in row.keys():  # Loop through column names (keys)
			var field = ch.create_child()
			field.set_text(0, key)  # Set column name

			# don't allow editing for foreign key ids
			var is_id = key.ends_with("id")

			match typeof(row[key]):
				TYPE_INT, TYPE_FLOAT:
					field.set_range(1, row[key])
					field.set_range_config(1, 0, 255, 1) 
				TYPE_STRING:
					field.set_text(1, row[key])
				TYPE_BOOL:
					field.set_checked(1, row[key])

			if not is_id:
				field.set_editable(1, true)  
				field.set_custom_bg_color(1, Color(0.113, 0.133, 0.16))


func item_edited() -> void:
	var treeItem: TreeItem = $Tree.get_edited()
	var row_item = treeItem.get_parent()
	var table_name row_item.get_parent().get_text(0)
	print(table_name)

	
