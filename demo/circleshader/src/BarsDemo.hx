import Axis2D;
import SquareShape;
import a2d.Placeholder2D;
import al.Builder;
import al.ec.WidgetSwitcher;
import data.IndexCollection;
import data.aliases.AttribAliases;
import dkit.Dkit.BaseDkit;
import ec.Entity;
import fu.graphics.ShapeWidget;
import gl.AttribSet;
import gl.ValueWriter;
import gl.sets.CircleSet;
import graphics.ShapesColorAssigner;
import graphics.shapes.Shape;
import haxe.io.Bytes;
import macros.AVConstructor;
import openfl.display.Sprite;

class BarsDemo extends Sprite {
    public var fui:FuiBuilder;
    public var switcher:WidgetSwitcher<Axis2D>;

    var attrs = CircleSet.instance;
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

    function shapes(ph) {
        fui.lqtr(ph);
        var shw = new ShapeWidget(attrs, ph);
        var s = new Strip(attrs, ph);
        shw.addChild(s);
        new ShapesColorAssigner(attrs, 0x320078, shw.getBuffer());
        s.writeAttributes = new PhAntialiasing(attrs, ph, fui.ar.getWindowSize()).writePostions;
        var uvs = new graphics.DynamicAttributeAssigner(attrs, shw.getBuffer());
        uvs.fillBuffer = (attrs, buffer) -> {
            var vertOffset = 0;
            var writers = attrs.getWriter(AttribAliases.NAME_UV_0);
            var wwr = new WeightedAttWriter(writers, AVConstructor.create([0, 0.5, 0.5, 1], [0., 1]));
            wwr.writeAtts(buffer.getBuffer(), vertOffset, (_, v) -> v);
            var rad = new RadiusAtt(attrs, buffer.getVertCount());
            rad.writePostions(buffer.getBuffer(), 0, null);
            gui.r1Changed.listen(v -> {
                rad.r1 = v;
                rad.writePostions(buffer.getBuffer(), 0, null);
            });
            gui.r2Changed.listen(v -> {
                rad.r2 = v;
                rad.writePostions(buffer.getBuffer(), 0, null);
            });
        };

        return shw;
    }
}

@:access(SquareShape)
class PhAntialiasing<T:AttribSet> {
    var att:T;
    var ph:Placeholder2D;
    var screenSize:ReadOnlyAVector2D<Int>;
    var smoothness = 6.;

    public function new(att, ph, screen) {
        this.att = att;
        this.ph = ph;
        this.screenSize = screen;
    }

    public function writePostions(target:Bytes, vertOffset = 0, transformer) {
        var s = Math.min(ph.axisStates[horizontal].getSize(), ph.axisStates[vertical].getSize());
        var aasize = smoothness / (s * screenSize[horizontal]);
        att.fillFloat(target, CircleSet.AASIZE_IN, aasize, vertOffset, 4);
    }
}

class Strip implements Shape {
    static var inds = IndexCollection.qGrid(4, 2);

    var wwr:WeightedAttWriter;
    var ph:Placeholder2D;
    var att:AttribSet;

    public function new(att, ph) {
        this.att = att;
        var writers = att.getWriter(AttribAliases.NAME_POSITION);
        wwr = new WeightedAttWriter(writers, AVConstructor.create([0, 0.5, 0.5, 1], [0., 1]));
        this.ph = ph;
    }

    public function writePostions(target:haxe.io.Bytes, vertOffset = 0, tr) {
        var w = ph.axisStates[horizontal].getSize();
        var h = ph.axisStates[vertical].getSize();
        var dir = w > h ? horizontal : vertical;
        wwr.direction = dir;
        var cdir = dir.other();
        var so = ph.axisStates[cdir].getSize() / ph.axisStates[dir].getSize();
        var aw = wwr.weights[horizontal];
        aw[1] = so * 0.5;
        aw[2] = 1 - so * 0.5;
        wwr.writeAtts(target, vertOffset, tr);
        writeAttributes(target, vertOffset, tr);
    }

    public dynamic function writeAttributes(target:Bytes, vertOffset = 0, transformer) {}

    public function getVertsCount():Int {
        return 8;
    }

    public function getIndices() {
        return inds;
    }
}

class WeightedAttWriter {
    var writers:AttributeWriters;

    public var direction:Axis2D = horizontal;
    public var weights:AVector2D<Array<Float>>;

    public function new(wrs, wghs:AVector2D<Array<Float>>) {
        this.writers = wrs;
        this.weights = wghs;
    }

    public inline function writeAtts(target, vertOffset, tr) {
        var aw = weights[horizontal];
        var cw = weights[vertical];
        for (i in 0...cw.length)
            writeLine(target, direction, vertOffset + aw.length * i, 1, aw, tr);
        for (i in 0...aw.length) {
            writeLine(target, direction.other(), vertOffset + i, aw.length, cw, tr);
        }
    }

    public inline function writeLine(target, dir:Axis2D, start, offset, weights, tr) {
        for (i in 0...weights.length)
            writers[dir].setValue(target, start + i * offset, tr(dir, weights[i]));
    }
}

// class SolidGrid implements Shape {
//     public var weights:AVector2D<Array<Float>>;
//     var writers:AttributeWriters;
//     var weights;
// }
// class ArrayAxisApplier implements AxisApplier {
//     var target:Array<Float>;
//     var ph:Placeholder2D;
//     public function new(ph, target) {
//         this.ph = ph;
//         this.target = target;
//     }
//     public function apply(pos:Float, size:Float) {}
// }
