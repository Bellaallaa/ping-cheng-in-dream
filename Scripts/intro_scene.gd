extends Control

# --- 节点引用 ---
@onready var main_visual = $main_visual
@onready var subtitle = $Subtitle
@onready var sfx_player = $SFX_Player
@onready var choice_container = $ChoiceContainer
@onready var detail_img = $DetailImg # 这个可能暂时用不到了，但先留着
@onready var yanweng_img = $YanwengImg

# --- 【新】预加载明暗变化的图片资源 ---
# 请确保你的路径和文件名是正确的！
var img_brightest = load("res://Assets/Images/background/1.1.jpg") # 1.1 最亮
var img_bright    = load("res://Assets/Images/background/1.2.jpg") # 1.2 较亮
var img_dark      = load("res://Assets/Images/background/1.3.jpg") # 1.3 较暗
#var img_darkest   = load("res://Assets/Images/background/1.4.jpg") # 1.4 最暗

# --- 定义信号 ---
signal user_clicked

func _ready():
	# 初始化
	# Shader 半径设为 -1 或 0 都可以，确保开始是黑的
	main_visual.material.set_shader_parameter("radius", 0.0)
	
	# 确保一开始加载的是最暗的那张图，或者普通的石窟图
	# 这里假设最开始显示最暗的，等待变亮
	main_visual.texture = img_dark
	
	detail_img.visible = false
	yanweng_img.visible = false
	choice_container.visible = false
	subtitle.text = ""
	
	# 开始演出
	start_opening_sequence()

# --- 全局输入检测 ---
func _input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			# 检查是不是因为按钮挡住了？
			if choice_container.visible:
				return
			user_clicked.emit()

# --- 显示文字并等待点击 ---
func say_and_wait(text: String):
	subtitle.text = text
	subtitle.visible_ratio = 0.0 
	
	var duration = text.length() * 0.05
	var tween = create_tween()
	tween.tween_property(subtitle, "visible_ratio", 1.0, duration)
	
	await user_clicked
	
	if subtitle.visible_ratio < 1.0:
		tween.kill()
		subtitle.visible_ratio = 1.0 
		await user_clicked

# --- 导演脚本 ---
func start_opening_sequence():
	print("阶段1：开始播放字幕...")
	await say_and_wait("我叫林音，一个普通的学生...（点击继续...）")
	
	print("阶段2：开始播放Shader动画...")
	subtitle.text = "（点击继续...）" 
	sfx_player.play() 
	
	var tween = create_tween()
	# 半径变大，显示出画面
	tween.tween_property(main_visual, "material:shader_parameter/radius", 1.5, 4.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	
	await tween.finished
	print("晕染结束...")
	
	# 此时画面已经是亮的了，开始旁白
	await say_and_wait("现在的石窟是静止的、灰暗的，仿佛一幅褪色的古画。")
	
	# 观察效果（放大再缩小）
	await play_zoom_effect()
	
	# --- 阶段三：明暗闪烁 (修改后) ---
	# 字幕配合
	subtitle.text = "（石窟深处传来了微弱的光芒...）"
	await play_light_change_sequence() # 执行图片切换动画
	
	# --- 阶段四：岩翁出场 ---
	yanweng_img.visible = true 
	
	await say_and_wait("岩翁：你来了……入画之人。吾乃此山之骨。\n云冈石窟沉睡太久了。")
	await say_and_wait("岩翁：当年的工匠将东方的木、西方的石、胡人的乐、汉人的礼，统统揉进了这洞窟里。")
	await say_and_wait("岩翁：如今，这些‘连接’断了。\n你需要帮我找回散落在画中的‘意象’，重修这交融之窟。")
	
	# --- 阶段五：显示选择按钮 ---
	subtitle.text = "（请选择进入的年代）"
	choice_container.visible = true
	$ChoiceContainer/Btn_Middle.pressed.connect(_on_enter_game)


# --- 【核心修改】播放明暗变化的图片序列 ---
func play_light_change_sequence():
	print("开始播放明暗闪烁...")
	
	# 定义播放顺序：暗 -> 亮 -> 暗
	# 1.4(最暗) -> 1.3 -> 1.2 -> 1.1(最亮) -> 1.2 -> 1.3 -> 1.4(最暗)
	var sequence = [
		#img_darkest,
		img_dark,
		img_bright,
		img_brightest, # 顶峰
		img_bright,
		img_dark,
		#img_darkest
	]
	
	# 遍历数组进行播放
	for img in sequence:
		main_visual.texture = img
		# 每张图停留 0.15 秒，你可以修改这个数字调整闪烁快慢
		# 0.1 ~ 0.2 秒比较有“老电影”或“记忆闪回”的感觉
		await get_tree().create_timer(0.2).timeout

# --- 播放仔细观察的缩放效果 ---
func play_zoom_effect():
	print("开始观察效果...")
	main_visual.pivot_offset = main_visual.size / 2
	var tween = create_tween()
	tween.tween_property(main_visual, "scale", Vector2(1.1, 1.1), 3.0).set_trans(Tween.TRANS_SINE)
	tween.tween_interval(1.0)
	tween.tween_property(main_visual, "scale", Vector2(1.0, 1.0), 2.0).set_trans(Tween.TRANS_SINE)
	await tween.finished

# --- 进入游戏 ---
func _on_enter_game():
	sfx_player.stop()
	get_tree().change_scene_to_file("res://Scenes/game_scene1.tscn")
