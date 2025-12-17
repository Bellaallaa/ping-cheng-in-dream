extends Control

# --- 1. 获取核心节点 ---
@onready var background = $Background
@onready var character = $Character
@onready var dialog_box = $DialogBox
@onready var name_label = $DialogBox/NameLabel
@onready var content_label = $DialogBox/ContentLabel

# 交互按钮 & 弹窗
@onready var pillar_btn = $PillarButton 
@onready var collection_popup = $CollectionPopup
@onready var item_image = $CollectionPopup/ItemImage 
@onready var item_desc = $CollectionPopup/ItemDesc
@onready var confirm_btn = $CollectionPopup/ConfirmButton
@onready var end_title = $EndTitle 
@onready var next_button=$NextButton
# --- 2. 剧本数据  ---
var script_data = [
	# 0. 林音开场
	{
		"type": "text", 
		"name": "林音", 
		"text": "  这就是第12窟……被称为‘音乐窟’的地方。但在书本之外，它竟然如此寂静，像一位失语的老人。",
		"char": null,
		"bg": "res://Assets/Images/background/bg_scene1.jpg" # 最开始的全景图
	},
	# 1. 岩翁出场
	{
		"type": "text", 
		"name": "岩翁", 
		"text": "  孩子，别只盯着地面。云冈的魂魄，往往藏在你抬头才能看见的地方。",
		"char": "res://Assets/Images/ui/RockOldMan.png"
	},
	# 2. 岩翁提示 (切换：拱门全景)
	{
		"type": "text", 
		"name": "岩翁", 
		"text": "  看那窟门上方的拱楣……众神飞舞之间，有两条神兽正首尾相交，锁住了这满窟的繁华。",
		"char": "res://Assets/Images/ui/RockOldMan.png",
		# 这里切换成【拱门全景】
		"bg": "res://Assets/Images/background/jiaolong_wide.png" 
	},
	# 3. 等待交互 (寻找交龙)
	{
		"type": "wait_click_pillar"
	},
	
	# --- 弹窗关闭后的剧情 ---
	
	# 4. 岩翁解说 (背景定格在交龙细节)
	{
		"type": "text", 
		"name": "岩翁", 
		"text": "  这是汉家的龙，却有着草原的野性。它们不再是僵硬的符号，而是如同云气一般流动、缠绕。",
		"char": "res://Assets/Images/ui/RockOldMan.png"
	},
	# 5. 升华
	{
		"type": "text", 
		"name": "岩翁", 
		"text": "  这一缠，便缠住了汉风与胡韵。骨架虽成，但若无‘气韵’，这殿堂终究只是死寂的石头。",
		"char": "res://Assets/Images/ui/RockOldMan.png"
	},
	# 6. 结束
	{
		"type": "end_screen",  
		"text": "（第一幕 · 寻找骨骼 完成）",
		"bg": "res://Assets/Images/background/zhuzi.jpg"
	}
]

var current_index = 0
var is_waiting_click = false

func _ready():
	# 初始化
	pillar_btn.visible = false
	collection_popup.visible = false
	
	if not confirm_btn.pressed.is_connected(_on_confirm_button_pressed):
		confirm_btn.pressed.connect(_on_confirm_button_pressed)
	
	show_line()

func _input(event):
	if is_waiting_click or collection_popup.visible:
		return
	if event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		next_line()

func next_line():
	current_index += 1
	if current_index < script_data.size():
		show_line()
	else:
		print("本章结束")

# --- 核心逻辑 ---
func show_line():
	var data = script_data[current_index]
	
	# 背景切换逻辑
	if data.has("bg") and data["bg"] != null:
		if current_index == 0:
			background.texture = load(data["bg"])
			background.modulate.a = 1.0
		elif background.texture == null or background.texture.resource_path != data["bg"]:
			change_background_smooth(data["bg"])
	
	if data["type"] == "text":
		dialog_box.visible = true
		pillar_btn.visible = false
		name_label.text = data["name"]
		content_label.text = data["text"]
		if data["char"]:
			character.texture = load(data["char"])
			character.visible = true
		else:
			character.visible = false
			
	elif data["type"] == "wait_click_pillar":
		dialog_box.visible = false
		is_waiting_click = true
		pillar_btn.visible = true
		# 闪烁提示
		var tween = create_tween().set_loops()
		tween.tween_property(pillar_btn, "modulate:a", 0.5, 0.8)
		tween.tween_property(pillar_btn, "modulate:a", 1.0, 0.8)
	elif data["type"] == "end_screen":
		# [落幕模式]
		# 1. 隐藏所有旧UI
		dialog_box.visible = false
		character.visible = false
		pillar_btn.visible = false
		
		# 2. 设置并显示居中标题
		end_title.text = data["text"]
		end_title.visible = true
		next_button.visible=true
# --- 柔和切换背景函数 ---
func change_background_smooth(image_path):
	var tween = create_tween()
	tween.tween_property(background, "modulate:a", 0.0, 0.5)
	tween.tween_callback(func(): background.texture = load(image_path))
	tween.tween_property(background, "modulate:a", 1.0, 0.5)


func _on_pillar_button_pressed():
	is_waiting_click = false
	pillar_btn.visible = false
	collection_popup.visible = true
	
	# --- 1. 设置弹窗里的大图 (交龙细节) ---
	if item_image:
		item_image.texture = load("res://Assets/Images/background/jiaolong_detail.jpg")
	
	# --- 2. 科普文案 (交龙纹) ---
	item_desc.text = "      【意象 · 门楣交龙纹】\n\n" + \
	"位置：第12窟前室拱门门楣\n" + \
	"  双龙首尾相交，龙身呈波状起伏，穿插缠绕。不同于秦汉的粗犷，这里的龙线条柔韧流畅，如同云气盘旋。\n" + \
	"  这是北魏鲜卑族吸收汉文化后，将草原的生命力融入汉式威严的独特创造。"

func _on_confirm_button_pressed():
	collection_popup.visible = false
	
	# --- 3. 收录完成后，背景直接切换成高清细节图 ---
	var detail_bg_path = "res://Assets/Images/background/jiaolong_detail.jpg"
	change_background_smooth(detail_bg_path)
	
	next_line()

func _on_next_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/ceiling_scene.tscn")
	
