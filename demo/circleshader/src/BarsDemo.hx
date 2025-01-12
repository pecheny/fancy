import graphics.shapes.WeightedAttWriter;
import Axis2D;
import SquareShape;
import a2d.Placeholder2D;
import a2d.Widget;
import a2d.transform.WidgetToScreenRatio;
import al.Builder;
import al.core.AxisApplier;
import al.ec.WidgetSwitcher;
import data.IndexCollection;
import data.aliases.AttribAliases;
import dkit.Dkit.BaseDkit;
import ec.Entity;
import fu.graphics.BarWidget;
import fu.graphics.ShapeWidget;
import gl.AttribSet;
import gl.ValueWriter;
import gl.sets.CircleSet;
import gl.sets.ColorSet;
import graphics.ShapesColorAssigner;
import graphics.shapes.Bar;
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
        ngrid(gui.canvas.ph, true);
        ngrid(gui.canvas.ph);
        shapes(gui.ph);
        createBarWidget(gui.canvas.ph);
        switcher.switchTo(gui.ph);
    }

    function ngrid(ph, fill = false) {
        fui.lqtr(ph);
        // var attrs = ColorSet.instance;
        var steps = WidgetToScreenRatio.getOrCreate(ph.entity, ph, 0.05);
        var cornerSize = 3;
        var shw = new ShapeWidget(attrs, ph);
        var s = new NineGrid(attrs, ph, cornerSize);
        shw.addChild(s);
        new ShapesColorAssigner(attrs, 0x776A00FF, shw.getBuffer());
        s.writeAttributes = new PhAntialiasing(attrs, ph, fui.ar.getWindowSize()).writePostions;
        var uvs = new graphics.DynamicAttributeAssigner(attrs, shw.getBuffer());
        uvs.fillBuffer = (attrs, buffer) -> {
            var vertOffset = 0;
            var writers = attrs.getWriter(AttribAliases.NAME_UV_0);
            var wwr = new WeightedAttWriter(writers, AVConstructor.create([0, 0.4999, 0.50001, 1], [0, 0.4999, 0.50001, 1]));
            wwr.writeAtts(buffer.getBuffer(), vertOffset, (_, v) -> v);
            var rad = new RadiusAtt(attrs, buffer.getVertCount());
            rad.r2 = 1;
            rad.r1 = 1 - (1 / cornerSize);
            rad.r1 *= rad.r1;
            if (fill)
                rad.r1 = 0;
            rad.writePostions(buffer.getBuffer(), 0, null);
        };

        return shw;
    }

    function shapes(ph) {
        fui.lqtr(ph);
        var steps = WidgetToScreenRatio.getOrCreate(ph.entity, ph, 0.05);

        var shw = new ShapeWidget(attrs, ph);
        var writers = attrs.getWriter(AttribAliases.NAME_POSITION);
        var wwr = new WeightedAttWriter(writers, AVConstructor.create([0, 0.5, 0.5, 1], [0., 1]));
        var s = new Strip(attrs, ph, wwr);
        var sa = new StripAxisApplier(ph, wwr);
        ph.axisStates[vertical].addSibling(sa);
        shw.addChild(s);
        new ShapesColorAssigner(attrs, 0x776A00FF, shw.getBuffer());
        s.writeAttributes = new PhAntialiasing(attrs, ph, fui.ar.getWindowSize()).writePostions;
        var uvs = new graphics.DynamicAttributeAssigner(attrs, shw.getBuffer());
        uvs.fillBuffer = (attrs, buffer) -> {
            var vertOffset = 0;
            var writers = attrs.getWriter(AttribAliases.NAME_UV_0);
            var wwr = new WeightedAttWriter(writers, AVConstructor.create([0, 0.5, 0.5, 1], [0., 1]));
            wwr.writeAtts(buffer.getBuffer(), vertOffset, (_, v) -> v);
            var rad = new RadiusAtt(attrs, buffer.getVertCount());
            rad.writePostions(buffer.getBuffer(), 0, null);
            // gui.r1Changed.listen(v -> {
            //     rad.r1 = v*v;
            //     rad.writePostions(buffer.getBuffer(), 0, null);
            // });
            // gui.r2Changed.listen(v -> {
            //     rad.r2 = v*v;
            //     rad.writePostions(buffer.getBuffer(), 0, null);
            // });
            new CircleThicknessCalculator(ph, steps, rad, buffer.getBuffer());
        };

        return shw;
    }

    function createBarWidget(ph) {
        var elements = () -> [
            new BarContainer(Portion(new BarAxisSlot({start: 0., end: 1.}, null)), FixedThikness(new BarAxisSlot({pos: .0, thikness: 1.}, null))),
            new BarContainer(FixedThikness(new BarAxisSlot({pos: 1., thikness: 1.}, null)), Portion(new BarAxisSlot({start: 0., end: 1.}, null))),
        ];

        var attrs = ColorSet.instance;
        var cq = new BarWidget(attrs, ph, elements());
        var colors = new ShapesColorAssigner(attrs, 0, cq.getBuffer());
        return cq;
    }
}

