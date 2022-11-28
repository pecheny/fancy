package update;
import update.Updatable;
interface Updater {
    public function addUpdatable(e:Updatable):Void;
    public function removeUpdatable(e:Updatable):Void;
}
