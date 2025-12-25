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
        fui.lqtr(ph);
        var shw = new ShapeWidget(CircleSet.instance, ph);
        shw.addChild(new FlatBubble(ph, 0x93ff0080));
        shw.addChild(new EdgedBubble(ph, 0xabff9900));
        shw.addChild(new FlatBallon(ph, 0x9F00AAFF));
        shw.addChild(new EdgedBallon(ph, 0x93EE0000));
        createBarWidget(ph);
        switcher.switchTo(ph);
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
