extends Control

# --- 节点引用 ---
@onready var bg = $Background
@onready var subtitle = $CanvasLayer/SubtitleLabel

# UI
@onready var yanweng_img = $CanvasLayer/YanwengImg
@onready var collect_btn = $CanvasLayer/CollectButton
@onready var collect_btn2 = $CanvasLayer/CollectButton2
@onready var next_scene_btn = $CanvasLayer/NextSceneBtn

# 光点与物品
@onready var lights_group = $LightsGroup
@onready var left_light = $LightsGroup/LeftLight
@onready var right_light = $LightsGroup/RightLight

@onready var items_group = $ItemsGroup
@onready var item_pipa = $ItemsGroup/ItemPipa
@onready var item_conch = $ItemsGroup/ItemConch

# 音频
@onready var sfx_pipa = $SFX_Pipa
@onready var sfx_pipa2 = $SFX_Pipa2
@onready var sfx_conch = $SFX_Conch
@onready var bgm = $BGM

# --- 状态记录 ---
var current_item_type = "" 

# --- 信号 ---
signal user_clicked
signal phase_completed

func _ready():
	# 初始化：隐藏所有交互元素
	lights_group.visible = false
	left_light.visible = false
	right_light.visible = false
	items_group.visible = false
	collect_btn.visible = false
	collect_btn2.visible = false
	next_scene_btn.visible = false
	yanweng_img.visible = false
	
	bgm.play()
	
	# 开始线性流程
	play_full_flow()

# --- 输入检测 ---
func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if collect_btn.visible or next_scene_btn.visible:
			return
		user_clicked.emit()

# --- 辅助函数：显示字幕并等待 ---
func say_and_wait(text: String):
	subtitle.text = text
	await get_tree().create_timer(0.1).timeout
	await user_clicked

# --- 辅助函数：背景切换 ---
func switch_background_with_fade(new_texture_path: String):
	var tween_out = create_tween()
	tween_out.tween_property(bg, "modulate:a", 0.0, 0.5) # 0.5秒淡出
	await tween_out.finished
	bg.texture = load(new_texture_path)
	var tween_in = create_tween()
	tween_in.tween_property(bg, "modulate:a", 1.0, 0.5) # 0.5秒淡入
	await tween_in.finished

# ==========================================
#           核心流程控制 (主逻辑)
# ==========================================
func play_full_flow():
	# --- 1. 开场剧情 ---
	bg.texture = load("res://Assets/Images/background/6.1.jpg")
	yanweng_img.visible = true
	await say_and_wait("（点击继续...）")
	
	# 乐姬介绍
	yanweng_img.visible = false
	await switch_background_with_fade("res://Assets/Images/background/feitian_pipa.jpg")
	await say_and_wait("乐姬：我是天宫的乐伎。昔日我手持【曲项琵琶】，奏响胡汉之音。\n如今琴身失落，我也失去了色彩。")
	await say_and_wait("请帮我找回【曲项琵琶】，让音乐窟重新焕发生机。")
	# 僧人介绍
	await switch_background_with_fade("res://Assets/Images/background/feitian_faluo.jpg")
	await say_and_wait("僧人：贫僧守护此窟千年。那枚定调的【法螺】不知遗落在何处。")
	await say_and_wait("僧人：没有法螺的洪音，交响便失去了根基。施主，请务必帮我寻回。")
	
	# 回到主场景
	await switch_background_with_fade("res://Assets/Images/background/6.1.jpg")
	yanweng_img.visible = true
	
	# --- 2. 寻找琵琶阶段 ---
	await start_pipa_phase()
	await phase_completed 
	
	# --- 3. 寻找法螺阶段 ---
	await start_conch_phase()
	await phase_completed
	# --- 4. 结束 ---
	finish_scene()

# ==========================================
#           琵琶阶段逻辑
# ==========================================
func start_pipa_phase():
	# 播放引导
	sfx_pipa.play()
	print("start start_pipa_phase()\n")
	await say_and_wait("岩翁：听，左侧传来了急促的弹拨声。点亮光芒，找到它。")
	
	# 显示左侧光点
	lights_group.visible = true
	left_light.visible = true
	right_light.visible = false # 确保右边不显示
	
	# 等待玩家操作(此时逻辑交给 _on_left_light_pressed)
	# 我们需要在这里“暂停”，直到琵琶被归还
	# 技巧：我们等待一个自定义信号，或者简单地利用 await user_clicked 配合状态机
	# 但为了简单，我们让主流程在这里断开，通过函数调用链继续

# 点击左侧光点 (不切背景，直接出图)
func _on_left_light_pressed():
	#if current_item_type != "": return # 防止重复点
	
	current_item_type = "pipa"
	left_light.visible = false # 隐藏光点
	sfx_pipa.play()
	
	# 显示物品和按钮 (在当前背景上)
	items_group.visible = true
	item_pipa.visible = true
	item_conch.visible = false
	
	collect_btn.visible = true
	collect_btn.text = "收录意象"
	
	subtitle.text = "发现【曲项琵琶】"

# ==========================================
#           法螺阶段逻辑
# ==========================================
func start_conch_phase():
	current_item_type = "" # 重置状态
	yanweng_img.visible = true
	
	sfx_conch.play()
	await say_and_wait("岩翁：右侧传来了嘹亮的声响。去看看吧。")
	
	lights_group.visible = true
	right_light.visible = true
	left_light.visible = false
	current_item_type = "pipa"
	
# 点击右侧光点
func _on_right_light_pressed():
	
	current_item_type = "conch"
	right_light.visible = false
	sfx_conch.play()
	
	items_group.visible = true
	item_conch.visible = true
	item_pipa.visible = false
	
	collect_btn2.visible = true
	collect_btn2.text = "收录意象"
	
	subtitle.text = "发现【法螺】"

# ==========================================
#        通用：点击收录(归还)按钮
# ==========================================
func _on_collect_button_pressed():
	# 隐藏物品
	items_group.visible = false
	collect_btn.visible = false
	yanweng_img.visible = false
	
	# 1. 切换背景给乐姬
	await switch_background_with_fade("res://Assets/Images/background/feitian_pipa.jpg")
	sfx_pipa2.play()
	await say_and_wait("乐姬：琵琶已归位。多谢入画者，盛唐之音将再次回荡。")
	
	# 2. 切回主场景，准备找下一个
	await switch_background_with_fade("res://Assets/Images/background/6.1.jpg")
	
	# 3. 触发下一阶段
	await start_conch_phase()



func _on_collect_button2_pressed():
	# 隐藏物品
	items_group.visible = false
	collect_btn2.visible = false
	yanweng_img.visible = false

	# 1. 切换背景给僧人
	await switch_background_with_fade("res://Assets/Images/background/feitian_faluo.jpg")

	await say_and_wait("僧人：善哉。法螺归位，众生皆闻。")
	
	# 2. 切回主场景，准备结束
	await switch_background_with_fade("res://Assets/Images/background/6.1.jpg")
	
	# 3. 触发结束
	finish_scene()
		
# ==========================================
#           结束逻辑
# ==========================================
func finish_scene():
	yanweng_img.visible = true
	subtitle.text = "岩翁：乐章已完整，天宫即将苏醒..."
	next_scene_btn.visible = true

func _on_next_scene_btn_pressed():
	get_tree().change_scene_to_file("res://Scenes/feitian_scene.tscn")
