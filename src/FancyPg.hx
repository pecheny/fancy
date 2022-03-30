package ;
import widgets.ColouredQuad;
import al.al2d.Axis2D;
import al.Builder;
import al.openfl.StageAspectResizer;
import crosstarget.Widgetable;
import ec.CtxBinder;
import ec.Entity;
import FuiBuilder;
import gl.ec.DrawcallDataProvider;
import gl.ec.Drawcalls;
import gl.sets.MSDFSet;
import input.al.ButtonPanel;
import openfl.display.Sprite;
import text.TextRender;
import text.transform.TextTransformer;
import transform.AspectRatioProvider;
import transform.LiquidTransformer;
import utils.DummyEditorField;
import widgets.ColorBars;
using transform.LiquidTransformer;
class FancyPg extends FuiAppBase {
    public function new() {
        super();
        var b = new Builder();
//        var fuiBuilder = new FuiBuilder();
//        var root:Entity = fuiBuilder.createContainer(["color", "text:''"]);
        var root:Entity = new Entity();
//        var ar:StageAspectKeeper = new StageAspectKeeper(1);
        var ar = fuiBuilder.ar;
        fuiBuilder.addBmFont("", "Assets/heaps-fonts/robo.fnt"); // todo
        root.addComponentByName(Entity.getComponentId(AspectRatioProvider), fuiBuilder.ar);
        root.addComponentByType(Size2D, fuiBuilder.ar);
        fuiBuilder.configureInput(root);

//        fuiBuilder.addBmFont("", "Assets/heaps-fonts/monts.fnt");
//        root.addComponent(fuiBuilder.createTextStyle(""));
        var dl =
        '<container>
        <drawcall type="color"/>
        <drawcall type="text" font=""/>
        </container>';
        fuiBuilder.createContainer(root, Xml.parse(dl).firstElement());
        var container:Sprite = root.getComponent(Sprite);
        for (i in 0...container.numChildren) {
            trace(container.getChildAt(i));
        }
        addChild(container);
//        var root = PgRoot.createRoot();
        var pxStyle = fuiBuilder.textStyles.newStyle("px")
        .withSizeInPixels(64)
        .withPivot(horizontal, new ForwardPivot(1))
        .withPivot(vertical, new ForwardPivot(1))
        .build();

        var fitStyle = fuiBuilder.textStyles.newStyle("fit")
        .withFitFontScale(.75)
        .withPivot(horizontal, new ForwardPivot(1))
        .withPivot(vertical, new MiddlePivot())
        .build();

        var quads = [for (i in 0...1)new ColorBars(b.widget().withLiquidTransform(ar.getFactorsRef()), Std.int(0xffffff * Math.random())).widget()];
        quads.push(new DummyText(b.widget().withLiquidTransform(ar.getFactorsRef()), pxStyle).widget());
        quads.push(new DummyText(b.widget().withLiquidTransform(ar.getFactorsRef()), fitStyle).widget());
//        quads.push(new SomeButton(b.widget().withLiquidTransform(ar.getFactorsRef())).widget());
//        quads.push(new ColouredQuad(b.widget().withLiquidTransform(ar.getFactorsRef()), 0x303090).widget());
        var rw = b.align(vertical).container(quads);
        ButtonPanel.make(rw);
        root.addChild(rw.entity);
        new StageAspectResizer(rw, 2);
        new DummyEditorField();

    }

    function getSampleText() {
        return lime.utils.Assets.getText("Assets/heaps-fonts/Rich-text-sample.xml");
    }

}


class DummyText extends Widgetable {
//    @:once
    var textStyleContext:TextStyleContext;
    var text:String = "";
    @:once var fluidTransform:LiquidTransformer;
    @:once var aspectRatioProvider:AspectRatioProvider;
    @:once var windowSize:Size2D;

    public function new(w, tc) {
        super(w);
        new ColouredQuad(w, Std.int(Math.random() * 0xffffff));
        this.textStyleContext = tc;
    }

    public function withText(s) {
        text = s;
        return this;
    }

    override function init() {
        var attrs = MSDFSet.instance;
        var l = textStyleContext.layouterFactory.create();
        var dpiWriter = attrs.getWriter(MSDFSet.NAME_DPI);

        TextTransformer.withTextTransform(w, aspectRatioProvider.getFactorsRef(), textStyleContext);
        var tt = w.entity.getComponent(TextTransformer);
        var smothWr = new SmothnessWriter(dpiWriter[0], l, textStyleContext, tt, windowSize);
        var text = new TextRender(attrs, l, tt, smothWr);
        text.setText("Foo bar");
        text.setText("FoEo Bar AbAb Aboo Distance Field texture
Ad Ae Af
Bd Be Bf Bb Ab
Dd De Df
Cd Ce Cf");
        var drawcallsData = DrawcallDataProvider.get(MSDFSet.instance, w.entity, textStyleContext.getDrawcallName());
        drawcallsData.views.push(text);
        new CtxBinder(Drawcalls, w.entity);
    }
}
