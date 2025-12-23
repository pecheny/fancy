import shaderbuilder.CircleShader;
import fu.graphics.ShapeWidget;
import backends.openfl.OpenflBackend.StageImpl;
import Axis2D;
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
import graphics.shapes.NGrid;
import graphics.shapes.TGrid;
import openfl.display.Sprite;

class BarsDemo extends Sprite {
    public var fui:FuiBuilder;
    public var switcher:WidgetSwitcher<Axis2D>;

    var attrs = CircleSet.instance;

    public function new() {
        super();
        var stage = new StageImpl(1);
        var uikit = new FlatUikitExtended(stage);
        fui = new FuiBuilder(stage, uikit);
        BaseDkit.inject(fui);
        var root:Entity = fui.createDefaultRoot();
        uikit.configure(root);
        uikit.createContainer(root);
        fui.configureDisplayRoot(root, this);
        switcher = root.getComponent(WidgetSwitcher);
        var ph = Builder.widget();
        ngrid(ph);
        tgrid(ph);
        createBarWidget(ph);
        switcher.switchTo(ph);
    }

    function ngrid(ph) {
        fui.lqtr(ph);
        var cornerSize = 3;

        // var fac = new NGridFactory(attrs, cornerSize);
        var shw = new ShapeWidget(CircleSet.instance, ph);
        var shape = new RoundNGrid(ph);
        shw.addChild(shape);

        var buffer = shw.getBuffer();

        new ShapesColorAssigner(attrs, 0x9789FFC8, shw.getBuffer());

        buffer.onInit.listen(() -> {
            var rad = new RadiusAtt(attrs, buffer.getVertCount());
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
        // var fac = new TGridFactory(attrs);
        var shw = new ShapeWidget(CircleSet.instance, ph);
        var shape = new RoundTGrid(ph);
        shw.addChild(shape);
        var buffer = shw.getBuffer();
        // buffer.onInit.listen(() -> fac.addUV(buffer));
        // call addUv in iteration over children

        new ShapesColorAssigner(attrs, 0x77DEC7FF, shw.getBuffer());
        buffer.onInit.listen(() -> {
            var rad = new RadiusAtt(attrs, buffer.getVertCount());
            // for solid fill
            // rad.r1 = 0;
            // rad.r2 = 1;
            rad.writePostions(buffer.getBuffer(), 0, null);
            //for border of line thickness
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
        new ShapesColorAssigner(attrs, 0xffff7b7b, cq.getBuffer());
        return cq;
    }
}
