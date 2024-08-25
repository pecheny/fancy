package widgets.utils;

import Axis2D;
import Axis;
import al.core.AxisState;
import al.core.Placeholder;
import shimp.IPos;
import shimp.InputSystem.HitTester;
import shimp.Point;

class WidgetHitTester2D extends WidgetHitTester<2, Axis2D, Point> {}

@:generic
class WidgetHitTester<@:const NumAxes:Int, TAxis:Axis<TAxis>, TPos:IPos<TPos> & PosAccess<TAxis>> implements HitTester<TPos> {
	var w:Placeholder<TAxis>;

	public function new(w) {
		this.w = w;
	}

	public function isUnder(pos:TPos):Bool {
		var axisStates:AVector<TAxis, AxisState> = w.axisStates;
        // @:const works in haxe nightly only
        // as long as there is no other implementations than Axis2D yet
        // for now it is safe to leave hardcoded value '2'
		var numAxes =
			#if (haxe_ver < 4.4)
			2;
			#else
			NumAxes;
			#end

		for (a in 0...numAxes) {
			var a:TAxis = cast a;
            var axis = w.axisStates[a];
			var val = pos.getValue(a);
			if (val < axis.getPos())
				return false;
			if (val > (axis.getPos() + axis.getSize()))
				return false;
		}
		return true;
	}
}