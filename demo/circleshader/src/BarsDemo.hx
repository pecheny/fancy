import Axis2D;
import SquareShape;
import a2d.transform.WidgetToScreenRatio;
import al.Builder;
import al.ec.WidgetSwitcher;
import dkit.Dkit.BaseDkit;
import ec.Entity;
import fu.graphics.BarWidget;
import gl.sets.CircleSet;
import gl.sets.ColorSet;
import graphics.ShapesColorAssigner;
import graphics.shapes.Bar;
import graphics.shapes.WeightedGrid;
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
        ngrid(gui.canvas.ph);
        tgrid(gui.ph);
        createBarWidget(gui.canvas.ph);
        switcher.switchTo(gui.ph);
    }

    function ngrid(ph) {
        fui.lqtr(ph);
        var cornerSize = 3;

        var fac = new NGridFactory(attrs, cornerSize);
        var shw = fac.create(ph);
        var buffer = shw.getBuffer();

        new ShapesColorAssigner(attrs, 0x77BA89FF, shw.getBuffer());

        buffer.onInit.listen(() -> {
            var rad = new RadiusAtt(attrs, buffer.getVertCount());
            rad.r1 = 0;
            rad.r2 = 1;
            rad.r1 = 1 - (1 / cornerSize);
            rad.r1 *= rad.r1;

            rad.writePostions(buffer.getBuffer(), 0, null);
        });
        return shw;
    }

    function tgrid(ph) {
        fui.lqtr(ph);
        var steps = WidgetToScreenRatio.getOrCreate(ph.entity, ph, 0.05);
        var fac = new TGridFactory(attrs);
        var shw = fac.create(ph);

        var buffer = shw.getBuffer();
        new ShapesColorAssigner(attrs, 0x77DEC7FF, shw.getBuffer());
        buffer.onInit.listen(() -> {
            var rad = new RadiusAtt(attrs, buffer.getVertCount());
            rad.writePostions(buffer.getBuffer(), 0, null);
            new fu.graphics.CircleThicknessCalculator(ph, steps, cast rad, buffer.getBuffer());
        });
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
