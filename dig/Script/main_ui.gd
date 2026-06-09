extends Control
signal on_upgrade_tree
signal off_upgrade_tree
var isOpenUpgradeTree = false

	
func _ready():
	$RichTextLabel.text = "[img=35x35]res://img/gold.png[/img]   "
	$RichTextLabel.add_text(str(Globals.money) + "\n")
	if Globals.old_log > 0:
		$RichTextLabel.add_image(ItemManager.get_item("old_log").icon,35,35)
		$RichTextLabel.add_text("   " + str(Globals.old_log))
		
func _on_button_pressed() -> void:
	if not isOpenUpgradeTree:
		isOpenUpgradeTree = true
		$TextureRect.visible = false
		emit_signal("on_upgrade_tree")
		
	elif isOpenUpgradeTree:
		isOpenUpgradeTree = false
		emit_signal("off_upgrade_tree")

func refresh():
	$RichTextLabel.text = ""
	$RichTextLabel.text = "[img=35x35]res://img/gold.png[/img]   "
	$RichTextLabel.add_text(str(Globals.money) + "\n")
	if Globals.old_log > 0:
		$RichTextLabel.add_image(ItemManager.get_item("old_log").icon,35,35)
		$RichTextLabel.add_text("   " + str(Globals.old_log))
