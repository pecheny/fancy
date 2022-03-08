package crosstarget;
import al.al2d.Axis2D;
import al.al2d.Widget2D;
import al.Builder;
import gltools.aspects.TextureBinder;
import gltools.sets.ColorSet;
import gltools.sets.MSDFSet;
import gltools.sets.TexSet;
import haxe.ds.ReadOnlyArray;
import oglrenderer.GLDisplayObject;
import oglrenderer.RenderingElements;
import shader.MSDFShader;
import transform.AspectRatio;
import transform.AspectRatioProvider;
class StageAspectResizer {
    var target:Widget2D;
    var base:Float;

    public function new(target, base = 1) {
        this.target = target;
        this.base = base;
        openfl.Lib.current.stage.addEventListener(Event.RESIZE, onResize);
        onResize(null);
    }

    function onResize(e) {
        var stage = openfl.Lib.current.stage;
        var width = stage.stageWidth;
        var height = stage.stageHeight;
        if (width > height) {
            target.axisStates[Axis2D.horizontal].apply(0, base * width / height);
            target.axisStates[Axis2D.vertical].apply(0, base);
        } else {
            target.axisStates[horizontal].apply(0, base);
            target.axisStates[vertical].apply(0, base * height / width);
        }
    }
}




class InputRoot {
    var factors:AspectRatio;
    var input:InputTarget<Point>;
    var pos = new Point();
    var stg:Stage;


    public function new(input, fac) {
        this.input = input;
        this.factors = fac;
        stg = openfl.Lib.current.stage;
        stg.addEventListener(Event.ENTER_FRAME, onEnterFrame);
        stg.addEventListener(MouseEvent.MOUSE_UP, onUp);
        stg.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
    }

    function onEnterFrame(e) {
        updatePos();
    }

    inline function updatePos() {
        pos.x = 2 * (stg.mouseX / stg.stageWidth) * factors[horizontal];
        pos.y = 2 * (stg.mouseY / stg.stageHeight) * factors[vertical];
        input.setPos(pos);
    }

    function onDown(e) {
        updatePos();
        input.press();
    }

    function onUp(e) {
        input.release();
    }
}
typedef SomeLabel = graphics.items.SimpleLabel;
typedef ColorRect = graphics.items.ColouredQuad;
typedef SomeButton = graphics.items.SomeButton;

interface RenderingElementsFactory {
    function newChain():RenderingElementsFactory;
    function add(re:RenderingElement):RenderingElementsFactory;
    function build():RenderingElement;
}

class RenderElementBuilder implements RenderingElementsFactory {
    // для элементов не зваисящих от шейдерной программы
    // для зависящих вместо массива надоделать фабрику
    var sharedAspects:Array<RenderingElement>;
    var instance:Array<RenderingElement>;

    public function new(sharedAspects) {
        this.sharedAspects = sharedAspects;
    }

    public function newChain() {
        instance = [];
        return this;
    }

    public function add(re:RenderingElement) {
        instance.push(re);
        return this;
    }

    public function build() {
        if (instance==null) throw "start new chain before build()";
        var result =
        if (sharedAspects.length + instance.length == 0)
            null;
        else if (instance.length == 0){
            if (sharedAspects.length > 1)
                new RenderingElements(sharedAspects);
            else
                sharedAspects[0];
        }
        else if (sharedAspects.length == 0){
            if (instance.length > 1)
                new RenderingElements(instance);
            else
                instance[0];
        } else
        new RenderingElements(sharedAspects.concat(instance));
        instance = null;
        return result;
    }
}

class PgRoot {

    static var fonts = new FontStorage(new VJsonFontFactory());
    static var elFactory = new RenderElementBuilder([]);

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

        configureInput(root);
        createDisplayRoot(root);
        return root;
    }

    static function configureInput(root:Entity) {
        var aspects = root.getComponent(AspectRatioProvider);
        var s = new InputSystemsContainer(new Point(), null);
        root.addComponent(new SwitchableInputBinder<Point>(s));
        new InputRoot(s, aspects.getFactorsRef());
    }

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


class TextureGraphics extends GraphicsBase<TexSet> {

}

class ScrollboxItem extends ScrollboxWidget {

    public function new(w:Widget2D, content:ScrollableContent, ar) {
        var fac = new RenderElementBuilder([new ScissorAspect(w, ar)]);
        PgRoot.createLayers(w.entity, fac);
        new CtxBinder(Drawcalls, w.entity);

        var vscroll = new FlatScrollbar(Builder.widget2d(), ar, vertical);
        var hscroll = new FlatScrollbar(Builder.widget2d(), ar, horizontal);
        scrollbars = new AxisCollection2D();
        scrollbars[horizontal] = hscroll;
        scrollbars[vertical] = vscroll;
        super(w, content, ar);
//        bg(w.entity, ar);
    }

//    function bg(e, aspectRatio) {
//        var fluidTransform = new GFluidTransform(aspectRatio);
//        var renderTarget = new RenderDataTarget();
//        var colorContainer = new GraphicsContainer(ColorSet.instance, e, renderTarget);
//        var q = fluidTransform.addChild(colorContainer.addGraphic(new QuadGraphicElement(ColorSet.instance)));
//
//        colorContainer.build();
//        for (a in Axis2D.keys) {
//            var applier2 = fluidTransform.getAxisApplier(a);
//            w.axisStates[a].addSibling(applier2);
//        }
//        MeshUtils.writeInt8Attribute(ColorSet.instance, colorContainer.bytes(), AttribAliases.NAME_COLOR_IN, q.pos, q.vertCount(), (_, _) -> 240);
//    }
}
