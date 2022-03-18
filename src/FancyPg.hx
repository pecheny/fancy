package ;
import font.FontInstance;
import font.IFont;
import openfl.display.Sprite;
import openfl.events.Event;
import haxe.ds.ReadOnlyArray;
import al.al2d.Axis2D;
import al.Builder;
import al.openfl.StageAspectResizer;
import crosstarget.Widgetable;
import ec.CtxBinder;
import ec.Entity;
import gl.ec.DrawcallDataProvider;
import gl.ec.Drawcalls;
import gl.sets.MSDFSet;
import text.TextLayouter.CharsLayouterFactory;
import text.TextRender;
import transform.AspectRatioProvider;
import transform.LiquidTransformer;
import widgets.ColorBars;
import widgets.ColouredQuad;
import FuiBuilder;
class FancyPg extends FuiAppBase {
    public function new() {
        super();
        var b = new Builder();
//        var fuiBuilder = new FuiBuilder();
//        var root:Entity = fuiBuilder.createContainer(["color", "text:''"]);
        var root:Entity = new Entity();
        fuiBuilder.addBmFont("", "Assets/heaps-fonts/Cardo-36-df8.fnt");
        root.addComponent(fuiBuilder.createTextStyle(""));
        var ar:StageAspectKeeper = new StageAspectKeeper(1);
        root.addComponentByName(Entity.getComponentId(AspectRatioProvider), ar);
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

        var quads = [for (i in 0...2)new ColorBars(b.widget(), Std.int(0xffffff * Math.random())).widget()];
        quads.push(new DummyText(b.widget()).widget());
        quads.push(new ColouredQuad(b.widget(), 0x303090).widget());
        var rw = b.align(vertical).container(quads);
        root.addChild(rw.entity);
        new StageAspectResizer(rw, 2);

    }


//    static function initFonts(root:Entity, ab:RenderAspectBuilder) {
//        var drcalls = root.getComponent(Drawcalls);
//        var storage = new FontStorage(new BMFontFactory());
//        root.addComponent();
//        function initFont(fac, alias:FontAlias, path, df = 2) {
//            ab.add(new MSDFRenderingElement())
//            var font = storage.initFont(alias, path, fac, df);
//        }
//
//        var defaultfont = initFont(bmfac, "", "Assets/heaps-fonts/Cardo-36-df8.fnt", 8);
//        var font = initFont(bmfac, "svg", "Assets/heaps-fonts/svg.fnt", 4);
//        root.addComponentByType(CharsLayouterFactory, new H2dCharsLayouterFactory(defaultfont.font));
//    }


    function getSampleText() {
        return lime.utils.Assets.getText("Assets/heaps-fonts/Rich-text-sample.xml");
    }

}



class StageAspectKeeper implements AspectRatioProvider {
    var base:Float;

    var factors:Array<Float> = [1, 1];


    public function new(base:Float = 1) {
        this.base = base;
        openfl.Lib.current.stage.addEventListener(Event.RESIZE, onResize);
        onResize(null);
    }

    function onResize(e) {
        var stage = openfl.Lib.current.stage;
        var width = stage.stageWidth;
        var height = stage.stageHeight;
        if (width > height) {
            factors[0] = (base * width / height);
            factors[1] = base;
        } else {
            factors[0] = base;
            factors[1] = (base * height / width);
        }
    }

    public inline function getFactor(cmp:Int):Float {
        return factors[cmp];
    }

    public function getFactorsRef():ReadOnlyArray<Float> {
        return factors;
    }
}

class DummyText extends Widgetable {


    @:once var ratioProvider:AspectRatioProvider;
//    @:once var charsLayouterFactory:CharsLayouterFactory;
    @:once var textStyleContext:TextStyleContext;

    override function init() {
        trace("init");
        var aspectRatio = ratioProvider.getFactorsRef();
        var fluidTransform = new LiquidTransformer(aspectRatio);
        for (a in Axis2D.keys) {
            var applier2 = fluidTransform.getAxisApplier(a);
            w.axisStates[a].addSibling(applier2);
        }
        var text = new TextRender(MSDFSet.instance, textStyleContext.layouterFactory.create(), fluidTransform);
        text.setText("Foo");
        var drawcallsData = DrawcallDataProvider.get(MSDFSet.instance, w.entity, textStyleContext.getDrawcallName());
        drawcallsData.views.push(text);
        new CtxBinder(Drawcalls, w.entity);
    }

}
