extends Control
# ==========================================
# 1. 节点引用
# ==========================================
# --- 场景基础 ---
@onready var bg = $Background
@onready var subtitle = $CanvasLayer/SubtitleLabel
@onready var yanweng_img = $CanvasLayer/YanwengImg

# --- 探索阶段 UI ---
@onready var collect_btn = $CanvasLayer/CollectButton
@onready var collect_btn2 = $CanvasLayer/CollectButton2
@onready var lights_group = $LightsGroup
@onready var left_light = $LightsGroup/LeftLight
@onready var right_light = $LightsGroup/RightLight
@onready var items_group = $ItemsGroup
@onready var item_pipa = $ItemsGroup/ItemPipa
@onready var item_conch = $ItemsGroup/ItemConch

# --- 音频 ---
@onready var sfx_pipa = $SFX_Pipa
@onready var sfx_pipa2 = $SFX_Pipa2
@onready var sfx_conch = $SFX_Conch
@onready var bgm = $BGM

# --- 【修复阶段节点】(根据你的截图和需求) ---
@onready var restoration_ui = $RestorationUI
@onready var backpack = $RestorationUI/Backpack
@onready var pack_pipa = $RestorationUI/Backpack/PackPipa # 请确保背包里有这个节点
@onready var pack_conch = $RestorationUI/Backpack/PackConch # 请确保背包里有这个节点

# 乐姬房间
@onready var pipa_room = $RestorationUI/PipaRoom
@onready var leji_img = $RestorationUI/PipaRoom/LejiFullImg
@onready var target_pipa = $RestorationUI/PipaRoom/LejiFullImg/TargetPipa
@onready var back_btn_pipa = $RestorationUI/PipaRoom/BackBtn
@onready var bag_btn_pipa = $RestorationUI/PipaRoom/BagBtn # ★新加的按钮

# 法螺房间
@onready var conch_room = $RestorationUI/ConchRoom
@onready var faluo_img = $RestorationUI/ConchRoom/FaluoFullImg
@onready var target_conch = $RestorationUI/ConchRoom/FaluoFullImg/TargetConch
# @onready var back_btn_conch = ... (法螺修完直接结束，可以不需要返回按钮)
@onready var bag_btn_conch = $RestorationUI/ConchRoom/BagBtn # ★新加的按钮

# ==========================================
# 2. 状态变量
# ==========================================
var current_item_type = "" 
var is_all_finished = false
var is_repair_phase = false # 是否进入了修复阶段

# 拖拽相关
var dragging_item = null
var original_pos = Vector2.ZERO

# 信号
signal user_clicked

func _ready():
	# --- 初始化显示状态 ---
	lights_group.visible = false
	items_group.visible = false
	collect_btn.visible = false
	collect_btn2.visible = false
	yanweng_img.visible = false
	
	# 隐藏修复相关 UI
	restoration_ui.visible = false # 这一层初始全隐
	pipa_room.visible = false
	conch_room.visible = false
	backpack.visible = false
	
	# 确保背包里的道具初始是隐藏的(还没捡到)
	if pack_pipa: pack_pipa.visible = false
	if pack_conch: pack_conch.visible = false
	
	# --- 绑定信号 (代码自动连接，防止你漏连) ---
	# 背包拖拽
	if pack_pipa: pack_pipa.gui_input.connect(_on_item_input.bind(pack_pipa))
	if pack_conch: pack_conch.gui_input.connect(_on_item_input.bind(pack_conch))
	
	# 房间内按钮
	if has_node("RestorationUI/PipaRoom/BagBtn"):
		bag_btn_pipa.pressed.connect(_on_bag_btn_pressed)
	if has_node("RestorationUI/ConchRoom/BagBtn"):
		bag_btn_conch.pressed.connect(_on_bag_btn_pressed)
	
	# 返回按钮
	if back_btn_pipa: back_btn_pipa.pressed.connect(_on_pipa_room_back)
	
	# 播放背景音
	bgm.play()
	
	# 开始流程
	play_full_flow()

# ==========================================
# 3. 输入控制
# ==========================================
func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		
		# 1. 如果正在拖拽或者打开了背包/按钮，不要触发剧情字幕
		if backpack.visible or collect_btn.visible or collect_btn2.visible:
			return
		
		# 2. 如果全通关，点击屏幕跳转
		if is_all_finished:
			print("剧情结束，跳转...")
			get_tree().change_scene_to_file("res://Scenes/feitian_scene.tscn")
			return 
		
		# 3. 正常剧情点击
		user_clicked.emit()

func _process(_delta):
	# 物品跟随鼠标
	if dragging_item:
		dragging_item.global_position = get_global_mouse_position() - (dragging_item.size / 2)

# ==========================================
# 4. 剧情流程 (前半部分：探索收集)
# ==========================================
func say_and_wait(text: String):
	subtitle.text = text
	await get_tree().create_timer(0.2).timeout
	await user_clicked

