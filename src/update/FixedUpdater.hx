package update;
import update.Updatable;
import update.Updater;
class FixedUpdater implements Updater {
    var updatables:Array<Updatable> = [];
    var step:Float;

    public function new(step = 1 / 60) {
        this.step = step;
    }

    public function update() {
        for (u in updatables)
            u.update(step);
    }

    public function addUpdatable(e:Updatable):Void {
        updatables.push(e);
    }

    public function removeUpdatable(e:Updatable):Void {
        updatables.remove(e);
    }
}
