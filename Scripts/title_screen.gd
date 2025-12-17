extends Control

# --- 节点引用 ---
@onready var credits_panel = $CreditsPanel
# 如果加了背景音乐节点，把下面这行注释取消
# @onready var bgm = $BGM_Player 

func _ready():
	# 确保一开始弹窗是关的
	credits_panel.visible = false
	# if bgm: bgm.play()

# --- 1. 点击“开始”按钮 ---
func _on_start_button_pressed():
	print("开始游戏，跳转场景...")
	# 【关键】这里填写你之前做好的开场场景的路径
	get_tree().change_scene_to_file("res://Scenes/intro_scene.tscn")

# --- 2. 点击“制作人员”按钮 ---
func _on_credits_button_pressed():
	credits_panel.visible = true

# --- 3. 点击“关闭”制作人员 ---
func _on_close_credits_pressed():
	credits_panel.visible = false
