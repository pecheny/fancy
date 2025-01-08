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

    public function new() {
        super();
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
        var gui = new DemoGui(Builder.widget());
        shapes(gui.canvas.ph);
        switcher.switchTo(gui.ph);
    }

    function shapes(ph) {
        var shw = new ShapeWidget(ColorSet.instance, ph);
        var aweights = [];
        // shw.ph.axisStates[horizontal].getPos

        var along = new PortionTransformApplier(aweights);
        // var bar = new Bar(ColorSet.instance, along, along);
        //
        shw.addChild(new Strip(ColorSet.instance, ph));
        new ShapesColorAssigner(ColorSet.instance, 0xff0000, shw.getBuffer());

        return shw;
    }
}

class Strip implements Shape {
    static var inds = IndexCollection.qGrid(4, 2);

    var wwr:WeightedAttWriter;
    var ph:Placeholder2D;
    // var att:AttribSet;

    public function new(att, ph) {
        // this.att = att;
        var writers = att.getWriter(AttribAliases.NAME_POSITION);
        wwr = new WeightedAttWriter(writers);
        this.ph = ph;
    }

    static final cw:ReadOnlyArray<Float> = [0, 1];
    final aw:Array<Float> = [0, 0.5, 0.5, 1];

    public function writePostions(target:haxe.io.Bytes, vertOffset = 0, tr) {
        var w = ph.axisStates[horizontal].getSize();
        var h = ph.axisStates[vertical].getSize();
        var dir = w > h ? horizontal : vertical;
        var cdir = dir.other();
        var so = ph.axisStates[cdir].getSize() / ph.axisStates[dir].getSize();
        aw[1] = so * 0.5;
        aw[2] = 1 - so * 0.5;

        wwr.writeAtts(target, dir, vertOffset, 1, aw, tr);
        wwr.writeAtts(target, dir, vertOffset + aw.length, 1,  aw,tr);
        for (i in 0...aw.length)
            wwr.writeAtts(target, cdir, vertOffset + i, aw.length, cw, tr);
    }

    public function getVertsCount():Int {
        return 8;
    }

    public function getIndices() {
        return inds;
    }
}

class WeightedAttWriter {
    var writers:AttributeWriters;


    public function new(wrs) {
        this.writers = wrs;
    }

    public inline function writeAtts(target, dir:Axis2D, start, offset, weights:ReadOnlyArray<Float>, tr) {
        for (i in 0...weights.length)
            writers[dir].setValue(target, start + i * offset, tr(dir, weights[i]));
    }
}

// class SolidGrid implements Shape {
//     public var weights:AVector2D<Array<Float>>;
//     var writers:AttributeWriters;
//     var weights;
// }
class DemoGui extends BaseDkit {
    static var SRC = <demo-gui hl={PortionLayout.instance}>
        <base(b().h(pfr, 0.25).b()) vl={PortionLayout.instance}>
            // <label(b().h(pfr, 1).v(sfr, 0.1).l().b()) text={ "r1, inner radius" }  />
        </base>
        <base(b().h(pfr, 1).l().b()) public id="canvas">
        // ${fui.quad(__this__.ph, 0xff0000)}
        </base>
    </demo-gui>
}

// class ArrayAxisApplier implements AxisApplier {
//     var target:Array<Float>;
//     var ph:Placeholder2D;
//     public function new(ph, target) {
//         this.ph = ph;
//         this.target = target;
//     }
//     public function apply(pos:Float, size:Float) {}
// }
