extends Control

func _ready():
	if Globals.old_log > 0:
		$RichTextLabel.add_image(ItemManager.get_item("old_log").icon)
		$RichTextLabel.add_text(" = " + str(Globals.old_log))
