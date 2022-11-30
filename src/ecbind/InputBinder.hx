package ecbind;

import ec.CtxWatcher.CtxBinder;
import ec.Entity;
import shimp.IPos;
import shimp.InputSystem;
class InputBinder<T:IPos<T>> implements CtxBinder {
    var system:InputSystem<T>;

    public function new(s) {
        this.system = s;
    }

    public function bind(e:Entity):Void {
        var clicks = e.getComponent(InputSystemTarget);
        if (clicks != null) {
            system.addChild(clicks);
        }
    }

    public function unbind(e:Entity):Void {
        var clicks = e.getComponent(InputSystemTarget);
        if (clicks != null) {
            system.removeChild(clicks);
        }
    }
}
