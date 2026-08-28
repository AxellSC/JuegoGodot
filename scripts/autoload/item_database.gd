## Global item registry (Autoload singleton: "ItemDatabase").
##
## On startup, recursively scans [member ITEMS_PATH] and loads every
## [code].tres[/code]/[code].res[/code] resource that is an [Item],
## indexing it by its [member Item.id]. Any script can then fetch an
## item definition by id via [method get_item], without needing a
## direct reference to the resource file.
extends Node

## Folder scanned (recursively) for [Item] resources on startup.
const ITEMS_PATH := "res://data/items/"

## Maps [StringName] item id -> loaded [Item] resource.
var items: Dictionary = {}

func _ready() -> void:
	_load_items_from_folder(ITEMS_PATH)
	
## Recursively loads and registers every [Item] resource found under
## [param path], including subfolders.
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

## Registers [param item] under its [member Item.id]. Warns (without
## failing) if the item has no id, or if the id is already taken by
## another registered item.
func register_item(item: Item) -> void:
	if item.id == &"":
		push_warning("ItemDatabase: item with no id at %s, not registered" % item.resource_path)
		return
	if items.has(item.id):
		push_warning("ItemDatabase: duplicate id '%s' (%s)" % [item.id, item.resource_path])
	items[item.id] = item

## Returns the registered [Item] with the given [param id], or
## [code]null[/code] (with a warning) if no item is registered under
## that id.
func get_item(id: StringName) -> Item:
	if items.has(id):
		return items[id]
	push_warning("ItemDatabase: item not found with id '%s'" % id)
	return null

## Returns [code]true[/code] if an item with [param id] is registered.
func has_item(id: StringName) -> bool:
	return items.has(id)

## Returns every registered [Item] resource, in no particular order.
func get_all() -> Array:
	return items.values()