func switch_background_with_fade(new_path: String):
	var t = create_tween()
	t.tween_property(bg, "modulate:a", 0.0, 0.5)
	await t.finished
	bg.texture = load(new_path)
	var t2 = create_tween()
	t2.tween_property(bg, "modulate:a", 1.0, 0.5)
	await t2.finished
# --- 新增辅助函数：让界面淡入显示 ---
func fade_in_ui(ui_node):
	ui_node.modulate.a = 0.0 # 先设为完全透明
	ui_node.visible = true   # 显示出来（此时因为透明所以看不见）
	
	var tween = create_tween()
	# 0.5秒内，透明度从0变到1
	tween.tween_property(ui_node, "modulate:a", 1.0, 0.5)
# ==========================================
#           4. 剧情流程 (Intro)
# ==========================================
func play_full_flow():
	# --- 1. 开场初始状态 ---
	bg.texture = load("res://Assets/Images/background/6.1.jpg")
	yanweng_img.visible = true
	await say_and_wait("（点击屏幕继续...）")
	
	# 乐姬介绍
	yanweng_img.visible = false
	await switch_background_with_fade("res://Assets/Images/background/pipayueji1.jpg")
	await say_and_wait("乐姬：我是天宫的乐伎。昔日我手持【曲项琵琶】，奏响胡汉之音。\n如今琴身失落，我也失去了色彩。")
	await say_and_wait("请帮我找回【曲项琵琶】，让音乐窟重新焕发生机。")
	
	# 僧人介绍 (法螺介绍)
	await switch_background_with_fade("res://Assets/Images/background/faluoyueji1.jpg")
	await say_and_wait("僧人：贫僧守护此窟千年。那枚定调的【法螺】不知遗落在何处。")
	await say_and_wait("僧人：没有法螺的洪音，交响便失去了根基。施主，请务必帮我寻回。")
	
	# 回到主场景
	await switch_background_with_fade("res://Assets/Images/background/6.1.jpg")
	yanweng_img.visible = true
	
	# -----------------------------------
	
	# --- 3. 剧情讲完，开始寻找 ---
	start_pipa_phase()
	
func start_pipa_phase():
	lights_group.visible = true
	left_light.visible = true
	right_light.visible = false
	await say_and_wait("岩翁：左侧有动静，去看看。")

# --- 左侧光点点击逻辑 (兼顾收集和修复) ---
func _on_left_light_pressed():
	# 【逻辑分支】如果是修复阶段，进乐姬房间
	if is_repair_phase:
		enter_pipa_room()
		return
	
	# 否则：原来的收集逻辑
	current_item_type = "pipa"
	left_light.visible = false
	sfx_pipa.play()
	items_group.visible = true
	item_pipa.visible = true
	item_conch.visible = false
	collect_btn.visible = true
	subtitle.text = "发现【曲项琵琶】"

func _on_collect_button_pressed():
	items_group.visible = false
	collect_btn.visible = false
	
	# 进背包
	pack_pipa.visible = true 
	subtitle.text = "【曲项琵琶】已放入背包。"
	
	# 下一阶段：找法螺
	await get_tree().create_timer(1.0).timeout
	start_conch_phase()

func start_conch_phase():
	lights_group.visible = true
	left_light.visible = false
	right_light.visible = true
	await say_and_wait("岩翁：右侧也有光芒。")

# --- 右侧光点点击逻辑 ---
func _on_right_light_pressed():
	# 【逻辑分支】如果是修复阶段，进法螺房间
	if is_repair_phase:
		enter_conch_room()
		return
		
	# 否则：原来的收集逻辑
	current_item_type = "conch"
	right_light.visible = false
	sfx_conch.play()
	items_group.visible = true
	item_conch.visible = true
	item_pipa.visible = false
	collect_btn2.visible = true
	subtitle.text = "发现【法螺】"

# ==========================================
# 5. 开启修复阶段 
# ==========================================
func _on_collect_button2_pressed():
	# 1. 隐藏收集界面
	items_group.visible = false
	collect_btn2.visible = false
	yanweng_img.visible = false
	
	# 进背包
	pack_conch.visible = true
	
	subtitle.text = "【法螺】已放入背包。碎片集齐。"
	await get_tree().create_timer(1.0).timeout
	
	# 3. 开启修复阶段
	start_repair_phase()

func start_repair_phase():
	is_repair_phase = true # 打开开关
	
	yanweng_img.visible = true
	await say_and_wait("岩翁：现在，点击左侧光点进入心像空间，修复乐姬。")
	
	# 重新点亮左侧光点 (作为入口)
	lights_group.visible = true
	left_light.visible = true
	right_light.visible = false

