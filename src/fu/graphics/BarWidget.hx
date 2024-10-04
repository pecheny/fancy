package fu.graphics;

import a2d.Placeholder2D;
import a2d.transform.WidgetToScreenRatio;
import gl.AttribSet;
import graphics.shapes.Bar;
import graphics.shapes.Shape;

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

class ColorBarWidget<T:AttribSet> extends BarWidget<T> {
    var colorer:ShapeColorer<T>;
    var colors:Array<Int> = [];
    var defaultColor:Int;

    public function new(att:T, ph, els, color) {
        colorer = new ShapeColorer(att);
        defaultColor = color;
        super(att, ph, els);
        shapeRenderer.onInit.listen(colorizeAll);
    }

    override function addChild(shape:Shape) {
        super.addChild(shape);
        colorer.addChild(shape);
        if (colors.length < @:privateAccess colorer.shapes.length)
            colors.push(defaultColor);
    }

    public function getColorizeFun(shapeId) {
        if (!inited)
            return (color) -> {
                if (inited)
                    colorer.colorize(shapeRenderer.getBuffer(), shapeId, color);
            }
        else
            return colorer.colorize.bind(shapeRenderer.buffer, shapeId);
    }

    function colorizeAll() {
        for (i in 0...colors.length)
            colorer.colorize(shapeRenderer.buffer, i, colors[i]);
    }

    public function colorize(shapeId, color:Int) {
        colors[shapeId] = color;
        if (inited)
            colorer.colorize(shapeRenderer.buffer, shapeId, color);
    }
}

class ShapeColorer<T:AttribSet> {
    var shapes:Array<Shape> = [];
    var positions:Array<Int> = [];
    var currentPos = 0;
    var att:T;

    public function new(att:T) {
        this.att = att;
    }

    public function addChild(shape:Shape) {
        shapes.push(shape);
        positions.push(currentPos);
        currentPos += shape.getVertsCount();
    }

    public function colorize(buffer, shapeId, color:Int) {
        att.writeColor(buffer, color, positions[shapeId], shapes[shapeId].getVertsCount());
    }
}
