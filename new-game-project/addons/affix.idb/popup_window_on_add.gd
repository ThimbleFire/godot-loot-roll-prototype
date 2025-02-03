@tool
class_name MyPopup extends Window

var database: SQLite
signal button_pressed
	
func _enter_tree() -> void:
	database = SQLite.new()
	database.open_db()
	database.query("SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'")
	for table_name in database.query_result:
		$background/OptionButton.add_item(table_name["name"])
	
func _exit_tree() -> void:
	database.close_db()
	
func _on_close_requested() -> void:
	queue_free()

func _on_option_button_item_selected(index: int) -> void:
	pass
	
func _on_button_pressed() -> void:
	button_pressed.emit()
