@tool
class_name Pluggy extends EditorPlugin

var idb_dock
var imt_dock
var controller: EditorController
static var database: SQLite

func _enter_tree():
	#add_custom_type("EditorControl", "TabContainer", preload("res://addons/affix.idb/EditorControl.gd"), preload("res://icon.svg"))
	#add_custom_type("MapEditor", "Control",  preload("res://addons/affix.idb/MapEditor.gd"), preload("res://icon.svg"))

	idb_dock  = preload("res://addons/affix.idb/editor_idb.tscn").instantiate()
	imt_dock = preload("res://addons/affix.idb/editor_imt.tscn").instantiate()

	add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_UL, idb_dock)
	add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_UL, imt_dock)

func _exit_tree():
	#remove_custom_type("EditorControl")
	#remove_custom_type("MapEditor")

	remove_control_from_docks(idb_dock)
	remove_control_from_docks(imt_dock)

	idb_dock.free()
	imt_dock.free()
