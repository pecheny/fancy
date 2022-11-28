package update;
import update.Updater;
import update.Updatable;
class RealtimeUpdater implements Updater {
    var last:Float;
    var timeMultiplier:Float = 1;
    var updatables:Array<Updatable> = [];

    inline static var maxElapsed = 0.016666666;

    public function new() {
    }

    public function update():Void {
        var time = haxe.Timer.stamp();
        var elapsed = (time - last);
        if (elapsed > maxElapsed) elapsed = maxElapsed;
        last = time;
        for (u in updatables)
            u.update(elapsed * timeMultiplier);
    }

    public function addUpdatable(e:Updatable):Void {
        updatables.push(e);
    }

    public function removeUpdatable(e:Updatable):Void {
        updatables.remove(e);
    }
}