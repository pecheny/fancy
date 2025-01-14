import Axis2D;
import SquareShape;
import a2d.transform.WidgetToScreenRatio;
import al.Builder;
import al.appliers.ContainerRefresher;
import al.ec.WidgetSwitcher;
import data.aliases.AttribAliases;
import dkit.Dkit.BaseDkit;
import ec.Entity;
import fu.graphics.BarWidget;
import fu.graphics.ShapeWidget;
import gl.sets.CircleSet;
import gl.sets.ColorSet;
import graphics.ShapesColorAssigner;
import graphics.shapes.Bar;
import graphics.shapes.WeightedAttWriter;
import graphics.shapes.WeightedGrid;
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
        // ngrid(gui.canvas.ph, true);
        ngrid(gui.canvas.ph);
        shapes(gui.ph);
        createBarWidget(gui.canvas.ph);
        switcher.switchTo(gui.ph);
    }

    function ngrid(ph) {
        fui.lqtr(ph);
        var steps = WidgetToScreenRatio.getOrCreate(ph.entity, ph, 0.05);
        var cornerSize = 3;
        var shw = new ShapeWidget(attrs, ph);
        var writers = attrs.getWriter(AttribAliases.NAME_POSITION);

        var wwr = new WeightedAttWriter(writers, AVConstructor.create([0, 0.5, 0.5, 1], [0, 0.5, 0.5, 1]));
        var s = new WeightedGrid(wwr);
        var sa = new NGridWeightsWriter(wwr.weights, steps.getRatio(), cornerSize);
        ph.axisStates[vertical].addSibling(new ContainerRefresher(sa));
        shw.addChild(s);
        new ShapesColorAssigner(attrs, 0x77BA89FF, shw.getBuffer());
        // s.writeAttributes = new PhAntialiasing(attrs,  s.getVertsCount()).writePostions;
        var uvs = new graphics.DynamicAttributeAssigner(attrs, shw.getBuffer());
        uvs.fillBuffer = (attrs, buffer) -> {
            var vertOffset = 0;
            var writers = attrs.getWriter(AttribAliases.NAME_UV_0);
            var wwr = new WeightedAttWriter(writers, AVConstructor.create([0, 0.4999, 0.50001, 1], [0, 0.4999, 0.50001, 1]));
            wwr.writeAtts(buffer.getBuffer(), vertOffset, (_, v) -> v);
            var rad = new RadiusAtt(attrs, buffer.getVertCount());
            rad.r1 = 0;
            rad.r2 = 1;
            rad.r1 = 1 - (1 / cornerSize);
            rad.r1 *= rad.r1;

            rad.writePostions(buffer.getBuffer(), 0, null);
        };

        return shw;
    }

    function shapes(ph) {
        fui.lqtr(ph);
        var fac = new TGridFactory(attrs);
        return fac.create(ph);
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