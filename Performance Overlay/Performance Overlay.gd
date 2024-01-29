extends CanvasLayer

const WIDTHSETTINGPATH = &"quack/performance_overlay/size/max_width"
const FONTSIZESETTINGPATH = &"quack/performance_overlay/size/font_size"

func _ready() -> void:
	container.size.x = max_width if max_width > 0 else Quack.root.size.x
	if GameState.acting_as_server():
		framedelayreadout.get_parent().hide()
		timebehindserverreadout.get_parent().hide()
		netinputdelayreadout.get_parent().hide()
		serverbufferreadout.get_parent().hide()
		totalinputdelayreadout.get_parent().hide()

func _enter_tree() -> void:
	Quack.root.size_changed.connect(assign_width_to_root_width)
func _exit_tree() -> void:
	Quack.root.size_changed.disconnect(assign_width_to_root_width)

func assign_width_to_root_width() -> void:
	var root_width: int = Quack.root.size.x
	if root_width < max_width or max_width == 0:
		container.size.x = root_width
	elif container.size.x != max_width:
		container.size.x = max_width

#@onready var topcontainer: HBoxContainer = $topcontainer
#@onready var fpscontainer: HBoxContainer = $topcontainer/fpscontainer

@onready var container: HFlowContainer = $container
@onready var max_width: int = ProjectSettings.get_setting(WIDTHSETTINGPATH,container.size.x)

@onready var fpsreadout: Label = $container/fpscontainer/readout
@onready var interpreadout: Label = $container/interpcontainer/readout
@onready var deltareadout: Label = $container/deltacontainer/readout
@onready var physdeltareadout: Label = $container/physdeltacontainer/readout
@onready var quackphysdeltareadout: Label = $container/quackphysdeltacontainer/readout
@onready var quackdeltareadout: Label = $container/quackdeltacontainer/readout
@onready var processtimereadout: Label = $container/processtimecontainer/readout
@onready var physprocesstimereadout: Label = $container/physprocesstimecontainer/readout
@onready var processdeltatimediffreadout: Label = $container/processdeltatimediffcontainer/readout
@onready var processquackdeltadiffreadout: Label = $container/processquackdeltadiffcontainer/readout
@onready var physicsprocesstimedeltadiffreadout: Label = $container/physicsprocesstimedeltadiffcontainer/readout
@onready var physicsprocessratereadout: Label = $container/physicsprocessratecontainer/readout
@onready var netupdateratereadout: Label = $container/netupdateratecontainer/readout
@onready var physicsnetdiffreadout: Label = $container/physicsnetdiffcontainer/readout
@onready var physicsprocessoffsetreadout: Label = $container/physicsprocessoffsetcontainer/readout
@onready var netupdateoffsetreadout: Label = $container/netupdateoffsetcontainer/readout
@onready var physicsprocessnetupdateoffsetreadout: Label = $container/physicsprocessnetupdateoffsetdiffcontainer/readout
@onready var quackfpsreadout: Label = $container/quackfpscontainer/readout
@onready var framedelayreadout: Label = $container/framedelaycontainer/readout
@onready var timebehindserverreadout: Label = $container/timebehindservercontainer/readout
@onready var netinputdelayreadout: Label = $container/netinputdelaycontainer/readout
@onready var serverbufferreadout: Label = $container/serverbuffercontainer/readout
@onready var totalinputdelayreadout: Label = $container/totalinputdelaycontainer/readout
#@onready var test: Label = $container/test/label

var processtime: float
var physprocesstime: float
func _process(delta: float) -> void:
	fpsreadout.set_text(str(Engine.get_frames_per_second()))
	quackfpsreadout.set_text(str(int(1.0/delta)))
	interpreadout.set_text(str(TimeUtils.interpfrac))
	deltareadout.set_text(str(delta))
	processtime = Performance.get_monitor(Performance.TIME_PROCESS)
	processtimereadout.set_text(str(processtime))
	quackdeltareadout.set_text(str(TimeUtils.process_delta_time_float))
	processdeltatimediffreadout.set_text(str(delta - processtime))
	processquackdeltadiffreadout.set_text(str(delta - TimeUtils.process_delta_time_float))
	var netupdaterate: float = TimeUtils.usec_to_seconds(Network.delta_time_net_receive)
	netupdateratereadout.set_text(str(netupdaterate))
	physicsnetdiffreadout.set_text(str(netupdaterate - physicsprocessrate))
	var netupdateoffset: float = TimeUtils.usec_get_sec_offset_from_second(Network.current_time_net_receive)
	netupdateoffsetreadout.set_text(str(netupdateoffset))
	physicsprocessnetupdateoffsetreadout.set_text(str(netupdateoffset-physicsprocessoffset))

var physicsprocessrate: float
var physicsprocessoffset: float
func _physics_process(delta: float) -> void:
	physprocesstime = Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS)
	physdeltareadout.set_text(str(delta))
	quackphysdeltareadout.set_text(str(Tickrate.physics_delta))
	physprocesstimereadout.set_text(str(physprocesstime))
	physicsprocesstimedeltadiffreadout.set_text(str(delta - physprocesstime))
	physicsprocessrate = TimeUtils.usec_to_seconds(TimeUtils.physics_delta_time_usec)
	physicsprocessratereadout.set_text(str(physicsprocessrate))
#	(Quack.current_time_physics-Quack.physics_start_time)%1000000
	physicsprocessoffset = TimeUtils.usec_get_sec_offset_from_second(TimeUtils.physics_delta_time_usec)
	physicsprocessoffsetreadout.set_text(str(physicsprocessoffset))
	if !GameState.acting_as_server():
		update_network_readouts()

const framestring = "f"
const msstring = "ms"

func update_network_readouts() -> void:
	var local_client := GameState.local_client
	framedelayreadout.set_text(str(local_client.frame_delay)+framestring)
	timebehindserverreadout.set_text(str(TimeUtils.frames_to_ms(local_client.frame_delay))+msstring)
	netinputdelayreadout.set_text(str(TimeUtils.frames_to_ms(local_client.get_network_input_delay()))+msstring)
	serverbufferreadout.set_text(str(local_client.get_server_input_delay())+framestring)
	totalinputdelayreadout.set_text(str(TimeUtils.frames_to_ms(local_client.get_total_input_delay()))+msstring)

func call_all(callables: Array[Callable]) -> void:
	for callable in callables:
		callable.call()
