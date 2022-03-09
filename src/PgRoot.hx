package ;
import openfl.events.Event;
import haxe.ds.ReadOnlyArray;
import text.h2d.H2dTextLayouter.H2dRichCharsLayouterFactory;
import text.h2d.H2dTextLayouter.H2dCharsLayouterFactory;
import text.TextLayouter.CharsLayouterFactory;
import shaderbuilder.MSDFShader;
import gl.sets.MSDFSet;
import font.bmf.BMFont.BMFontFactory;
import gl.aspects.TextureBinder;
import transform.AspectRatioProvider;
import gl.sets.TexSet;
import shaderbuilder.SnaderBuilder;
import gl.sets.ColorSet;
import gl.GLDisplayObject;
import shaderbuilder.SnaderBuilder.PosPassthrough;
import gl.ec.Drawcalls;
import gl.RenderingAspect.RenderingElementsFactory;
import ec.Entity;
import gl.RenderingAspect.RenderAspectBuilder;
import font.vjson.VJsonFontFactory;
import font.FontStorage;
class PgRoot {



    static var fonts = new FontStorage(new VJsonFontFactory());
    static var elFactory = new RenderAspectBuilder([]);


    public static function createLayers(root:Entity, elFactory:RenderingElementsFactory) {
        var drcalls = new Drawcalls();
        root.addComponent(drcalls);

        var posShader = PosPassthrough.instance;
        var l = new GLDisplayObject(ColorSet.instance,
        new ShaderBase(
        [posShader, ColorPassthroughVert.instance],
        [ ColorPassthroughFrag.instance]).create,
        elFactory.newChain().build());
        openfl.Lib.current.addChild(l);
        drcalls.addLayer(ColorSet.instance, l);


        var tex = new GLDisplayObject(TexSet.instance,
        TextureShader.instance.create,
        elFactory.newChain().add(new TextureBinder(lime.utils.Assets.getImage("Assets/9q.png"))).build());
        openfl.Lib.current.addChild(tex);
        drcalls.addLayer(TexSet.instance, tex);


        initFonts(root, elFactory);
    }

    public static function createRoot() {
        var root = new Entity();
        var aspects:StageAspectKeeper = new StageAspectKeeper(1);
        root.addComponentByName(Entity.getComponentId(AspectRatioProvider), aspects);

//        configureInput(root);
        createDisplayRoot(root);
        return root;
    }

//    static function configureInput(root:Entity) {
//        var aspects = root.getComponent(AspectRatioProvider);
//        var s = new InputSystemsContainer(new Point(), null);
//        root.addComponent(new SwitchableInputBinder<Point>(s));
//        new InputRoot(s, aspects.getFactorsRef());
//    }

    static function initFonts(root:Entity, elFactory:RenderingElementsFactory = null) {
        if (elFactory == null)
            elFactory = PgRoot.elFactory;
//        var relements = new Map<FontAlias, RenderingElement>();
        var drcalls = root.getComponent(Drawcalls);
        var storage = new FontStorage(new VJsonFontFactory());
        var bmfac = new BMFontFactory();
        root.addComponent(storage);
        function initFont(fac, alias:FontAlias, path, df = 2) {
            var font = storage.initFont(alias, path, fac, df);
            var tl = new GLDisplayObject(MSDFSet.instance, MSDFShader.instence.create,
            elFactory.newChain().add(new MSDFRenderingElement(font.textureImage)).build()
            );
            drcalls.addLayer(MSDFSet.instance, tl, alias);
            openfl.Lib.current.addChild(tl);
            return font;
        }

//        var path = "Assets/text/DidactGothic-Regular.json";
//        var font = initFont(null, "", path);

//        var defaultfont = initFont(bmfac, "",  "Assets/heaps-fonts/text_res/msdf.fnt");
//        var defaultfont = initFont(bmfac, "",  "Assets/heaps-fonts/AmaticSC.fnt");
//        var defaultfont = initFont(bmfac, "",  "Assets/heaps-fonts/Cardo.fnt", 1);
//        var defaultfont = initFont(bmfac, "d8",  "Assets/heaps-fonts/Cardo.fnt", 8);
        var defaultfont = initFont(bmfac, "",  "Assets/heaps-fonts/Cardo-36-df8.fnt", 8);
        var font = initFont(bmfac, "svg", "Assets/heaps-fonts/svg.fnt", 4);
//        var defaultfont = initFont(bmfac, "",  "Assets/heaps-fonts/raw/msdf.fnt");
        root.addComponentByType(CharsLayouterFactory, new H2dCharsLayouterFactory(defaultfont.font));
//        root.addComponentByType(CharsLayouterFactory, new SimpleCharsLayouterFactory(font.font));

        var richLayFactory = new H2dRichCharsLayouterFactory(storage);
        root.addComponentByName("CharsLayouterFactory_rich" , richLayFactory);

//        var font = initFont(bmfac, "svg", "Assets/heaps-fonts/svg.fnt");
//        root.addComponentByName("CharsLayouterFactory_svg" , new H2dCharsLayouterFactory(font.font));
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

        var tex = new GLDisplayObject(TexSet.instance,
        TextureShader.instance.create,
        new TextureBinder(lime.utils.Assets.getImage("Assets/9q.png"))
        );
        openfl.Lib.current.addChild(tex);
        drcalls.addLayer(TexSet.instance, tex);

        initFonts(root);
    }

}

typedef FontAlias  = String ;
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
