package widgets;
import al.al2d.Widget2D;
import data.aliases.AttribAliases;
import gl.sets.ColorSet;
import graphics.shapes.QuadGraphicElement;
import widgets.ShapeWidget;
import haxe.io.Bytes;
import mesh.MeshUtilss;
import mesh.providers.AttrProviders.SolidColorProvider;

class ColouredQuad extends ShapeWidget<ColorSet> {
    public var q:QuadGraphicElement<ColorSet>;
    var color:Int;
    var cp:SolidColorProvider;

    public function new(w:Widget2D, color) {
        this.color = color;
//        buffer = Bytes.alloc(4 * ColorSet.instance.stride);
//        posWriter = ColorSet.instance.getWriter(AttribAliases.NAME_POSITION);
        cp = SolidColorProvider.fromInt(color, 128);
        super(ColorSet.instance, w);
    }

    override function createShapes() {
        var q = new QuadGraphicElement(ColorSet.instance);
        addChild(q);
    }

    override function onShapesDone() {
        setColor(color);
    }


    public function setColor(c:Int) {
        color = c;
        if (!inited)
            return;
        cp.setColor(c);
        MeshUtilss.writeInt8Attribute(attrs, @:privateAccess shapeRenderer.buffer, AttribAliases.NAME_COLOR_IN, 0, shapeRenderer.getVertCount(), cp.getValue);
    }
}
