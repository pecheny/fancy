package;

import gl.sets.CircleSet;
import gl.ValueWriter;
import Axis2D;
import a2d.Placeholder2D;
import a2d.transform.WidgetToScreenRatio;
import data.IndexCollection;
import data.aliases.AttribAliases;
import fu.bootstrap.WidgetTester;
import fu.graphics.ShapeWidget;
import gl.AttribSet;
import gl.ValueWriter.AttributeWriters;
import gl.sets.ColorSet;
import graphics.shapes.Shape;
import haxe.ds.ReadOnlyArray;
import haxe.io.Bytes;
import macros.AVConstructor;

using a2d.transform.LiquidTransformer;
using al.Builder;

class SquaresDemo extends CircleShaderDemo {
    public function new() {
        super();
        var wdg = quads(fui.placeholderBuilder.h(sfr, 1).v(sfr, 1).b(), 0x6a00ff);
        switcher.switchTo(wdg.ph);
    }

    public function quads(ph:Placeholder2D, color) {
        fui.lqtr(ph);
        var attrs = CircleSet.instance;
        var steps = WidgetToScreenRatio.getOrCreate(ph.entity, ph, 0.15);

        var shw = new ShapeWidget(attrs, ph, true);

        var n = 3;
        var squv = new SquareUV(attrs);
        var rad = new RadiusAtt(attrs);
        for (i in 0...n)
            shw.addChild(new SquareShape(attrs, steps.getRatio(), Math.random(), Math.random())
            .withAtt(squv.writePostions)
            .withAtt(rad.writePostions)
        );

        shw.manInit();
        return shw;
    }
}

class RadiusAtt<T:AttribSet> {
    var att:T;

    public function new(att) {
        this.att = att;
    }

    public function writePostions(target:Bytes, vertOffset = 0, transformer) {
        for (i in 0...4) {
            att.fillFloat(target, CircleSet.R1_IN, 0.3, vertOffset, 4);
            att.fillFloat(target, CircleSet.R2_IN, 0.9, vertOffset, 4);
        }
    }

}

class SquareUV<T:AttribSet> {
    var att:T;
    var writers:Array<IValueWriter>;
    // var values:Array<Float> = [0, 0, 1, 0, 1, 1, 0, 1];
    var values:Array<Float> = [0, 0, 0,1, 1, 0, 1,1];

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
        // weights = RectWeights.identity();
        // var writers:AttributeWriters;
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
