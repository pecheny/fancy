package fu.graphics;

import a2d.Placeholder2D;
import a2d.transform.WidgetToScreenRatio;
import gl.AttribSet;
import graphics.shapes.Bar;

class BarWidget<T:AttribSet> extends ShapeWidget<T> {
    public var q:Bar;

    var elements:Array<BarContainer>;
    var bars:Array<Bar>;
    var steps:WidgetToScreenRatio;

    public function new(attrs:T, w:Placeholder2D, elements) {
        this.elements = elements;
        steps = WidgetToScreenRatio.getOrCreate(w.entity, w, 0.05);
        super(attrs, w);
    }

    override function createShapes() {
        var bb = new BarsBuilder(ratioProvider.getAspectRatio(), steps.getRatio());
        bars = [
            for (e in elements) {
                var sh = bb.create(attrs, e);
                addChild(sh);
                sh;
            }
        ];
    }
}