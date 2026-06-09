extends Node
#전역 변수 저장

var stage_num:int = 1
var money:int = 0
var return_play:bool = false
var open_muse= 0
var box_size:int = 3
var old_log:int = 0
var income:int = 1
var level=0
var stage_clr = {
	"stage1":false,
	"stage2":false,
	"stage3":false
}
var unlocked_stage:int = 1
var item_list:Dictionary = {
		"stage1_item":0,
		"stage2_item":0
}
	
