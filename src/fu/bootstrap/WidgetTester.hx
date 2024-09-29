package fu.bootstrap;

import htext.FontAspectsFactory;
import fu.GuiDrawcalls;
import gl.aspects.TextureBinder;
import gl.aspects.RenderingAspect.RenderAspectBuilder;
import gl.passes.FlatColorPass;
import gl.passes.CmsdfPass;
import ec.Entity;
import fancy.domkit.Dkit.BaseDkit;
import al.ec.WidgetSwitcher;
import al.Builder;
import openfl.display.Sprite;

using al.Builder;
using a2d.transform.LiquidTransformer;

class WidgetTester extends Sprite {
    public var fui:FuiBuilder;
    public var switcher:WidgetSwitcher<Axis2D>;

    var e:Entity;

    public function new() {
        super();
        fui = new FuiBuilder();

        var pipeline = fui.pipeline;
        pipeline.addPass(GuiDrawcalls.BG_DRAWCALL, new FlatColorPass());
        pipeline.addPass(GuiDrawcalls.TEXT_DRAWCALL, new CmsdfPass());
        var fontAsp = new FontAspectsFactory(fui.fonts, pipeline.textureStorage);
        pipeline.addAspectExtractor(GuiDrawcalls.TEXT_DRAWCALL, fontAsp.create, fontAsp.getAlias);

        BaseDkit.inject(fui);
        fui.regDefaultDrawcalls = () -> {};
        e = fui.createDefaultRoot(Xml.parse(GuiDrawcalls.DRAWCALLS_LAYOUT).firstElement());
        switcher = e.getComponent(WidgetSwitcher);
    }
}
