@tool
extends EditorPlugin
var dock

var controller: EditorController

func _enter_tree():
	add_custom_type("EditorControl", "TabContainer", preload("res://addons/affix.idb/EditorControl.gd"), preload("res://icon.svg"))
	dock  = preload("res://addons/affix.idb/editor_test.tscn").instantiate()
	add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_UL, dock)

func _exit_tree():
	remove_custom_type("EditorControl")
	remove_control_from_docks(dock)
	dock.free()
