![image](https://i.imgur.com/TTpKgMs.png)

We declare Goblin in-game. We start by getting its id.<br>
`database.query_with_bindings("SELECT id FROM Monsters WHERE name = ?", [monster_name])`

**Monsters**

|id|name
|:-:|:-:|
|1|Goblin|

We get all loot tables belonging to the monster with that id.<br>
`database.query_with_bindings("SELECT loot_table_id FROM MonsterLootTables WHERE monster_table_id = ?", [id])`

**MonsterLootTables**

|id|monster_table_id|loot_table_id|
|:-:|:-:|:-:|
|1|	1|	1|
|2|	1|	2|
|3|	1|	3|

For each monster loot table tied to that id we get all loot entries belonging to that table<br>
`database.query_with_bindings("SELECT * FROM LootEntries WHERE loot_table_id = ?", [table["loot_table_id"]])`

**LootEntries**

|id|loot_table_id|item_id|probability|quantity|
|:-:|:-:|:-:|:-:|:-:|
|1|	3|	1|	1.0|	1|
|2|	3|	1|	5.0|	5|
|3|	3|	1|	9.0|	9|
|4|	3|	1|	15.0|	15|
|5|	3|	1|	25.0|	25|
|6|	2|	5|	12.0|	12|
|7|	2|	6|	9.0|	9|
|8|	1|	2|	12.0|	1|
|9|	1|	3|	12.0|	1|
|10|1|	4|	12.0|	1|

For each item in the table being iterated, we get the item name.<br>
`database.query_with_bindings("SELECT name FROM Items WHERE id = ?", [item["item_id"]])`

**Items**

|id|name|
|:-:|:----:|
| 1 |	Coin |
| 2 |	Bronze Sword |
| 3 |	Bronze Shield |
| 4 |	Bronze Spear |
| 5 |	Bronze Bolt |
| 6 |	Bronze Arrow |
| 7 |	Goblin Sword |
| 8 |	Oak Log |
| 9 |	Knife |
| 10 | Bronze Axe |
| 11 | Tinderbox |

