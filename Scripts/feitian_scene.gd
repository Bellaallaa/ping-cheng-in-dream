extends Control

# --- 1. 拿到场景里的“木偶”部件 ---
@onready var faded_mural = $FadedMural
@onready var vibrant_mural = $VibrantMural
@onready var audio_player = $AudioPlayer
@onready var sfx_player = $SFX_Player
@onready var subtitle = $Subtitle
# 拿到道具图标
@onready var pipa_icon = $UI_Layer/Inventory/PipaIcon
@onready var bili_icon = $UI_Layer/Inventory/BiliIcon
# 拿到目标区域
@onready var pipa_target = $UI_Layer/PipaTarget
@onready var bili_target = $UI_Layer/BiliTarget

# --- 新增引用 ---
@onready var panorama_img = $PanoramaImg
@onready var distant_img = $DistantImg
@onready var achievement_badge = $AchievementBadge
# 如果你有黑框节点，最好也引用一下，方便控制
@onready var dialog_box = $DialogBox 

@onready var tunnel_bg = $TunnelBg
@onready var achievement_text = $AchievementText
@onready var white_flash = $WhiteFlash

# --- 2. 定义变量（大脑的记忆） ---
var dragging_item = null  # 当前正在拖谁？(null表示没拖东西)
var original_position = Vector2.ZERO # 记录道具原来的位置，拖错了要弹回去
var placed_count = 0 # 记录放对了好几个

func _ready():
	# 加载并播放初始背景音
	#audio_player.stream = load("res://Assets/Audio/bgm/1.mp3") 
	#audio_player.play()
	
	# 初始化：把艳丽背景设为全透明
	vibrant_mural.modulate.a = 0
	subtitle.text = "岩翁：乐姬们已重获失落的音韵..."
	
	# --- 【新增】修正缩放中心点 ---
	# 这一行意思是：把缩放中心设置到图片宽的一半、高的一半（也就是正中心）
	# 只有设了这行，后面的放大动画才会是从中间放大的！
	vibrant_mural.pivot_offset = vibrant_mural.size / 2
	tunnel_bg.pivot_offset = tunnel_bg.size / 2
	
	## --- 关键：开启图标的鼠标检测 ---
	## 告诉Godot：这两个图标要接收鼠标信号
	#pipa_icon.gui_input.connect(_on_icon_gui_input.bind(pipa_icon))
	#bili_icon.gui_input.connect(_on_icon_gui_input.bind(bili_icon))
	#
	

## --- 3. 核心交互：拖拽逻辑 ---
## 这个函数会每一帧都运行，检测鼠标信号
#func _on_icon_gui_input(event, item):
	#if item.visible == false: return # 已经放好的东西不能再拖
	#
	#if event is InputEventMouseButton:
		## A. 鼠标按下：开始拖
		#if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			#dragging_item = item
			#original_position = item.global_position # 记住老家在哪
		#
		## B. 鼠标松开：停止拖，并检查位置
		#elif event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			#if dragging_item == item:
				#check_drop_target(item)
				#dragging_item = null # 清空手里的东西
#
#func _process(delta):
	## 如果当前手里正抓着东西，让它跟着鼠标跑
	#if dragging_item != null:
		#dragging_item.global_position = get_global_mouse_position() - (dragging_item.size / 2)
#
## --- 4. 裁判逻辑：放对了吗？ ---
#func check_drop_target(item):
	#var target = null
	## 如果拖的是琵琶，目标就是琵琶区域；如果是筚篥，目标就是筚篥区域
	#if item == pipa_icon:
		#target = pipa_target
	#elif item == bili_icon:
		#target = bili_target
	#
	## 检测距离：图标中心 和 目标区域中心 的距离小于 100 像素就算放对了
	#if item.global_position.distance_to(target.global_position) < 1000:
		#success_place(item)
	#else:
		## 放错了：弹回背包里
		#var tween = create_tween()
		#tween.tween_property(item, "global_position", original_position, 0.2)
#
## --- 5. 成功后的逻辑 ---
#func success_place(item):
	#print("放置成功！")
	#item.visible = false # 隐藏背包里的图标
	## 这里其实应该让壁画上对应的乐器亮起来，简单起见我们只计分
	#
	#placed_count += 1
	#if placed_count == 1:
		#subtitle.text = "岩翁：感觉到石窟的呼吸了吗？"
		## --- 音频部分修改 ---
		## 用专门的 SFX_Player 播放解锁音效，这样不会打断背景风声
		#sfx_player.stream = load("res://Assets/Audio/bgm/3.mp3")
		#sfx_player.play()
	#elif placed_count == 2:
		#start_climax()

# --- 6. 高潮演出  ---
#func start_climax():
	await get_tree().create_timer(2.0).timeout # 听一会儿音乐
	subtitle.text = "岩翁：这就是云冈的真相..."
	
	# A. 播放交响乐
	#切换背景音乐为高潮音乐
	audio_player.stop() # 先停掉风声
	audio_player.stream = load("res://Assets/Audio/bgm/3.mp3") # 确保你有这个文件
	audio_player.play()
	
	# B. 画面变艳丽 (Tween动画)
	var tween = create_tween()
	tween.set_parallel(true)
	# 3秒内，VibrantMural 从透明变实心
	tween.tween_property(vibrant_mural, "modulate:a", 1.0, 3.0)
	# 稍微放大一点，制造震撼感
	tween.tween_property(vibrant_mural, "scale", Vector2(1.05, 1.05), 5.0)
	# 岩翁消失
	tween.tween_property($RockOldMan, "modulate:a", 0.0, 3.0)
	tween.tween_property(subtitle, "modulate:a", 0.0, 3.0)
	tween.tween_property($DialogBox, "modulate:a", 0.0, 3.0)
	
	await tween.finished
	
