package;

import Axis2D;
import a2d.Placeholder2D;
import a2d.transform.WidgetToScreenRatio;
import al.ec.WidgetSwitcher;
import data.aliases.AttribAliases;
import dkit.Dkit.BaseDkit;
import ec.Entity;
import fu.graphics.ShapeWidget;
import gl.sets.CircleSet;
import graphics.ShapesColorAssigner;
import graphics.shapes.QuadGraphicElement;
import graphics.shapes.SquareShape;
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
        root.addComponent(new al.openfl.display.FlashDisplayRoot(this));
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
        var uvs = new graphics.DynamicAttributeAssigner(CircleSet.instance, shw.getBuffer());
        uvs.fillBuffer = (attrs:CircleSet, buffer) -> {
            var writer = attrs.getWriter(AttribAliases.NAME_UV_0);
            for (i in 0...n)
                QuadGraphicElement.writeQuadPostions(buffer.getBuffer(), writer, i * 4, (a, wg) -> wg);
        };

        var rad = new RadiusAtt(attrs, 4);
        for (i in 0...n) {
            var sq = new SquareShape(attrs, steps.getRatio(), Math.random(), Math.random());
            sq.withAtt(rad.writePostions);
            sq.withAtt(new SquareAntialiasing(attrs, sq, fui.ar.getWindowSize()).writePostions);
            shw.addChild(sq);
            squares.push(sq);
        }

        gui.r1Changed.listen(v -> rad.r1 = v);
        gui.r2Changed.listen(v -> rad.r2 = v);
        shw.manInit();
        new ShapesColorAssigner(attrs, 0xff0000, shw.getBuffer());
        return shw;
    }
}