# ==========================================
# 6. 乐姬修复流程 (进房 -> 开包 -> 拖拽)
# ==========================================
# --- 进入乐姬房间 (带淡入效果) ---
func enter_pipa_room():
	lights_group.visible = false
	yanweng_img.visible = true
	# 打开 UI 层
	restoration_ui.visible = true
	
	# 【修改点】使用淡入动画，而不是直接变硬显
	fade_in_ui(pipa_room) # <--- 改了这里
	
	conch_room.visible = false
	
	backpack.visible = false
	bag_btn_pipa.visible = true
	back_btn_pipa.visible = false # 隐藏“返回”
	# 确保黑白状态
	leji_img.material = leji_img.material 
	leji_img.modulate.a = 1.0 # 确保图片本身是不透明的
	
	subtitle.text = "岩翁：乐姬失去了色彩... 打开背包试试。"

	
# 点击“打开背包”按钮 (通用)
func _on_bag_btn_pressed():
	backpack.visible = true
	# 隐藏按钮自己
	if pipa_room.visible: bag_btn_pipa.visible = false
	if conch_room.visible: bag_btn_conch.visible = false

# 拖拽逻辑 (通用)
func _on_item_input(event, item):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				dragging_item = item
				original_pos = item.global_position
			else:
				if dragging_item == item:
					check_drop(item)
					dragging_item = null

func check_drop(item):
	var target = null
	
	# 判断当前在哪个房间，找哪个目标
	if pipa_room.visible and item == pack_pipa:
		target = target_pipa
	elif conch_room.visible and item == pack_conch:
		target = target_conch
	
	if target and item.global_position.distance_to(target.global_position) < 400:
		fix_success(item)
	else:
		create_tween().tween_property(item, "global_position", original_pos, 0.2)
		# --- 新增调试代码 (修好后可以删掉) ---
	if target:
		var dist = item.global_position.distance_to(target.global_position)
		print("物品位置:", item.global_position)
		print("目标位置:", target.global_position)
		print("两者距离:", dist)
		# ----------------------------------
	
	# 距离判定
	if target and item.global_position.distance_to(target.global_position) < 200: # 这里的200就是判定范围
		fix_success(item)
	else:
		create_tween().tween_property(item, "global_position", original_pos, 0.2)
		
# --- 修复成功 (带色彩渐变动画) ---
# --- 修复成功 (带色彩渐变动画) ---
func fix_success(item):
	item.visible = false # 消耗物品
	backpack.visible = false
	
	# 创建动画管家
	var tween = create_tween()
	
	if item == pack_pipa:
		# 1. 【视觉魔术】先让黑白图“闪亮/变白” (模拟灵力注入)
		# 0.5秒内，把颜色变成很亮的白色 (RGB=5,5,5)，看起来像发光
		tween.tween_property(leji_img, "modulate", Color(5, 5, 5, 1), 0.5)
		
		# 2. 动画中间：去掉滤镜，变回彩色
		tween.tween_callback(func(): 
			leji_img.material = null # 这一瞬间变彩，但因为太亮了看不清切换过程
			sfx_pipa2.play() # 音乐响起
		)
		
		# 3. 慢慢变回正常颜色
		# 1.5秒内，从亮白变回正常颜色，颜色就显现出来了
		tween.tween_property(leji_img, "modulate", Color(1, 1, 1, 1), 1.5)
		
		subtitle.text = "乐姬：盛唐之音，再次回响。"
		
		await tween.finished
		back_btn_pipa.visible = true
		
	elif item == pack_conch:
		# 法螺也是同样的“闪亮变色”逻辑
		tween.tween_property(faluo_img, "modulate", Color(5, 5, 5, 1), 0.5)
		
		tween.tween_callback(func(): 
			faluo_img.material = null
			sfx_conch.play()
		)
		
		tween.tween_property(faluo_img, "modulate", Color(1, 1, 1, 1), 1.5)
		
		subtitle.text = "法螺乐姬：法螺归位，佛音长鸣。"
		
		await tween.finished
		await get_tree().create_timer(1.0).timeout
		finish_scene()
		
				
# 点击乐姬房的返回按钮
func _on_pipa_room_back():
	# 退出房间
	pipa_room.visible = false
	restoration_ui.visible = false
	
	# 回到主界面，指引去右边
	lights_group.visible = true
	left_light.visible = false
	right_light.visible = true
	
	subtitle.text = "岩翁：去右侧，修复最后一位。"

# ==========================================
# 7. 法螺修复流程
# ==========================================
# --- 进入法螺房间 (带淡入效果) ---
func enter_conch_room():
	lights_group.visible = false
	
	restoration_ui.visible = true
	
	# 【修改点】使用淡入动画
	fade_in_ui(conch_room) # <--- 改了这里
	
	pipa_room.visible = false
	
	backpack.visible = false
	bag_btn_conch.visible = true
	
	# 确保黑白状态
	faluo_img.material = faluo_img.material
	faluo_img.modulate.a = 1.0
	
	subtitle.text = "岩翁：打开背包，归还法螺。"

# ==========================================
# 8. 结局
# ==========================================
func finish_scene():
	restoration_ui.visible = false
	yanweng_img.visible = true
	subtitle.text = "岩翁：乐章已完整，天宫即将苏醒... (点击屏幕跳转)"
	is_all_finished = true
