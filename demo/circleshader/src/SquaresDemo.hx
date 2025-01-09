package;

import Axis2D;
import a2d.Placeholder2D;
import a2d.transform.WidgetToScreenRatio;
import al.ec.WidgetSwitcher;
import al.layouts.PortionLayout;
import data.IndexCollection;
import data.aliases.AttribAliases;
import dkit.Dkit.BaseDkit;
import ec.Entity;
import fu.Signal;
import fu.graphics.ShapeWidget;
import fu.graphics.Slider;
import gl.AttribSet;
import gl.ValueWriter;
import gl.sets.CircleSet;
import graphics.ShapesColorAssigner;
import graphics.shapes.Shape;
import haxe.ds.ReadOnlyArray;
import haxe.io.Bytes;
import macros.AVConstructor;
import openfl.display.Sprite;

using a2d.transform.LiquidTransformer;
using al.Builder;

class SquaresDemo extends Sprite {
    public var fui:FuiBuilder;
    public var switcher:WidgetSwitcher<Axis2D>;

    var gui:DemoGui;
    public function new() {
        super();
        fui = new FuiBuilder();
        BaseDkit.inject(fui);
        var root:Entity = fui.createDefaultRoot();
        var uikit = new FlatUikitExtended(fui);
        uikit.configure(root);
        uikit.createContainer(root);

        switcher = root.getComponent(WidgetSwitcher);

        gui = new DemoGui(Builder.widget());
        shapes(gui.canvas.ph);
        switcher.switchTo(gui.ph);
    }

    var squares:Array<SquareShape<CircleSet>> = [];

    public function shapes(ph:Placeholder2D) {
        fui.lqtr(ph);
        var attrs = CircleSet.instance;
        var steps = WidgetToScreenRatio.getOrCreate(ph.entity, ph, 0.5);

        var shw = new ShapeWidget(attrs, ph, true);

        var n = 3;
        var squv = new SquareUV(attrs);
        var rad = new RadiusAtt(attrs);
        for (i in 0...n) {
            var sq = new SquareShape(attrs, steps.getRatio(), Math.random(), Math.random());
            sq.withAtt(squv.writePostions).withAtt(squv.writePostions).withAtt(rad.writePostions);
            sq.withAtt(new SquareAntialiasing(attrs, sq, fui.ar.getWindowSize()).writePostions);
            shw.addChild(sq);
            squares.push(sq);
        }
        
        // var lastSq = squares[n-1];
        
        gui.r1Changed.listen(v -> rad.r1 = v);
        gui.r2Changed.listen(v -> rad.r2 = v);
        shw.manInit();
        new ShapesColorAssigner(attrs, 0xff0000, shw.getBuffer());
        return shw;
    }
}


@:access(SquareShape)
class SquareAntialiasing<T:AttribSet> {
    var att:T;
    var square:SquareShape<T>;
    var screenSize:ReadOnlyAVector2D<Int>;
    var smoothness = 6.;

    public function new(att, square, screen) {
        this.att = att;
        this.square = square;
        this.screenSize = screen;
    }

    public function writePostions(target:Bytes, vertOffset = 0, transformer) {
        var aasize = smoothness / (square.size * square.lineScales[horizontal] * screenSize[horizontal]);
        att.fillFloat(target, CircleSet.AASIZE_IN, aasize, vertOffset, 4);
    }
}

class RadiusAtt<T:AttribSet> {
    var att:T;
    public var r1 = 0.3;
    public var r2 = 0.9;

    public function new(att) {
        this.att = att;
    }

    public function writePostions(target:Bytes, vertOffset = 0, transformer) {
        att.fillFloat(target, CircleSet.R1_IN, r1, vertOffset, 4);
        att.fillFloat(target, CircleSet.R2_IN, r2, vertOffset, 4);
    }
}

class SquareUV<T:AttribSet> {
    var att:T;
    var writers:Array<IValueWriter>;
    var values:Array<Float> = [0, 0, 0, 1, 1, 0, 1, 1];

    public function new(att) {
        this.att = att;
        writers = att.getWriter(AttribAliases.NAME_UV_0);
    }

    public function writePostions(target:Bytes, vertOffset = 0, transformer) {
        for (i in 0...4) {
            writers[0].setValue(target, vertOffset + i, values[i * 2]);
            writers[1].setValue(target, vertOffset + i, values[i * 2 + 1]);
        }
    }
}

class SquareShape<T:AttribSet> implements Shape {
    var pos:AVector2D<Float>;
    var writers:AttributeWriters;
    var size:Float;
    var lineScales:ReadOnlyAVector2D<Float>;

    static var weights:ReadOnlyAVector2D<ReadOnlyArray<Float>> = AVConstructor.create([-0.5, -0.5, 0.5, 0.5], [-0.5, 0.5, -0.5, 0.5]);

    public function new(attrs:T, lineScales, x, y, size = 1) {
        this.size = size;
        this.lineScales = lineScales;
        this.pos = AVConstructor.create(x, y);
        this.writers = attrs.getWriter(AttribAliases.NAME_POSITION);
    }

    public inline function getIndices():IndexCollection {
        return IndexCollections.QUAD_ODD;
    }

    public function writePostions(target:Bytes, vertOffset = 0, transformer) {
        inline function writeAxis(axis:Axis2D, i) {
            var vpos = pos[axis] + weights[axis][i] * size * lineScales[axis];
            writers[axis].setValue(target, vertOffset + i, transformer(axis, vpos));
        }
        for (i in 0...4) {
            writeAxis(horizontal, i);
            writeAxis(vertical, i);
        }

        writeAttributes(target, vertOffset, transformer);
    }

    function writeAttributes(target:Bytes, vertOffset = 0, transformer) {
        for (a in moreAttribs)
            a(target, vertOffset, transformer);
    }

    var moreAttribs:Array<(Bytes, Int, Transformer) -> Void> = [];

    public function withAtt(a) {
        moreAttribs.push(a);
        return this;
    }

    public function getVertsCount():Int {
        return 4;
    }
}
