package ;
import gl.GNLayer;
import entitygl.DrawcallDataProvider;
import shaderbuilder.SnaderBuilder;
import openfl.events.Event;
import gl.sets.ColorSet;
import oglrenderer.GLLayer;
import haxe.ds.ReadOnlyArray;
import ec.Entity;
import openfl.display.Sprite;
import al.openfl.StageAspectResizer;
import al.al2d.Axis2D;
import al.Builder;
import transform.AspectRatioProvider;
class FancyPg extends Sprite {
    public function new() {
        super();
        var b = new Builder();
        var root = createRoot();
        var ar = root.getComponentUpward(AspectRatioProvider).getFactorsRef();
        var customSvgW = b.widget(portion, 1, portion, 1);

        var quad = new ColouredQuad(b.widget(), 0xff0000);
//        var bars = new BarsItem(b.widget(), elements, root.getComponentUpward(AspectRatioProvider).getFactorsRef(), new ColorArrayProvider([new RGB(255,0,0)]).getValue);
        var rw = b.align(horizontal).container(
            [
                quad.widget()
//                new RichLabel(customSvgW).setText(getSampleText()).widget(),
//                    b.align(vertical).container([
//                        new RichLabel(b.widget()).setText(getSampleText()).widget(),
//                        new RichLabel(b.widget()).setText(getSampleText()).widget(),
//                    ])
            ]);
        root.addChild(rw.entity);
        new StageAspectResizer(rw, 2);
        var l:GNLayer<ColorSet> = root.getComponent(GNLayer);
        l.addView(quad);
//        var drd:DrawcallDataProvider<ColorSet> = quad.widget().entity.getComponent(DrawcallDataProvider);
//        trace(drd);
//        trace(drd.views);
//        for (v in drd.views) {
//            trace(l  + " " + v);
//            l.addView(v);
//        }
    }


    function getSampleText() {
        return lime.utils.Assets.getText("Assets/heaps-fonts/Rich-text-sample.xml");
    }


    public static function createRoot() {
        var root = new Entity();
        var aspects:StageAspectKeeper = new StageAspectKeeper(1);
        root.addComponentByName(Entity.getComponentId(AspectRatioProvider), aspects);

        createDisplayRoot(root);
        return root;
    }

    static function createDisplayRoot(root:Entity) {

        // -- color layer
        var l = new GNLayer(ColorSet.instance,
        new ShaderBase(
        [PosPassthrough.instance, ColorPassthroughVert.instance],
        [ColorPassthroughFrag.instance]).create,
        null);
        openfl.Lib.current.addChild(l);
        root.addComponent(l);
        // --- end of color
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