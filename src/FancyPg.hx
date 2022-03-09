package ;
import al.al2d.Axis2D;
import al.Builder;
import al.openfl.StageAspectResizer;
import crosstarget.Widgetable;
import ec.CtxBinder;
import gl.ec.DrawcallDataProvider;
import gl.ec.Drawcalls;
import gl.sets.MSDFSet;
import openfl.display.Sprite;
import PgRoot;
import text.TextLayouter.CharsLayouterFactory;
import text.TextRender;
import transform.AspectRatioProvider;
import transform.LiquidTransformer;
import widgets.ColorBars;
import widgets.ColouredQuad;
class FancyPg extends Sprite {
    public function new() {
        super();
        var b = new Builder();
        var root = PgRoot.createRoot();
        var ar = root.getComponentUpward(AspectRatioProvider).getFactorsRef();
        var customSvgW = b.widget(portion, 1, portion, 1);

        var quads = [for (i in 0...2)new ColorBars(b.widget(), Std.int(0xffffff * Math.random())).widget()];
        quads.push(new DummyText(b.widget()).widget());
        quads.push(new ColouredQuad(b.widget(), 0x303090).widget());
        var rw = b.align(vertical).container(quads);
        root.addChild(rw.entity);
        new StageAspectResizer(rw, 2);

    }


    function getSampleText() {
        return lime.utils.Assets.getText("Assets/heaps-fonts/Rich-text-sample.xml");
    }

}

class DummyText extends Widgetable {


    @:once var ratioProvider:AspectRatioProvider;
    @:once var charsLayouterFactory:CharsLayouterFactory;

    override function init() {
        trace("init");
        var aspectRatio = ratioProvider.getFactorsRef();
        var fluidTransform = new LiquidTransformer(aspectRatio);
        for (a in Axis2D.keys) {
            var applier2 = fluidTransform.getAxisApplier(a);
            w.axisStates[a].addSibling(applier2);
        }
        var text = new TextRender(MSDFSet.instance, charsLayouterFactory, fluidTransform);
        text.setText("Foo");
        var drawcallsData = DrawcallDataProvider.get(MSDFSet.instance, w.entity);
        drawcallsData.views.push(text);
        new CtxBinder(Drawcalls, w.entity);
    }

}
