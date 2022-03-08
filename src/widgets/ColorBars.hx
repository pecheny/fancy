package widgets;
import al.al2d.LineThicknessCalculator;
import al.al2d.Widget2D;
import data.aliases.AttribAliases;
import gl.sets.ColorSet;
import graphics.shapes.Bar;
import graphics.ShapeWidget;
import mesh.providers.AttrProviders.SolidColorProvider;

class ColorBars extends ShapeWidget<ColorSet> {
    public var q:Bar;
    var color:Int;
    var cp:SolidColorProvider;


    public function new(w:Widget2D, color) {
        this.color = color;
        super(ColorSet.instance, w);
    }

    override function createShapes() {
        var aspectRatio = ratioProvider.getFactorsRef();
        var lineCalc = new LineThicknessCalculator(w, aspectRatio);
        var bb = new BarsBuilder(aspectRatio, lineCalc.lineScales());
        cp = SolidColorProvider.fromInt(color, 128);
        var elements = [
            new BarContainer(FixedThikness(new BarAxisSlot ({pos:.5, thikness:1.}, null)), Portion(new BarAxisSlot ({start:0., end:1.}, null))),
            new BarContainer(FixedThikness(new BarAxisSlot ({pos:0., thikness:1.}, null)), Portion(new BarAxisSlot ({start:0., end:1.}, null)) ),
        ];
        for (e in elements) {
            var sh = bb.create(attrs, fluidTransform.transformValue, e);
            children.push(sh);
        }
    }

    override function onShapesDone() {
        setColor(color);
    }


    public function setColor(c:Int) {
        cp.setColor(c);
        MeshUtilss.writeInt8Attribute(attrs, buffer, AttribAliases.NAME_COLOR_IN, 0, vertsCount, cp.getValue);
    }
}
