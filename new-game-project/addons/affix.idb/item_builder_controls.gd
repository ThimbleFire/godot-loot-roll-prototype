@tool
extends Panel

var database: SQLite

func _enter_tree() -> void:
	database = SQLite.new()
	database.open_db()
	
func _exit_tree() -> void:
	database.close_db()
	
	
