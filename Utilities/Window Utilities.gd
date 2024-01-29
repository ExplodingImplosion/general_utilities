class_name WindowUtils

const DEBUG_WINDOW_SIZE := Vector2i(768, 450)
const DEBUG_WINDOW_POS := Vector2i(20,40)
const RES_SETTING: StringName = "quack/video/resolution/game_resolution"
const MENU_RES_SETTING: StringName = "quack/video/resolution/menu_resolution"

const FPS_SETTING: StringName = "quack/video/framerate/game_framerate"
const MENU_FPS_SETTING: StringName = "quack/video/framerate/menu_framerate"
const OOF_FPS_SETTING: StringName = "quack/video/framerate/out_of_focus_framerate"

const FULLSCREEN_SETTING: StringName = "quack/video/fullscreen/game_fullscreen"
const MENU_FULLSCREEN_SETTING: StringName = "quack/video/fullscreen/menu_fullscreen"

const RENDER_SCALE_SETTING: StringName = "rendering/scaling_3d/scale"

enum {FULLSCREEN,WINDOWED,BORDERLESS,RESIZEABLE=8}

const DEBUG_IDENTIFIER: String = " (DEBUG)"


static func set_window_mode(mode: int) -> void:
	assert(mode <= Window.MODE_EXCLUSIVE_FULLSCREEN and mode >= 0, "Invalid window mode %s. Should be a value from 0 to %s."%[mode,Window.MODE_EXCLUSIVE_FULLSCREEN])
	Quack.root.set_mode(mode)

static func is_root_fullscreen() -> bool:
	return is_fullscreen(Quack.root)

static func is_fullscreen(window: Window) -> bool:
	return window.get_mode() == Window.MODE_FULLSCREEN or window.get_mode() == Window.MODE_EXCLUSIVE_FULLSCREEN

static func go_fullscreen() -> void:
	@warning_ignore("static_called_on_instance")
	Quack.root.set_mode(Window.MODE_EXCLUSIVE_FULLSCREEN if Quack.is_exported() else Window.MODE_FULLSCREEN)

static func go_windowed() -> void:
	Quack.root.set_mode(Window.MODE_WINDOWED)

static func is_windowed(window: Window) -> bool:
	return window.get_mode() == Window.MODE_WINDOWED or window.get_mode() == Window.MODE_MAXIMIZED

static func is_root_windowed() -> bool:
	return is_windowed(Quack.root)

static func set_fullscreen(enabled: bool = true) -> void:
	go_fullscreen() if enabled else go_windowed()
# static functionally the same as:
#	if enabled:
#		get_tree().get_root().set_mode(Window.MODE_FULLSCREEN)
#	else:
#		get_tree().get_root().set_mode(Window.MODE_WINDOWED)

static func toggle_fullscreen() -> void:
	set_fullscreen(!is_root_fullscreen())

static func set_borderless(enabled: bool = false) -> void:
	Quack.root.set_flag(Window.FLAG_BORDERLESS, enabled)

static func go_debug_window() -> void:
	if !is_root_windowed():
		go_windowed()
	Quack.root.set_size(DEBUG_WINDOW_SIZE)
	Quack.root.set_position(DEBUG_WINDOW_POS)

static func set_max_fps(max_fps: int) -> void:
	set_max_game_fps(max_fps) if Quack.is_3D_scene() else set_max_menu_fps(max_fps)

static func set_max_game_fps(max_fps: int) -> void:
	if Quack.is_3D_scene():
		Engine.set_max_fps(max_fps)
	ProjectSettings.set_setting(FPS_SETTING,max_fps)

static func set_max_menu_fps(max_fps: int) -> void:
	if !Quack.is_3D_scene():
		Engine.set_max_fps(max_fps)
	ProjectSettings.set_setting(MENU_FPS_SETTING,max_fps)

static func set_max_out_of_focus_fps(max_fps: int) -> void:
	ProjectSettings.set_setting(OOF_FPS_SETTING,max_fps)

static func get_oof_fps_cap() -> int:
	return ProjectSettings.get_setting(OOF_FPS_SETTING,60)

static func get_game_fps_cap() -> int:
	return ProjectSettings.get_setting(FPS_SETTING,300)

static func get_menu_fps_cap() -> int:
	return ProjectSettings.get_setting(MENU_FPS_SETTING,144)

static func initialize_general_settings() -> void:
	set_render_scale(ProjectSettings.get_setting(RENDER_SCALE_SETTING,1))

