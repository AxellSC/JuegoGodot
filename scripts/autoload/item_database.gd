extends Node

const ITEMS_PATH := "res://data/items/"

var items: Dictionary = {}

func _ready() -> void:
	_load_items_from_folder(ITEMS_PATH)
	
func _load_items_from_folder(path: String) -> void:
	var dir := DirAccess.open(path)
	if dir == null:
		push_warning("ItemDatabase: folder not found %s" % path)
		return

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		var full_path := path.path_join(file_name)
		if dir.current_is_dir():
			if not file_name.begins_with("."):
				_load_items_from_folder(full_path)
		elif file_name.ends_with(".tres") or file_name.ends_with(".res"):
			var resource: Resource = load(full_path)
			if resource is Item:
				register_item(resource)
			else:
				push_warning("ItemDatabase: %s is not an Item, skipping" % full_path)
		file_name = dir.get_next()
	dir.list_dir_end()

func register_item(item: Item) -> void:
	if item.id == &"":
		push_warning("ItemDatabase: item with no id at %s, not registered" % item.resource_path)
		return
	if items.has(item.id):
		push_warning("ItemDatabase: duplicate id '%s' (%s)" % [item.id, item.resource_path])
	items[item.id] = item


func get_item(id: StringName) -> Item:
	if items.has(id):
		return items[id]
	push_warning("ItemDatabase: item not found with id '%s'" % id)
	return null


func has_item(id: StringName) -> bool:
	return items.has(id)


func get_all() -> Array:
	return items.values()
