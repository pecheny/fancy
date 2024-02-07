package update;

import ec.Entity;
import ec.CtxWatcher.CtxBinder;

class UpdateBinder implements CtxBinder {
    var updater:Updater;

    public function new(updater:Updater) {
        this.updater = updater;
    }

    public function bind(e:Entity) {
        var u = e.getComponent(Updatable);
        if (u != null)
            updater.addUpdatable(u);
    }

    public function unbind(e:Entity) {
        var u = e.getComponent(Updatable);
        updater.removeUpdatable(u);
    }
}
