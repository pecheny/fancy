package ecbind;

import ec.CtxWatcher.CtxBinder;
import ec.Entity;
import shimp.IPos;
import shimp.InputSystem;
class InputBinder<T:IPos<T>> implements CtxBinder {
    var system:InputSystem<T>;
    var e:Entity;

    public function new(s, e:Entity = null) {
        this.system = s;
        this.e = e;
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

    public function toString() {
        return 'Binder for $system, ${e?.name}';
    }
}
