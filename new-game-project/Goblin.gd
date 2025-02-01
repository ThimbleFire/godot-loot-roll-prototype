class_name Goblin

var enemy_loot_tables: Array
var table_rares
var database: SQLite

func _init(monster_name: String) -> void:	
	database = SQLite.new()
	database.open_db()
	# get monster table ID
	database.query_with_bindings("SELECT id FROM Monsters WHERE name = ?", [monster_name])
	var id: int = database.query_result.front()["id"]
	# get all loot tables belonging to monster
	database.query_with_bindings("SELECT loot_table_id FROM MonsterLootTables WHERE monster_table_id = ?", [id])
	# get all items belonging to those tables
	for table in database.query_result:
		# create a new loot table
		var unfinished_loot_table: LootTable = LootTable.new(10)
		# get all content to put in the loot table
		database.query_with_bindings("SELECT * FROM LootEntries WHERE loot_table_id = ?", [table["loot_table_id"]])
		for item in database.query_result:
			# get the item properties, specifically the name
			database.query_with_bindings("SELECT name FROM Items WHERE id = ?", [item["item_id"]])
			var item_name = database.query_result.front()
			# populate the loot table
			unfinished_loot_table.add_item(item_name["name"], item["quantity"], item["probability"])
		if not unfinished_loot_table.items.is_empty():
			# add the table to the list of drop tables
			enemy_loot_tables.push_back(unfinished_loot_table)
	database.close_db()

func roll_loot():
	var chosen_table = roll_table()
	if chosen_table:
		var item = chosen_table.roll()
		if item.name == "Rare loot table":
			return table_rares.roll()
		else: return item
	return []

func roll_table():
	var total_weight = 0.0
	var weights = []
	
	for table in enemy_loot_tables:
		var weight = 1.0 / table.rarity  # Lower rarity value = Higher weight
		weights.append(weight)
		total_weight += weight

	var roll = randf() * total_weight
	var cumulative = 0.0

	for i in range(enemy_loot_tables.size()):
		cumulative += weights[i]
		if roll < cumulative:
			return enemy_loot_tables[i]

	return null  # No table selected (very rare case)
