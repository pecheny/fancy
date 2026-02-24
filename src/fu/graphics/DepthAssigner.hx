package fu.graphics;

import al.prop.DepthComponent;
import data.aliases.AttribAliases;
import ec.Component;
import gl.AttribSet;
import graphics.ShapesBuffer;

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
        attrs.fillFloat(buffer.getBuffer(), AttribAliases.NAME_DEPTH, depth.value, 0, buffer.getVertCount());
    }
}
