extends Control

var time_remaining := 360.0
var timer_running := false

var _door_choices := ["A", "B", "C"]
var _original_choice_container: VBoxContainer = null

func _ready():
	$StartButton.pressed.connect(_on_start_button_pressed)
	Dialogic.timeline_ended.connect(_on_dialog_ended)
	Dialogic.Choices.question_shown.connect(_on_question_shown)

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
	$AudioStreamPlayer.stop()
	time_remaining = 360.0
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
	$StartButton.visible = false
	$TimerLayer/TimerContainer.visible = false
	$TextureRect.visible = false
	$VBoxContainer.visible = false
	$GameOverLayer/GameOverBG.visible = true

func _on_question_shown(info: Dictionary):
	var texts := []
	for choice in info.choices:
		texts.append(choice.text.strip_edges())
	var is_door := texts.size() == 3
	for t in texts:
		if not _door_choices.has(t):
			is_door = false
	if not is_door:
		_restore_choice_container()
		return
	var choice_buttons := get_tree().get_nodes_in_group("dialogic_choice_button")
	var container: Node = null
	for btn in choice_buttons:
		if btn.visible and btn.get_parent() is VBoxContainer:
			container = btn.get_parent()
			break
	if container == null:
		return
	_original_choice_container = container
	var hbox := HBoxContainer.new()
	hbox.name = "DoorHBox"
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 80)
	hbox.layout_mode = 1
	hbox.anchors_preset = Control.PRESET_CENTER
	hbox.anchor_left = 0.5
	hbox.anchor_top = 0.5
	hbox.anchor_right = 0.5
	hbox.anchor_bottom = 0.5
	hbox.offset_left = -300
	hbox.offset_right = 300
	hbox.offset_top = -40
	hbox.offset_bottom = 40
	hbox.grow_horizontal = Control.GROW_DIRECTION_BOTH
	hbox.grow_vertical = Control.GROW_DIRECTION_BOTH
	container.get_parent().add_child(hbox)
	var buttons_to_move := []
	for child in container.get_children():
		if child is Button and child.visible:
			buttons_to_move.append(child)
	for btn in buttons_to_move:
		container.remove_child(btn)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.custom_minimum_size = Vector2(150, 60)
		hbox.add_child(btn)
	container.visible = false

func _restore_choice_container():
	var old_hbox = null
	for node in get_tree().get_nodes_in_group("dialogic_choice_button"):
		if node.get_parent() is HBoxContainer and node.get_parent().name == "DoorHBox":
			old_hbox = node.get_parent()
			break
	if old_hbox == null:
		return
	if _original_choice_container:
		var buttons := []
		for child in old_hbox.get_children():
			if child is Button:
				buttons.append(child)
		for btn in buttons:
			old_hbox.remove_child(btn)
			_original_choice_container.add_child(btn)
		_original_choice_container.visible = true
		_original_choice_container = null
	old_hbox.queue_free()
