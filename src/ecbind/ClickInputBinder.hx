package ecbind;

import input.core.IPos;
import input.core.ClicksInputSystem.ClickTarget;
import ec.Entity;
import input.core.ClicksInputSystem.ClicksSystem;
import ec.CtxWatcher.CtxBinder;
class ClickInputBinder<T:IPos<T>> implements CtxBinder {
    var system:ClicksSystem<T>;

    public function new(s) {
        this.system = s;
    }

    public function bind(e:Entity):Void {
        var clicks = e.getComponent(ClickTarget);
        if (clicks != null) {
            system.addHandler(clicks);
        }
    }

    public function unbind(e:Entity):Void {
        var clicks = e.getComponent(ClickTarget);
        if (clicks != null) {
            system.removeHandler(clicks);
        }
    }
}
