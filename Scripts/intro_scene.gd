extends Control

# --- 节点引用 ---
@onready var main_visual = $main_visual
@onready var subtitle = $Subtitle
@onready var sfx_player = $SFX_Player
@onready var choice_container = $ChoiceContainer
@onready var detail_img = $DetailImg
@onready var yanweng_img = $YanwengImg

# --- 【新】定义一个信号，用来通知脚本“玩家点击了” ---
signal user_clicked

func _ready():
	# 初始化
	main_visual.material.set_shader_parameter("radius", -1.0)
	
	detail_img.visible = false
	yanweng_img.visible = false
	choice_container.visible = false
	subtitle.text = ""
	
	# 开始演出
	start_opening_sequence()

# --- 【新】全局输入检测 ---
# 只要玩家点击鼠标左键，就发射信号
#func _unhandled_input(event):
	#if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		## 发射信号，告诉正在等待的函数“可以继续了”
		#user_clicked.emit()

# --- 将这段代码复制进去，替换原来的输入函数 ---
func _input(event):
	# 只要有鼠标按键动作，先打印一下，看看Godot是不是活着
	if event is InputEventMouseButton:
		# 只有按下那一瞬间才算
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			print("【DEBUG】检测到鼠标左键点击！准备发射信号...")
			
			# 检查是不是因为按钮挡住了？
			if choice_container.visible:
				print("【DEBUG】被选择按钮拦截了，不发射信号。")
				return
			
			# 发射信号
			user_clicked.emit()
			print("【DEBUG】信号已发射！")


# --- 【新】核心辅助函数：显示文字并等待点击 ---
# --- 【修改】带打字机效果的对话函数 ---
func say_and_wait(text: String):
	subtitle.text = text
	subtitle.visible_ratio = 0.0 # 先隐藏所有文字
	
	# 1. 计算打字速度
	# 0.05 表示每个字显示需要 0.05 秒，你可以改小让它更快
	var duration = text.length() * 0.05
	
	# 2. 创建打字动画
	var tween = create_tween()
	tween.tween_property(subtitle, "visible_ratio", 1.0, duration)
	
	# 3. 等待玩家点击
	# 注意：这里的 await 会在玩家点击时触发
	await user_clicked
	
	# 4. 【关键交互逻辑】
	# 当玩家点击时，我们要判断：是“字还没打完”？还是“字已经打完了”？
	
	if subtitle.visible_ratio < 1.0:
		# 情况A：玩家性急，字还没打完就点了
		# 操作：停止动画，瞬间显示所有字，并强迫玩家再点一次才换行
		tween.kill() # 杀掉动画
		subtitle.visible_ratio = 1.0 # 瞬间全显
		
		# 再次等待点击（防止玩家双击连跳两句）
		await user_clicked
		
	# 情况B：字已经自动打完了，玩家点击
	# 操作：什么都不用做，函数结束，脚本会自动执行下一句

# --- 导演脚本 ---
func start_opening_sequence():
	print("阶段1：开始播放字幕...")
	await say_and_wait("我叫林音，一个普通的学生...（点击继续...）")
	
	print("阶段2：开始播放Shader动画...")
	subtitle.text = "（点击继续...）" 
	sfx_player.play() 
	
	var tween = create_tween()
	# 注意：radius 应该从 0.0 变到 1.5，不要用负数，Shader里写的是 0.0-1.5
	tween.tween_property(main_visual, "material:shader_parameter/radius", 1.5, 4.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	
	await tween.finished
	print("动画播放完毕，等待用户点击...")
	
	#await user_clicked
	#print("用户点击了！进入下一阶段")
	
	say_and_wait("现在的石窟是静止的、灰暗的，仿佛一幅褪色的古画。")
	await play_zoom_effect()
	
	# --- 阶段三：局部闪烁 ---
	#play_flash_sequence()
	#await get_tree().create_timer(3.0).timeout # 闪烁还是让它自动播完比较好
	#
	# --- 阶段四：岩翁出场 ---
	yanweng_img.visible = true 
	
	# 使用新的点击等待逻辑，一句一句来
	await say_and_wait("岩翁：你来了……入画之人。吾乃此山之骨。\n云冈石窟沉睡太久了。")
	
	await say_and_wait("岩翁：当年的工匠将东方的木、西方的石、胡人的乐、汉人的礼，统统揉进了这洞窟里。")
	
	await say_and_wait("岩翁：如今，这些‘连接’断了。\n你需要帮我找回散落在画中的‘意象’，重修这交融之窟。")
	
	# --- 阶段五：显示选择按钮 ---
	subtitle.text = "（请选择进入的年代）"
	choice_container.visible = true
	$ChoiceContainer/Btn_Middle.pressed.connect(_on_enter_game)


# --- 辅助：播放特写闪烁 (保持不变) ---
func play_flash_sequence():
	detail_img.visible = true
	# 这里假设你没有多张图，用代码模拟闪烁
	# 如果你有图，请用你之前的写法
	var tween = create_tween()
	detail_img.modulate.a = 0.0
	tween.tween_property(detail_img, "modulate:a", 0.5, 1.0) # 变亮
	tween.tween_property(detail_img, "modulate:a", 0.0, 1.0) # 变暗
	await tween.finished
	detail_img.visible = false

# --- 进入游戏 ---
func _on_enter_game():
	sfx_player.stop()
	get_tree().change_scene_to_file("res://Scenes/game_scene1.tscn")

# --- 【新】播放仔细观察的缩放效果 ---
func play_zoom_effect():
	print("开始观察效果...")
	
	# 1. 关键步骤：设置缩放的轴心点为图片中心
	# 如果不写这一行，图片会向右下角跑偏
	main_visual.pivot_offset = main_visual.size / 2
	
	var tween = create_tween()
	
	# 2. 缓慢放大 (从 1.0 放大到 1.1倍，耗时 3 秒)
	# 这种缓慢的推镜头能营造“凝视”的感觉
	tween.tween_property(main_visual, "scale", Vector2(1.1, 1.1), 3.0).set_trans(Tween.TRANS_SINE)
	
	# 3. 停留 (保持放大状态 1 秒)
	tween.tween_interval(1.0)
	
	# 4. 缓慢复原 (回到 1.0，耗时 2 秒)
	tween.tween_property(main_visual, "scale", Vector2(1.0, 1.0), 2.0).set_trans(Tween.TRANS_SINE)
	
	# 等待整个过程结束
	await tween.finished