/**
 * Calclulates r attribute values for shape assuming the UVs are normal in Placeholder's normal space.
**/
class CircleThicknessCalculator implements AxisApplier {
    var ph:Placeholder2D;
    var steps:WidgetToScreenRatio;
    var rads:RadiusAtt<CircleSet>;
    var buffer:Bytes;

    public var thikness:Float = 1.;

    public function new(ph, steps, rads, b) {
        this.ph = ph;
        this.rads = rads;
        this.steps = steps;
        this.buffer = b;
        ph.axisStates[vertical].addSibling(this);
    }

    public function apply(pos:Float, size:Float) {
        calculateRadius();
    }

    public function calculateRadius() {
        rads.r2 = 1;
        var w = ph.axisStates[horizontal].getSize();
        var h = ph.axisStates[vertical].getSize();
        var dir = w < h ? horizontal : vertical;
        var r = 1 - 2 * steps.getRatio()[dir]; // * (ph.axisStates[dir].getSize() * thikness);
        rads.r1 = r * r;
        rads.writePostions(buffer, 0, null);
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

class NineGrid implements Shape extends Widget implements AxisApplier {
    static var inds = IndexCollection.qGrid(4, 4);

    var cornerScale = 2;

    var wwr:WeightedAttWriter;
    var att:AttribSet;
    var wtsr:WidgetToScreenRatio;
    var weights:AVector2D<Array<Float>> = AVConstructor.create([0, 0.5, 0.5, 1], [0, 0.5, 0.5, 1]);

    public function new(att, ph:Placeholder2D, cornerScale) {
        super(ph);
        this.att = att;
        this.cornerScale = cornerScale;
        wtsr = WidgetToScreenRatio.getOrCreate(ph.entity, ph, 1);
        var writers = att.getWriter(AttribAliases.NAME_POSITION);
        wwr = new WeightedAttWriter(writers, weights);
        ph.axisStates[vertical].addSibling(this);
    }

    public function writePostions(target:haxe.io.Bytes, vertOffset = 0, tr) {
        wwr.writeAtts(target, vertOffset, tr);
        writeAttributes(target, vertOffset, tr);
    }

    public dynamic function writeAttributes(target:Bytes, vertOffset = 0, transformer) {}

    public function getIndices():IndexCollection {
        return inds;
    }

    public function getVertsCount():Int {
        return 16;
    }

    public function apply(pos:Float, size:Float) {
        var ratio = wtsr.getRatio();
        for (a in Axis2D) {
            weights[a][1] = Math.min(cornerScale * ratio[a], 0.5);
            weights[a][2] = Math.max(1 - cornerScale * ratio[a], 0.5);
        }
    }
}

class StripAxisApplier implements AxisApplier {
    var wwr:WeightedAttWriter;
    var ph:Placeholder2D;
    public function new(ph, wwr) {
        this.ph = ph;
        this.wwr = wwr;
    }

    public function apply(pos:Float, size:Float) {
        var w = ph.axisStates[horizontal].getSize();
        var h = ph.axisStates[vertical].getSize();
        var dir = w > h ? horizontal : vertical;
        wwr.direction = dir;
        var cdir = dir.other();
        var so = ph.axisStates[cdir].getSize() / ph.axisStates[dir].getSize();
        var aw = wwr.weights[horizontal];
        aw[1] = so * 0.5;
        aw[2] = 1 - so * 0.5;
    }
}

class Strip implements Shape {
    static var inds = IndexCollection.qGrid(4, 2);

    var wwr:WeightedAttWriter;
    var ph:Placeholder2D;
    var att:AttribSet;

    public function new(att, ph, wwr) {
        this.att = att;
        this.wwr = wwr;
        this.ph = ph;
    }

    public function writePostions(target:haxe.io.Bytes, vertOffset = 0, tr) {
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
