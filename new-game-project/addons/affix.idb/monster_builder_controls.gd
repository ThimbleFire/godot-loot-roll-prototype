@tool
extends Panel

var database: SQLite

func _enter_tree() -> void:
	database = SQLite.new()
	database.open_db()
	
func _exit_tree() -> void:
	database.close_db()

func _on_txt_monster_name_text_changed(new_text: String) -> void:
	# query all names to see if the monster already exists
	database.query_with_bindings("SELECT id FROM Monsters WHERE name = ?", [new_text])
	$Button.disabled = true
	# if the monster doesn't already exist
	if database.query_result.is_empty():
		# the button can be pressed
		$Button.disabled = false
	if new_text == "":
		$Button.disabled = true
	
func _on_button_pressed() -> void:
	var dict = { "name": $txtMonsterName.text }
	database.insert_row("Monsters", dict)
	$txtMonsterName.text = ""
	
func _on_txt_monster_search_text_changed(new_text: String) -> void:
	var option_button = $OptionButton
	database.query_with_bindings("SELECT * FROM Monsters WHERE name LIKE ?", ["%"+new_text+"%"])
	for monster_name in database.query_result:
		option_button.add_item(monster_name["name"])

func _on_button_2_pressed() -> void:
	var option_button: OptionButton = $OptionButton
	if option_button.selected == -1:
		print("No monster selected")
		return
	var selected_name: String = option_button.get_item_text(option_button.selected)
	database.query_with_bindings("SELECT id FROM Monsters WHERE name = ?", [selected_name])
	var id: int = database.query_result.front()["id"]
	database.query_with_bindings("DELETE FROM Monsters WHERE id = ?", [id])
	database.query_with_bindings("DELETE FROM TableEntries WHERE monster_table_id = ?", [id])
	option_button.clear()
	$"../Set Monster Drop Tables/VBoxContainer2/txtAddLootTableSearch".clear()
	print("Monster deleted")
