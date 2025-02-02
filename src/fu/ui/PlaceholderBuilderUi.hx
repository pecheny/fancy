package fu.ui;

import fu.ui.Properties.EnabledProp;
import a2d.Placeholder2D;
import a2d.PlaceholderBuilder2D;

class PlaceholderBuilderUi extends PlaceholderBuilder2D {
    var _e:Bool; // enabled property

    /**
        Add EnabledProp
    **/
    public function e() {
        _e = true;
        return this;
    }

    override function reset() {
        super.reset();
        _e = false;
    }

    override function b(name:String = null):Placeholder2D {
        var _e = this._e;
        var ph = super.b(name);
        if (_e)
            EnabledProp.getOrCreate(ph.entity);
        return ph;
    }
}
