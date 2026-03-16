extends Control

var time_remaining := 600.0
var timer_running := false

func _ready():
	$StartButton.pressed.connect(_on_start_button_pressed)
	Dialogic.timeline_ended.connect(_on_dialog_ended)

func _process(delta):
	if not timer_running:
		return
	time_remaining -= delta
	if time_remaining <= 0:
		time_remaining = 0
		timer_running = false
		_on_time_up()
	var minutes := int(time_remaining) / 60
	var seconds := int(time_remaining) % 60
	$TimerLayer/TimerContainer/TimerLabel.text = "%02d:%02d" % [minutes, seconds]

func _on_start_button_pressed():
	$StartButton.visible = false
	$TimerLayer/TimerContainer.visible = true
	time_remaining = 600.0
	timer_running = true
	if ResourceLoader.exists('res://dialogic/main_dialog.dtl'):
		Dialogic.start('res://dialogic/main_dialog.dtl')
	else:
		print("错误：时间轴文件不存在，请在 Dialogic 编辑器中创建")
		$StartButton.visible = true
		$TimerLayer/TimerContainer.visible = false
		timer_running = false

func _on_dialog_ended():
	$StartButton.visible = true
	timer_running = false
	$TimerLayer/TimerContainer.visible = false

func _on_time_up():
	Dialogic.end_timeline()
	$TimerLayer/TimerContainer/TimerLabel.text = "00:00"
	$StartButton.visible = true
	$TimerLayer/TimerContainer.visible = false
