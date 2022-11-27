package widgets;
import al.al2d.Placeholder2D;
import al.core.AxisApplier;
import Axis2D;
import gl.AttribSet;
import graphics.shapes.Bar;
import macros.AVConstructor;
import transform.LineThicknessCalculator;
import widgets.ShapeWidget;

class BarWidget<T:AttribSet> extends ShapeWidget<T> {
    public var q:Bar;
    var elements:Array<BarContainer>;
    var bars:Array<Bar>;

    public function new(attrs:T, w:Placeholder2D, elements) {
        this.elements = elements;
        super(attrs, w);
    }

    override function createShapes() {
        var aspectRatio = ratioProvider.getAspectRatio();
        var lineCalc = new LineThicknessCalculator(aspectRatio);
        var aa = new Axis2DApplier(lineCalc);
        for (a in Axis2D)
            w.axisStates[a].addSibling(aa.appliers[a]);
        var bb = new BarsBuilder(aspectRatio, lineCalc.lineScales());
        bars = [ for (e in elements) {
            var sh = bb.create(attrs, e);
            addChild(sh);
            sh;
        } ];
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


