import haxe.io.Bytes;
import gl.sets.CircleSet;
import macros.AVConstructor;
import haxe.ds.ReadOnlyArray;
import gl.AttribSet;
import Axis2D;
import a2d.Placeholder2D;
import al.Builder;
import al.ec.WidgetSwitcher;
import al.layouts.PortionLayout;
import data.IndexCollection;
import data.aliases.AttribAliases;
import dkit.Dkit.BaseDkit;
import ec.Entity;
import fu.graphics.ShapeWidget;
import gl.ValueWriter.AttributeWriters;
import gl.sets.ColorSet;
import graphics.ShapesColorAssigner;
import graphics.shapes.Bar;
import graphics.shapes.Shape;
import openfl.display.Sprite;

class BarsDemo extends Sprite {
    public var fui:FuiBuilder;
    public var switcher:WidgetSwitcher<Axis2D>;

    var attrs = CircleSet.instance;
    var gui:DemoGui;

    public function new() {
        super();
        trace("foo");
        var kbinder = new utils.KeyBinder();
        kbinder.addCommand(openfl.ui.Keyboard.A, () -> {
            ec.DebugInit.initCheck.dispatch();
        });
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
        var shw = new ShapeWidget(attrs, ph);
        var aweights = [];
        // shw.ph.axisStates[horizontal].getPos

        // var along = new PortionTransformApplier(aweights);
        // var bar = new Bar(ColorSet.instance, along, along);
        //
        var s = new Strip(attrs, ph);
        shw.addChild(s);
        s.writeAttributes = new PhAntialiasing(attrs, ph, fui.ar.getWindowSize()).writePostions;
        new ShapesColorAssigner(attrs, 0xff0000, shw.getBuffer());

        var uvs = new graphics.DynamicAttributeAssigner(attrs, shw.getBuffer());
        uvs.fillBuffer = (attrs, buffer) -> {
            var vertOffset = 0;
            var writers = attrs.getWriter(AttribAliases.NAME_UV_0);
            var wwr = new WeightedAttWriter(writers, AVConstructor.create([0, 0.5, 0.5, 1], [0., 1]));
            wwr.writeAtts(buffer.getBuffer(), vertOffset, (_, v) -> v);
            var rad = new RadiusAtt(attrs);
            rad.writePostions(buffer.getBuffer());
            gui.r1Changed.listen(v -> {
                rad.r1 = v;
                rad.writePostions(buffer.getBuffer());
            });
            gui.r2Changed.listen(v -> {
                rad.r2 = v;
                rad.writePostions(buffer.getBuffer());
            });


            // attrs.fillFloat(buffer.getBuffer(), CircleSet.AASIZE_IN, 1, vertOffset, 4);

            for (i in 0...8)
                trace(attrs.printVertex(buffer.getBuffer(), i));
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

class RadiusAtt<T:AttribSet> {
    var att:T;

    public var r1 = 0.3;
    public var r2 = 0.9;

    public function new(att) {
        this.att = att;
    }

    public function writePostions(target:Bytes, vertOffset = 0) {
        att.fillFloat(target, CircleSet.R1_IN, r1, vertOffset, 4);
        att.fillFloat(target, CircleSet.R2_IN, r2, vertOffset, 4);
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

    // final cw:ReadOnlyArray<Float> = [0, 1];
    // final aw:Array<Float> = [0, 0.5, 0.5, 1];

    public function writePostions(target:haxe.io.Bytes, vertOffset = 0, tr) {
        var w = ph.axisStates[horizontal].getSize();
        var h = ph.axisStates[vertical].getSize();
        var dir = w > h ? horizontal : vertical;
        wwr.direction = dir;
        var cdir = dir.other();
        var so = ph.axisStates[cdir].getSize() / ph.axisStates[dir].getSize();
        var aw = wwr.weights[horizontal];
        // var cw = wwr.weights[cdir];
        aw[1] = so * 0.5;
        aw[2] = 1 - so * 0.5;
        wwr.writeAtts(target, vertOffset, tr);
        writeAttributes(target, vertOffset, tr);
        // wwr.writeAtts(target, dir, vertOffset, 1, tr);
        // wwr.writeAtts(target, dir, vertOffset + aw.length, 1, tr);
        // for (i in 0...aw.length)
        //     wwr.writeAtts(target, cdir, vertOffset + i, aw.length, tr);
        // for (i in 0...8)
        //     trace(att.printVertex(target, i));
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

    public function new(wrs, wghs) {
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
