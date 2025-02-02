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
	populate_items(treeItems)
	
	treeMonsters = add_tree_header("Monsters", texture)
	#populate_category(treeMonsters)
	
	treeTables = add_tree_header("Tables", texture)
	#populate_category(treeTables)
	
func _exit_tree() -> void:
	database.close_db()
	pass
	
func add_tree_header(title:String, texture:Texture2D) -> TreeItem:
	var treeItem: TreeItem = $Tree.create_item(root)
	treeItem.set_text(0, title)
	treeItem.set_icon(0, texture)
	treeItem.set_text_alignment(0, HORIZONTAL_ALIGNMENT_LEFT)
	treeItem.set_custom_bg_color(0, Color(0.25, 0.26, 0.298))
	return treeItem

func populate_items(treeItem: TreeItem) -> void:
	var category_name = treeItem.get_text(0)
	
	database.query("SELECT * FROM Items")
	
	for row in database.query_result:
		var ch = treeItems.create_child()
		ch.set_text(0, "id")
		ch.set_text(1, str(row["id"]))
		
		ch = treeItem.create_child()
		ch.set_text(0, "name")
		ch.set_text(1, row["name"])
		ch.set_editable(1, true)

		
