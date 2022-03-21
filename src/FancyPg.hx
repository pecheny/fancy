package ;
import input.al.ButtonPanel;
import widgets.SomeButton;
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
import haxe.ds.ReadOnlyArray;
import openfl.display.Sprite;
import openfl.events.Event;
import text.TextRender;
import transform.AspectRatioProvider;
import transform.LiquidTransformer;
import widgets.ColorBars;
import widgets.ColouredQuad;
using transform.LiquidTransformer;
class FancyPg extends FuiAppBase {
    public function new() {
        super();
        var b = new Builder();
//        var fuiBuilder = new FuiBuilder();
//        var root:Entity = fuiBuilder.createContainer(["color", "text:''"]);
        var root:Entity = new Entity();
        var ar:StageAspectKeeper = new StageAspectKeeper(1);
        root.addComponentByName(Entity.getComponentId(AspectRatioProvider), ar);
        fuiBuilder.configureInput(root);

        fuiBuilder.addBmFont("", "Assets/heaps-fonts/Cardo-36-df8.fnt");
        root.addComponent(fuiBuilder.createTextStyle(""));
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

        var quads = [for (i in 0...1)new ColorBars(b.widget().withLiquidTransform(ar.getFactorsRef()), Std.int(0xffffff * Math.random())).widget()];
        quads.push(new DummyText(b.widget().withLiquidTransform(ar.getFactorsRef())).widget());
        quads.push(new SomeButton(b.widget().withLiquidTransform(ar.getFactorsRef())).widget());
        quads.push(new ColouredQuad(b.widget().withLiquidTransform(ar.getFactorsRef()), 0x303090).widget());
        var rw = b.align(vertical).container(quads);
        ButtonPanel.make(rw);
        root.addChild(rw.entity);
        new StageAspectResizer(rw, 2);

    }

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
    @:once var textStyleContext:TextStyleContext;
    @:once var fluidTransform:LiquidTransformer;
    override function init() {
        trace("init");
        var text = new TextRender(MSDFSet.instance, textStyleContext.layouterFactory.create(), fluidTransform);
        text.setText("Foo");
        var drawcallsData = DrawcallDataProvider.get(MSDFSet.instance, w.entity, textStyleContext.getDrawcallName());
        drawcallsData.views.push(text);
        new CtxBinder(Drawcalls, w.entity);
    }
}
