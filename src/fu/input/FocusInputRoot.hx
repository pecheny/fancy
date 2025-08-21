package fu.input;

import ec.Entity;
import ec.CtxWatcher.CtxBinder;
import shimp.Point;
import shimp.InputSystem;

class FocusInputRoot implements CtxBinder {
    var target:InputTarget<Point>;

    public function new(trg) {
        this.target = trg;
    }

    public function bind(e:Entity) {
        var dispatcher = e.getComponent(FocusDispatcher);
        if (dispatcher != null)
            dispatcher.focusRequest.listen(onFocusRequest);

        var clicks = e.getComponent(ClickDispatcher);
        if (clicks != null) {
            clicks.press.listen(press);
            clicks.release.listen(release);
        }
    }

    public function unbind(e:Entity) {
        var dispatcher = e.getComponent(FocusDispatcher);
        if (dispatcher != null)
            dispatcher.focusRequest.remove(onFocusRequest);
        var clicks = e.getComponent(ClickDispatcher);
        if (clicks != null) {
            clicks.press.remove(press);
            clicks.release.remove(release);
        }
    }

    function press() {
        target.press();
    }

    function release() {
        target.release();
    }

    function onFocusRequest(pos:Point) {
        target.setPos(pos);
    }
}

interface ClickDispatcher {
    var press(default, null):Signal<Void->Void>;
    var release(default, null):Signal<Void->Void>;
}

interface FocusDispatcher {
    var focusRequest(default, null):Signal<Point->Void>;
}