static func go_menu_settings() -> void:
	set_all_window_settings(get_menu_fps_cap(),
							ProjectSettings.get_setting(MENU_RES_SETTING),
							ProjectSettings.get_setting(MENU_FULLSCREEN_SETTING),0)

static func set_all_window_settings(max_fps: int, size: Vector2i, fullscreen: int,flags: int) -> void:
	Engine.set_max_fps(max_fps)
	if Quack.is_exported():
		resize_aligned(size)
		set_window_mode(fullscreen)
		if fullscreen != Window.MODE_EXCLUSIVE_FULLSCREEN:
			Quack.root.borderless = ByteUtils.bit_has_flag(flags,BORDERLESS)
			Quack.root.unresizable = !ByteUtils.bit_has_flag(flags,RESIZEABLE)
			# The same as doing these. idk why the fuck 'flags' work this way and are
			# settable this way via script.
#			Quack.root.set_flag(Window.FLAG_BORDERLESS,ByteUtils.bit_has_flag(fullscreen,BORDERLESS))
#			Quack.root.set_flag(Window.FLAG_RESIZE_DISABLED,ByteUtils.bit_has_flag(fullscreen,RESIZEABLE))

static func resize_aligned(size: Vector2i) -> void:
	Quack.root.set_size(size)
	var screensize: Vector2i = DisplayServer.screen_get_size()
	Quack.root.set_position((screensize-size)/2)

const video_settings_string: String = "Video Settings"
static func go_game_settings() -> void:
	set_all_window_settings(get_game_fps_cap(),
							ProjectSettings.get_setting(RES_SETTING),
							ProjectSettings.get_setting(FULLSCREEN_SETTING),0)

## Sets the render scale of the main window. lmao.
static func set_render_scale(scale: float) -> void:
	Quack.root.set_scaling_3d_scale(scale)
	ProjectSettings.set_setting(RENDER_SCALE_SETTING,scale)

## Changes the main window title to a specified string. lmao.
static func change_window_title(title: String) -> void:
	Quack.root.set_title(title)

## Resets the main window title to the project's name.
static func reset_window_title() -> void:
	change_window_title(get_window_title())

## Adds extra text to the title of the main window, succeeding the project's name
static func append_to_window_title(title: String) -> void:
	change_window_title(get_window_title() + title)

## Returns the project's name if the game is in release mode, or the project's
## name, plus a debug identifier if it isn't. Seems like godot does this by default now.
static func get_window_title() -> String:
	return ProjectSettings.get_setting("application/config/name","bruh")
#	var title: String = ProjectSettings.get_setting("application/config/name","bruh")
#	return title + DEBUG_IDENTIFIER if OS.is_debug_build() else title

enum {DEFAULT_WINDOW_SIZE_x = 1152,DEFAULT_WINDOW_SIZE_y = 648}
static func on_window_resized() -> void:
	var root: Viewport = Quack.root
	for child in root.get_children():
		if child is Control:
			child.set_scale(Vector2(root.size.x/float(DEFAULT_WINDOW_SIZE_x),
									root.size.y/float(DEFAULT_WINDOW_SIZE_y)))

static func get_mouse_position() -> Vector2:
	return Quack.root.get_mouse_position()

static func get_mouse_fraction() -> Vector2:
	return get_mouse_position() / Quack.root.size

static func get_mouse_position_from_center() -> Vector2:
	var mouse_position: Vector2 = get_mouse_position()
	var window_size: Vector2i = Quack.root.size
	var window_center: Vector2i = window_size / 2
	return Vector2(window_center) - mouse_position

static func get_mouse_fraction_from_center() -> Vector2:
	var mouse_position: Vector2 = get_mouse_position()
	var window_size: Vector2i = Quack.root.size
	var window_center: Vector2i = window_size / 2
	return (Vector2(window_center) - mouse_position) / Vector2(window_size)

static func get_target_fps() -> int:
				# passing nothing = pasding DisplayServer.SCREEN_OF_MAIN_WINDOW,
				# which is functionally the same as passing Quack.root.current_screen
	return roundi(DisplayServer.screen_get_refresh_rate()) if is_root_vsync_enabled() else Engine.max_fps

static func get_target_process_delta() -> float:
	return 1.0 / get_target_fps()

static func get_target_process_delta_usec() -> int:
	return TimeUtils.seconds_to_usec(get_target_process_delta())

static func is_root_vsync_enabled() -> bool:
	return get_root_vsync() > DisplayServer.VSYNC_DISABLED

static func get_root_vsync() -> int:
	return DisplayServer.window_get_vsync_mode(0)
