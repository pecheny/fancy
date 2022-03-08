package ;
import gl.ec.Drawcalls;
import al.al2d.Axis2D;
import al.Builder;
import al.openfl.StageAspectResizer;
import ec.Entity;
import gl.GLDisplayObject;
import gl.sets.ColorSet;
import haxe.ds.ReadOnlyArray;
import openfl.display.Sprite;
import openfl.events.Event;
import shaderbuilder.SnaderBuilder;
import transform.AspectRatioProvider;
class FancyPg extends Sprite {
    public function new() {
        super();
        var b = new Builder();
        var root = createRoot();
        var ar = root.getComponentUpward(AspectRatioProvider).getFactorsRef();
        var customSvgW = b.widget(portion, 1, portion, 1);


//        var quads = [for (i in 0...12)new ColouredQuad(b.widget(), Std.int(0xffffff*Math.random()))];
        var quads = [for (i in 0...2)new ColorBars(b.widget(), Std.int(0xffffff * Math.random()))];
//        var bars = new BarsItem(b.widget(), elements, root.getComponentUpward(AspectRatioProvider).getFactorsRef(), new ColorArrayProvider([new RGB(255,0,0)]).getValue);
        var rw = b.align(horizontal).container(quads.map(q -> q.widget()));
        root.addChild(rw.entity);
        new StageAspectResizer(rw, 2);
//        var l:GLDisplayObject<ColorSet> = root.getComponent(GLDisplayObject);
//        for (q in quads)
//            l.addView(q);
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
        var drcalls = new Drawcalls();
        root.addComponent(drcalls);
        // -- color layer
        var l = new GLDisplayObject(ColorSet.instance,
        new ShaderBase(
        [PosPassthrough.instance, ColorPassthroughVert.instance],
        [ColorPassthroughFrag.instance]).create,
        null);
        openfl.Lib.current.addChild(l);
        drcalls.addLayer(ColorSet.instance, l);
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