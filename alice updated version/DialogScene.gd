extends Control

func _ready():
	# 连接按钮信号
	$StartButton.pressed.connect(_on_start_button_pressed)

	# 连接 Dialogic 信号
	Dialogic.timeline_ended.connect(_on_dialog_ended)

func _on_start_button_pressed():
	# 隐藏按钮
	$StartButton.visible = false

	# 检查时间轴是否存在
	if ResourceLoader.exists('res://dialogic/main_dialog.dtl'):
		# 启动时间轴
		Dialogic.start('res://dialogic/main_dialog.dtl')
	else:
		print("错误：时间轴文件不存在，请在 Dialogic 编辑器中创建")
		$StartButton.visible = true

func _on_dialog_ended():
	# 对话结束后显示按钮
	$StartButton.visible = true
	print("对话结束")
