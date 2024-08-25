package backends.openfl;

import shimp.Point;
import Axis2D;
import openfl.events.MouseEvent;
import openfl.events.Event;
import shimp.InputSystem.InputTarget;
import a2d.AspectRatio;

class OflInputRoot {
	var factors:AspectRatio;
	var input:InputTarget<Point>;
	var pos = new Point();
	var stg:openfl.display.Stage;

	public function new(input, fac) {
		this.input = input;
		this.factors = fac;
		stg = openfl.Lib.current.stage;
		stg.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		stg.addEventListener(MouseEvent.MOUSE_UP, onUp);
		stg.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
	}

	function onEnterFrame(e) {
		updatePos();
	}

	inline function updatePos() {
		pos.x = 2 * (stg.mouseX / stg.stageWidth) * factors[horizontal];
		pos.y = 2 * (stg.mouseY / stg.stageHeight) * factors[vertical];
		input.setPos(pos);
	}

	function onDown(e) {
		updatePos();
		input.press();
	}

	function onUp(e) {
		input.release();
	}
}
