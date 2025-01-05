package;

import dkit.Dkit;
import data.IndexCollection;
import haxe.io.Bytes;
import gl.passes.CirclePass;
import FuiBuilder;
import a2d.Placeholder2D;
import al.ec.WidgetSwitcher;
import data.aliases.AttribAliases;
import ec.Entity;
import fu.graphics.ShapeWidget;
import gl.sets.CircleSet;
import graphics.shapes.QuadGraphicElement;
import graphics.shapes.Shape;
import openfl.display.Sprite;

using a2d.transform.LiquidTransformer;
using al.Builder;

class CircleShaderDemo extends Sprite {
    public var fui:FuiBuilder;
    public var switcher:WidgetSwitcher<Axis2D>;

    var e:Entity;

    public function new() {
        super();
        fui = new FuiBuilder();
        BaseDkit.inject(fui);
        var root:Entity = fui.createDefaultRoot();
        var uikit = new FlatUikitExtended(fui);
        uikit.configure(root);
        uikit.createContainer(root);

        switcher = root.getComponent(WidgetSwitcher);
        var wdg = quad(fui.placeholderBuilder.h(sfr, 1).v(sfr, 1).b(), 0x6a00ff);
        root.getComponent(WidgetSwitcher).switchTo(wdg.ph);
    }

    public function quad(ph:Placeholder2D, color) {
        fui.lqtr(ph);
        var attrs = CircleSet.instance;
        var shw = new ShapeWidget(attrs, ph, true);
        shw.addChild(new QuadGraphicElement(attrs));
        var uvs = new graphics.DynamicAttributeAssigner(attrs, shw.getBuffer());
        uvs.fillBuffer = (attrs:CircleSet, buffer) -> {
            var writer = attrs.getWriter(AttribAliases.NAME_UV_0);
            QuadGraphicElement.writeQuadPostions(buffer.getBuffer(), writer, 0, (a, wg) -> wg);
            attrs.fillFloat(buffer.getBuffer(), CircleSet.R1_IN, 0.3, 0, 4);
            attrs.fillFloat(buffer.getBuffer(), CircleSet.R2_IN, 0.9, 0, 4);
        };
        shw.manInit();
        return shw;
    }
}