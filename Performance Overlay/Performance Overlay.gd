extends CanvasLayer

const WIDTHSETTINGPATH: String = "quack/performance_overlay/size/max_width"
const FONTSIZESETTINGPATH: String = "quack/performance_overlay/size/font_size"

func _ready() -> void:
	var width: int = ProjectSettings.get_setting(WIDTHSETTINGPATH,$container.size.x)
	if width <= 0:
		width = Quack.root.size.x
	$container.size.x = width

#@onready var topcontainer: HBoxContainer = $topcontainer
#@onready var fpscontainer: HBoxContainer = $topcontainer/fpscontainer

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
#@onready var test: Label = $container/test/label

var processtime: float
var physprocesstime: float
func _process(delta: float) -> void:
	fpsreadout.set_text(str(Engine.get_frames_per_second()))
	interpreadout.set_text(str(Quack.interpfrac))
	deltareadout.set_text(str(delta))
	processtime = Performance.get_monitor(Performance.TIME_PROCESS)
	processtimereadout.set_text(str(processtime))
	quackdeltareadout.set_text(str(Quack.delta_time_float))
	processdeltatimediffreadout.set_text(str(delta - processtime))
	processquackdeltadiffreadout.set_text(str(delta - Quack.delta_time_float))
	var netupdaterate: float = float(Quack.delta_time_net_recieve)* 0.000001
	netupdateratereadout.set_text(str(netupdaterate))
	physicsnetdiffreadout.set_text(str(netupdaterate - physicsprocessrate))
#	float((Quack.current_time_net_recieve-Quack.net_recieve_start_time)%1000000)* 0.000001
	var netupdateoffset: float = float(Quack.current_time_net_recieve%1000000)* 0.000001
	netupdateoffsetreadout.set_text(str(netupdateoffset))
	physicsprocessnetupdateoffsetreadout.set_text(str(netupdateoffset-physicsprocessoffset))
#	var nuts: float = 0.5
##	prints(get_meta("asfd"),get_meta("mat"),get_meta("fsda"))
#	var deez: int = Time.get_ticks_usec()
#	set_meta("asfd",999.456)
#	set_meta("mat",-59124)
#	set_meta("fsda",Vector3(54324.44,523.3,-4312.10))
##	prints(get_meta("asfd"),get_meta("mat"),get_meta("fsda"),Time.get_ticks_usec()-deez)
##	Quack.quit()
#	test.set_text(str(Time.get_ticks_usec()-deez))

var physicsprocessrate: float
var physicsprocessoffset: float
func _physics_process(delta: float) -> void:
	physprocesstime = Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS)
	physdeltareadout.set_text(str(delta))
	quackphysdeltareadout.set_text(str(Quack.physics_delta))
	physprocesstimereadout.set_text(str(physprocesstime))
	physicsprocesstimedeltadiffreadout.set_text(str(delta - physprocesstime))
	physicsprocessrate = float(Quack.delta_time_physics)* 0.000001
	physicsprocessratereadout.set_text(str(physicsprocessrate))
#	(Quack.current_time_physics-Quack.physics_start_time)%1000000
	physicsprocessoffset = float(Quack.current_time_physics%1000000)* 0.000001
	physicsprocessoffsetreadout.set_text(str(physicsprocessoffset))

func call_all(callables: Array[Callable]) -> void:
	for callable in callables:
		callable.call()
