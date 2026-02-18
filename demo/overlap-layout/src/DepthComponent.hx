import openfl.display3D.Context3DCompareMode;
import openfl.geom.Matrix3D;
import data.aliases.AttribAliases;
import ec.PropertyComponent;
import ec.Component;
import graphics.ShapesBuffer;
import gl.AttribSet;
import gl.sets.ColorSet.DepthColorSet;
import al.layouts.OverlapLayout;
import backends.openfl.OpenflBackend.StageImpl;
import a2d.Placeholder2D;
import a2d.PlaceholderBuilder2D;
import a2d.TableWidgetContainer;
import al.core.DataView;
import al.ec.WidgetSwitcher;
import al.layouts.PortionLayout;
import al.openfl.display.FlashDisplayRoot;
import dkit.Dkit.BaseDkit;
import ec.Entity;
import openfl.display.Sprite;

using a2d.ProxyWidgetTransform;
using a2d.transform.LiquidTransformer;
using al.Builder;

class DepthComponent extends PropertyComponent<Float> {}

class DepthAssigner<T:AttribSet> extends Component {
    var attrs:T;
    var buffer:ShapesBuffer<T>;
    var color:Int = -1;
    @:once var depth:DepthComponent;

    public function new(attrs, buffer):Void {
        super(null);
        this.attrs = attrs;
        this.buffer = buffer;
        this.buffer.onInit.listen(fillBuffer);
    }

    override function init() {
        depth.onChange.listen(fillBuffer);
        fillBuffer();
    }

    function fillBuffer() {
        if (!buffer.isInited() || !_inited)
            return;
        trace(depth.value);
        attrs.fillFloat(buffer.getBuffer(), AttribAliases.NAME_DEPTH, depth.value, 0, buffer.getVertCount());
    }
}
