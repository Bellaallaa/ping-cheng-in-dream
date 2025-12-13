extends Control

# --- 获取节点引用 ---
@onready var main_visual = $main_visual
@onready var subtitle = $Subtitle
@onready var sfx_player = $AudioStreamPlayer
@onready var choice_container = $ChoiceContainer

# --- 定义脚本台词 ---
var text_intro = "我叫林音，一个普通的学生。为了完成视觉艺术与计算美学的大作业，我来到了云冈石窟。"
var text_rock_old_man = "你来了……入画之人。吾乃此山之骨。云冈石窟沉睡太久了。\n你需要帮我找回散落在画中的‘意象’，重修这交融之窟。"

func _ready():
	# 1. 初始状态：全黑，静音
	#main_visual.modulate.a = 0 # 画面完全透明
	subtitle.text = ""
	choice_container.visible = false
	
	# 2. 开始演出序列
	start_opening_sequence()

func start_opening_sequence():
	# --- 阶段一：黑屏字幕 + 配音 ---
	# 对应脚本：屏幕全黑，下面有字幕...
	show_subtitle(text_intro)
	
	# 假设读这句话需要 4 秒
	await get_tree().create_timer(4.0).timeout
	
	# --- 阶段二：风声起，画面渐显 ---
	# 对应脚本：屏幕全黑，只有风沙呼啸的声音
	sfx_player.play() # 播放风声
	
	# 对应脚本：画面中央晕染开...显现出粗粝的砂岩质感
	# 我们用 Tween (补间动画) 让画面在 3 秒内从透明变清晰
	var tween = create_tween()
	tween.tween_property(main_visual, "modulate:a", 1.0, 3.0)
	
	# 等待画面完全显示
	await tween.finished
	
	# --- 阶段三：岩翁出场 ---
	# 对应脚本：微微亮起一丝微弱的光... “你来了...入画之人”
	# 这里我们可以做一个简单的高亮闪烁效果模拟“微微亮起”
	var flash_tween = create_tween()
	flash_tween.tween_property(main_visual, "modulate", Color(1.5, 1.5, 1.5, 1), 0.5) # 变亮
	flash_tween.tween_property(main_visual, "modulate", Color(1, 1, 1, 1), 0.5)     # 变回原样
	
	show_subtitle(text_rock_old_man)
	
	# 读完这段话后，显示选择按钮
	await get_tree().create_timer(6.0).timeout
	show_buttons()

# --- 辅助功能：显示字幕 ---
func show_subtitle(content: String):
	subtitle.text = content
	# 这里可以加一个打字机效果（以后再优化）

# --- 辅助功能：显示按钮 ---
func show_buttons():
	choice_container.visible = true
	# 连接中间按钮的信号
	# 对应脚本：出现三个按钮可以选择...中期（我们重点做的）
	$ChoiceContainer/Btn_Middle.pressed.connect(_on_middle_button_pressed)

# --- 交互反馈 ---
func _on_middle_button_pressed():
	print("玩家选择了中期音乐窟")
	# 停止风声
	sfx_player.stop()
	# 切换到下一个场景（第12窟）
	# get_tree().change_scene_to_file("res://scenes/GrottoScene.tscn")
	print("正在切换场景...")
