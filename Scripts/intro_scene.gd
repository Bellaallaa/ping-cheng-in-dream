extends Control

# --- 节点引用 ---
@onready var main_visual = $main_visual
@onready var subtitle = $Subtitle
@onready var sfx_player = $SFX_Player
@onready var choice_container = $ChoiceContainer
@onready var yanweng_img = $YanwengImg

# --- 【新增】视频播放器引用 ---
@onready var video_player_1 = $VideoPlayer1
@onready var video_player_2 = $VideoPlayer2

# --- 图片资源 ---
var img_brightest = load("res://Assets/Images/background/1.1.jpg")
var img_bright    = load("res://Assets/Images/background/1.2.jpg")
var img_dark      = load("res://Assets/Images/background/1.3.jpg")

signal user_clicked

func _ready():
	# 初始化：隐藏所有东西
	main_visual.visible = false # 先隐藏主视觉，等视频放完再显示
	main_visual.material.set_shader_parameter("radius", 0.0)
	main_visual.texture = img_dark
	
	yanweng_img.visible = false
	choice_container.visible = false
	subtitle.text = "" # 字幕先清空
	
	# 确保视频播放器也是隐藏的（或者黑屏）
	video_player_1.visible = false
	video_player_2.visible = false
	
	# 开始演出
	start_opening_sequence()

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			# 【新增】支持点击跳过视频 (可选功能)
			if video_player_1.visible and video_player_1.is_playing():
				video_player_1.stop()
				_on_video_1_finished() # 手动触发结束
				return
			if video_player_2.visible and video_player_2.is_playing():
				video_player_2.stop()
				_on_video_2_finished()
				return
				
			if choice_container.visible: return
			user_clicked.emit()

# --- 导演脚本 ---
func start_opening_sequence():
	print("--- 阶段0：播放开场视频 ---")
	
	# 1. 播放第一段视频
	await play_video(video_player_1)
	
	# 2. 播放第二段视频
	await play_video(video_player_2)
	
	# 视频全部结束，开始原本的流程
	print("--- 视频结束，进入主流程 ---")
	
	# 显示主视觉层 (虽然现在是全黑的Shader)
	main_visual.visible = true 
	
	print("阶段1：开始播放字幕...")
	await say_and_wait("我叫林音，一个普通的学生...（点击继续...）")
	
	print("阶段2：开始播放Shader动画...")
	subtitle.text = "（点击继续...）" 
	sfx_player.play() 
	
	var tween = create_tween()
	tween.tween_property(main_visual, "material:shader_parameter/radius", 1.5, 4.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	
	await tween.finished
	print("晕染结束...")
	
	await say_and_wait("现在的石窟是静止的、灰暗的，仿佛一幅褪色的古画。")
	await play_zoom_effect()
	
	subtitle.text = "（石窟深处传来了微弱的光芒...）"
	await play_light_change_sequence()
	
	yanweng_img.visible = true 
	await say_and_wait("岩翁：你来了……入画之人。吾乃此山之骨。\n云冈石窟沉睡太久了。")
	await say_and_wait("岩翁：当年的工匠将东方的木、西方的石、胡人的乐、汉人的礼，统统揉进了这洞窟里。")
	await say_and_wait("岩翁：如今，这些‘连接’断了。\n你需要帮我找回散落在画中的‘意象’，重修这交融之窟。")
	
	subtitle.text = "（请选择进入的年代）"
	choice_container.visible = true
	$ChoiceContainer/Btn_Middle.pressed.connect(_on_enter_game)

# --- 【新增】通用的播放视频辅助函数 ---
func play_video(player: VideoStreamPlayer):
	# 显示播放器
	player.visible = true
	player.play()
	
	# 等待 finished 信号 (视频自然播放结束)
	# 为了支持跳过，我们这里稍微复杂一点，或者直接await finished
	await player.finished
	
	# 隐藏并销毁 (或禁用)
	player.stop()
	player.visible = false
	print("视频播放完毕")

# 如果你需要手动处理跳过逻辑，可以用上面 _input 里的方式
func _on_video_1_finished():
	video_player_1.emit_signal("finished") # 假装它放完了，解除上面的 await

func _on_video_2_finished():
	video_player_2.emit_signal("finished")

# --- 其他辅助函数 (保持不变) ---
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

func play_light_change_sequence():
	var sequence = [img_dark, img_bright, img_brightest, img_bright, img_dark]
	for img in sequence:
		main_visual.texture = img
		await get_tree().create_timer(0.2).timeout

func play_zoom_effect():
	main_visual.pivot_offset = main_visual.size / 2
	var tween = create_tween()
	tween.tween_property(main_visual, "scale", Vector2(1.1, 1.1), 3.0).set_trans(Tween.TRANS_SINE)
	tween.tween_interval(1.0)
	tween.tween_property(main_visual, "scale", Vector2(1.0, 1.0), 2.0).set_trans(Tween.TRANS_SINE)
	await tween.finished

func _on_enter_game():
	sfx_player.stop()
	get_tree().change_scene_to_file("res://Scenes/game_scene1.tscn")