# --- 7. 场景3  ---
	# -----------------------------------------------
	# 第1阶段：全景展现 & 岩翁独白 (场景3开始)
	# -----------------------------------------------
	await get_tree().create_timer(2.0).timeout # 听一会儿音乐
	
	# C. 切换到全景图 (Cross-fade)
	var tween2 = create_tween()
	tween2.tween_property(panorama_img, "modulate:a", 1.0, 3.0) # 全景图慢慢浮现
	
	# D. 岩翁画外音 (字幕淡入)
	subtitle.text = "岩翁：波斯的骨，汉家的血，龟兹的魂……\n这就是云冈石窟的真相。"
	
	# 把字幕和黑框重新显示出来
	var tween_text = create_tween()
	tween_text.set_parallel(true)
	tween_text.tween_property(subtitle, "modulate:a", 1.0, 1.0)
	if dialog_box: tween_text.tween_property(dialog_box, "modulate:a", 1.0, 1.0)
	
	await get_tree().create_timer(6.0).timeout # 给玩家6秒时间读字幕
	
	subtitle.text = "岩翁：你唤醒的不是石头，是一个包容万象的时代。\n去吧，去后室，那里还有更多关于‘人间’的故事……"
	
	await get_tree().create_timer(6.0).timeout # 再读6秒
	
	# -----------------------------------------------
	# 第2阶段：远景定格  (章节结束)
	# -----------------------------------------------
	
	# E. 动态向外拉远 (仿照开头的反向效果)
	# 先设置缩放中心为中心点
	distant_img.pivot_offset = distant_img.size / 2
	distant_img.scale = Vector2(1.2, 1.2) # 一开始稍微放大一点
	
	var tween3 = create_tween()
	tween3.set_parallel(true)
	# 字幕再次隐去
	tween3.tween_property(subtitle, "modulate:a", 0.0, 2.0)
	if dialog_box: tween3.tween_property(dialog_box, "modulate:a", 0.0, 2.0)
	
	# 远景图浮现
	tween3.tween_property(distant_img, "modulate:a", 1.0, 3.0)
	# 同时缩小回正常大小 (Zoom Out 效果)
	tween3.tween_property(distant_img, "scale", Vector2(1.0, 1.0), 3.0)
	
	await tween3.finished
	
	# -----------------------------------------------
	# 第3阶段：时空隧道 & 手写成就
	# -----------------------------------------------
	
	# 1. 手写字动画
	achievement_text.text = "达成成就：平城入梦" 
	
	achievement_text.visible_ratio = 0.0 # 字数归零
	achievement_text.modulate.a = 1.0    # 确保文字框可见
	
	# 【修复点】：这里改名叫 tween_write，防止和前面的变量名冲突！
	var tween_write = create_tween()
	# 2秒内，visible_ratio 从0变到1，模拟手写效果
	tween_write.tween_property(achievement_text, "visible_ratio", 1.0, 2.0)
	
	await tween_write.finished
	
	await get_tree().create_timer(1.5).timeout 
	
	# 2. 隧道 + 光圈 同时浮现
	# 光圈会遮住方形图片的硬边，让它看起来像融入了白雾中
	var tween_tunnel = create_tween()
	tween_tunnel.set_parallel(true)
	tween_tunnel.tween_property(tunnel_bg, "modulate:a", 1.0, 2.0)
	
	await tween_tunnel.finished
	
	# -----------------------------------------------
	# 最终阶段：旋转加速 + 冲入白光 (梦醒)
	# -----------------------------------------------
	
	print("梦醒时分...")
	
	# 步骤 B：文字先淡出
	# -----------------------------------------------
	var tween_text_out = create_tween() # 创建第一个动画管家
	tween_text_out.tween_property(achievement_text, "modulate:a", 0.0, 1.0)
	
	# 让程序等待 2 秒（等文字淡出完）
	await get_tree().create_timer(2.0).timeout 
	
	var tween_end = create_tween()
	tween_end.set_parallel(true) # 让下面的动作同时发生
	tween_end.set_trans(Tween.TRANS_EXPO) # 指数加速，越来越快
	tween_end.set_ease(Tween.EASE_IN)
	
	# A. 隧道无限放大 + 旋转 (制造扭曲穿越感)
	# 前提：你必须在 _ready() 里设置了 pivot_offset = size / 2
	tween_end.tween_property(tunnel_bg, "scale", Vector2(8, 10), 3.0)
	tween_end.tween_property(tunnel_bg, "rotation_degrees", 160.0, 3.0)
	
	
	# C. 白光彻底变亮 (淹没屏幕)
	tween_end.tween_property(white_flash, "modulate:a", 1.0, 2.5)
	
	# D. 音乐淡出 (音量变小)
	tween_end.tween_property(audio_player, "volume_db", -80.0, 3.0)
	
	await tween_end.finished
	
	print("全剧终")
	# get_tree().quit() # 如果想自动退出游戏，取消这一行的注释
