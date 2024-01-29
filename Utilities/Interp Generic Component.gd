# MIT License
#
# Copyright (c) 2023 Miles Mazzotta
# https://github.com/explodingimplosion/general_utilities
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
class_name InterpGeneric extends RefCounted
## This class serves as a generic way to interpolate properties for [Node]s that
## are updated on physics frames (i.e. only change in [method Node._physics_process]), but are
## read by code and observed by players on rendered frames (i.e. in [method Node._process]).
##[br][br]Nodes can integrate this object into their scripts, calling [method update] using 
## Nodes can call [method interpolate] or [method interpolate_current_physics_fraction]
## during render frames to interpolate the property between its [member last] and
## [member next] values.


## The 'previous real' value of the given property that was used on the last
## physics frame.
var last: Variant
## The 'next real' value of the given property that was used on the most recently
## simulated physics frame
var next: Variant
## The owner [Node] that the interpolater is bound to.
var owner: Node
## The path to the [member owner]'s property which will be interpolated.
var property: StringName
## The numerical weight used in interpolating [member owner]'s [member property].
var diff: float

## Emitted whenever [method update] is called, and passes whatever value
## [member property] became.
signal updated(value)
## Emitted whenever the [member owner]'s property is changed by the interpolater.
## Includes [code]value[/code] as an argument, which is the [member owner]'s
## property's current value.
signal property_updated(value)
## Whenever the interpolater interpolates the [member owner]'s property between
## its [member last] and [member next] values, and 
signal interpolated(frac)
## Whenever the interpolater snaps to a value. Includes [code]to[/code] as an
## argument, which is the value the [member owner]'s property was snapped to.
signal interp_snapped(to)

## Constructor. Sets [member owner] and [member property].
@warning_ignore("shadowed_variable")
func _init(owner: Node, property: StringName) -> void:
	self.owner = owner
	self.property = property

## Assigns the [member owner]'s property to the [code]value[/code] parameter and
## emits the [signal property_updated] signal with [code]value[/code] passed as
## a parameter.
func assign_property(value: Variant) -> void:
	owner[property] = value
	property_updated.emit(value)

## Assigns [member last] to [member next]. This function is really just an
## abstraction to help understand why the assignment happens. It happens because
## before [member property] is updated, [member last] needs to be updated to
## [member property]'s 'real' value, that way when [member next] is updated,
## [member property] will properly interpolate between its new 'previous' value
## and its new 'real' value.
func update_last() -> void:
	last = next

## Assigns [member next] to [member owner]'s [member property]'s value. Similar
## to [method update_last], this function also serves as an abstraction to help
## understand why this assignment happens, such that on any subsequent frames,
func update_next() -> void:
	next = owner[property]

## Finds the proper weight of how far [member last] is from [member next].
func calc_diff() -> void:
	diff = last.distance_to(next)

## Interpolates the property on process frames
func interpolate(frac: float) -> void:
	assign_property(lerp(last,next,diff))
	interpolated.emit(frac)

## Calls [method interpolate] with [method Engine.get_physics_interpolation_fraction]
## passed as an argument.
func interpolate_current_physics_fraction() -> void:
	interpolate(Engine.get_physics_interpolation_fraction())

## Called before updating [member property] to a new value on a physics frame.
## Calls [method update_last] and [method assign_property] with [member next]
## passed as an argument for the latter function.
func preupdate() -> void:
	update_last()
	assign_property(next)

## Called after updating [member property]'s value. Calls [method update_next]
## and [method calc_diff].
func postupdate() -> void:
	update_next()
	calc_diff()

## This function is intended to be called when a function that changes
## [member owner]'s [member property]'s value. It sets up the [member owner] how
## it needs to be before the property is updated, then calls [code]update_func[/code]
## with [code]delta[/code] passed as an argument, and then sets up the interpolater
## how it needs to be for the next frame before emitting [signal updated] with
## the property's new value passed as an argument.
func update(update_func: Callable, delta: float) -> void:
	preupdate()
	update_func.call(delta)
	postupdate()
	updated.emit(next)

## Snaps the interpolating values to [member property]'s current value, such that
## until [method update] is called again, [member node]'s [member property] will
## no longer interpolate.
## Sets [member last] and [member next] to [member property], and sets [member diff]
## to 0. Also emits [signal interp_snapped] with [member property]'s current value passed
## as an argument.
func snap() -> void:
	last = owner[property]
	next = last
	diff = 0
	interp_snapped.emit(last)

## Identical to [method snap], except it accepts an argument to set [member property]
## to.
func snap_to(value: Variant) -> void:
	assign_property(value)
	last = value
	next = value
	diff = 0
	interp_snapped.emit(value)
