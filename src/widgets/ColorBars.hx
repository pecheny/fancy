package widgets;
import al.al2d.Widget2D;
import al.core.AxisApplier;
import Axis2D;
import data.aliases.AttribAliases;
import gl.sets.ColorSet;
import graphics.shapes.Bar;
import widgets.ShapeWidget;
import macros.AVConstructor;
import mesh.MeshUtilss;
import mesh.providers.AttrProviders.SolidColorProvider;
import transform.LineThicknessCalculator;

class ColorBars extends ShapeWidget<ColorSet> {
    public var q:Bar;
    var color:Int;
    var cp:SolidColorProvider;
    var elements:Array<BarContainer>;
    var bars:Array<Bar>;


    public function new(w:Widget2D, color, elements) {
        this.color = color;
        this.elements = elements;
        super(ColorSet.instance, w);
    }

    override function createShapes() {
        var aspectRatio = ratioProvider.getFactorsRef();
        var lineCalc = new LineThicknessCalculator(aspectRatio);
        var aa = new Axis2DApplier(lineCalc);
        for (a in Axis2D)
            w.axisStates[a].addSibling(aa.appliers[a]);
        var bb = new BarsBuilder(aspectRatio, lineCalc.lineScales());
        cp = SolidColorProvider.fromInt(color, 128);
        bars = [ for (e in elements) {
            var sh = bb.create(attrs, e);
            addChild(sh);
            sh;
        } ];
    }

    override function onShapesDone() {
        setColor(color);
    }


    public function setColor(c:Int) {
        cp.setColor(c);
        MeshUtilss.writeInt8Attribute(attrs, @:privateAccess shapeRenderer.buffer, AttribAliases.NAME_COLOR_IN, 0, shapeRenderer.getVertCount(), cp.getValue);
    }
}
class Axis2DApplier {
    public var appliers(default, null):ReadOnlyAVector2D<StorageAxisApplier>;
    var target:LineThicknessCalculator;

    public function new(lthc):Void {
        this.target = lthc;
        appliers = AVConstructor.factoryCreate(Axis2D, a -> new StorageAxisApplier(this));
    }

    public function refresh() {
        target.resize(appliers[Axis2D.horizontal].size, appliers[vertical].size);
    }
}

class StorageAxisApplier implements AxisApplier {
    public var pos:Float;
    public var size:Float;
    var target:Axis2DApplier;

    public function new(t) {
        this.target = t;
    }

    public function apply(pos:Float, size:Float):Void {
        this.pos = pos;
        this.size = size;
        target.refresh();
    }
}


