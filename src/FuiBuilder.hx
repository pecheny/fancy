package ;
import a2d.AspectRatio;
import a2d.AspectRatioProvider;
import a2d.Stage;
import a2d.WindowSizeProvider;
import al.al2d.Placeholder2D;
import al.animation.AnimationTreeBuilder;
import al.layouts.OffsetLayout;
import algl.Builder.PlaceholderBuilderGl;
import Axis2D;
import bindings.GLTexture;
import bindings.WebGLRenderContext;
import ec.CtxWatcher;
import ec.Entity;
import ecbind.ClickInputBinder;
import ecbind.InputBinder;
import ecbind.RenderableBinder;
import font.bmf.BMFont.BMFontFactory;
import font.FontStorage;
import gl.aspects.RenderingAspect;
import gl.AttribSet;
import gl.GLDisplayObject;
import gl.sets.ColorSet;
import gl.sets.MSDFSet;
import gl.ShaderRegistry;
import htext.style.TextContextBuilder;
import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.OpenflStage;
import scroll.ScissorAspect;
import shaderbuilder.MSDFShader;
import shaderbuilder.ShaderElement;
import shaderbuilder.SnaderBuilder;
import shimp.ClicksInputSystem;
import shimp.InputSystem;
import shimp.InputSystemsContainer;
import update.RealtimeUpdater;
import update.Updater;
import widgets.utils.WidgetHitTester;

class DummyFrag implements ShaderElement {
    public static var instance = new DummyFrag();

    public function new() {}

    public function getDecls():String {
        return "";
    }

    public function getExprs():String {
        return 'gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);';
    }
}

class FuiBuilder {
    public var ar:Stage = new OpenflStage(1);
    public var renderAspectBuilder(default, null):RenderAspectBuilder;
    public var textureStorage:TextureStorage;
    public var shaderRegistry:ShaderRegistry;
    public var fonts(default, null) = new FontStorage(new BMFontFactory());
    public var placeholderBuilder(default, null):PlaceholderBuilderGl;
    public var textStyles:TextContextBuilder;
    public var updater(default, null):Updater;
    var gldoBuilder:GldoBuilder ;
    var pos:ShaderElement = PosPassthrough.instance;
    var xmlProc:XmlProc;
    var sharedAspects:Array<RenderingAspect>;


    public function new() {
        textureStorage = new TextureStorage();
        placeholderBuilder = new PlaceholderBuilderGl(ar);
        shaderRegistry = new ShaderRegistry();
        gldoBuilder = new GldoBuilder(shaderRegistry);
        xmlProc = new XmlProc(gldoBuilder);
        textStyles = new TextContextBuilder(fonts, ar);
        var updater = new RealtimeUpdater();
        updater.update();
        this.updater = updater;
        #if openfl
        openfl.Lib.current.stage.addEventListener(openfl.events.Event.ENTER_FRAME, _->updater.update());
        #end
        setAspects([]);
    }


    static var smoothShaderEl = new GeneralPassthrough(MSDFSet.NAME_DPI, MSDFShader.smoothness);

    public function regDefaultDrawcalls():Void {
        regDrawcallType(
            "color",
            {
                type:"color",
                attrs:ColorSet.instance,
                vert:[ColorPassthroughVert.instance, PosPassthrough.instance],
                frag:[cast ColorPassthroughFrag.instance],
            }, (e, xml) -> createGldo(ColorSet.instance, e, "color", null, "")
        );

        regDrawcallType(
            "text",
            {
                type:"msdf",
                attrs:MSDFSet.instance,
                vert:[Uv0Passthrough.instance, PosPassthrough.instance, smoothShaderEl],
                frag:[cast MSDFFrag.instance],
                uniforms: ["color" ]
            }, createTextGldo
        );
    }

    public function regDrawcallType<T:AttribSet>(drawcallType:String, shaderDesc:ShaderDescr<T>, gldoFactory:GldoFactory<T>) {
        shaderRegistry.reg(shaderDesc);
        xmlProc.regHandler(drawcallType, gldoFactory);
    }

    public function hasDrawcallType(type) {
        return (shaderRegistry.getDescr(type) != null);
    }

    public function setAspects(a:Array<RenderingAspect>) {
        sharedAspects = a;
        renderAspectBuilder = new RenderAspectBuilder(a);
        return this;
    }

    public function setPositioning(pos:ShaderElement) {
        this.pos = pos;
        return this;
    }

    public function createGldo<T:AttribSet>(attrs:T, e:Entity, type:String, aspect:RenderingAspect, name:String):GLDisplayObject<T> {
        return cast gldoBuilder.getGldo(e, type, aspect, name);
    }

    public function createTextGldo(e, descr:Xml) {
        var fontName = descr.get("font");
        var color = descr.exists("color") ? Std.parseInt(descr.get("color")) : 0xffffff;
        var font = fonts.getFont(fontName);
        if (font == null)
            throw 'there is no font $fontName';
        var aspect = renderAspectBuilder.newChain().add(new MSDFRenderingElement(textureStorage, font.texturePath, color)).build();
        return createGldo(MSDFSet.instance, e, "msdf", aspect, font.getId());
    }

    public function createContainer(e:Entity, descr):Entity {
        xmlProc.processNode(e, descr);
        return e;
    }

    public function addBmFont(fontName, fntPath) {
        var font = fonts.initFont(fontName, fntPath, null);
        return this;
    }

    public function configureInput(root:Entity) {
        var s = new InputSystemsContainer(new Point(), null);
        root.addComponent(new InputBinder<Point>(s));
        new InputRoot(s, ar.getAspectRatio());
    }

    public function makeClickInput(w:Placeholder2D) {
        var input = new ClicksInputSystem(new Point());
        w.entity.addComponent(new ClickInputBinder(input));
        var outside = new Point();
        outside.x = -9999999;
        outside.y = -9999999;
        w.entity.addComponentByType(InputSystemTarget, new SwitchableInputAdapter(input, new WidgetHitTester(w), new Point(), outside));
        new CtxWatcher(InputBinder, w.entity);
        return w;
    }

    public function configureScreen(root:Entity) {
        root.addComponentByType(Stage, ar);
        root.addComponentByType(AspectRatioProvider, ar);
        root.addComponentByType(WindowSizeProvider, ar);
        root.addComponentByType(PlaceholderBuilderGl, placeholderBuilder);

        return root;
    }


    public function configureAnimation(root:Entity) {
        root.addComponentByType(Updater, updater);
        var animBuilder = new AnimationTreeBuilder();
        animBuilder.addLayout("offset", new OffsetLayout(0.1));
        root.addComponent(animBuilder);
        return root;
    }

    public function addScissors(w:Placeholder2D) {
        var sc = new ScissorAspect(w, ar.getAspectRatio());
        sharedAspects.push(sc);
    }
}

typedef GldoFactory<T:AttribSet> = Entity -> Xml -> GLDisplayObject<T>;
class XmlProc {
    var ctx:FuiBuilder;
    var handlers:Map<String, GldoFactory<Dynamic>> = new Map();
    var gldoBuilder:GldoBuilder;


    public function new(gb) {
        this.gldoBuilder = gb;
    }


    public function processNode(e:Entity, node:Xml, ?container:Null<DisplayObjectContainer>):Entity {
        return switch (node.nodeName) {
            case "container" : {
                var c = new Sprite();
                e.addComponent(c);
                if (container != null) container.addChild(c);
                var dc = gldoBuilder.getDrawcalls(e);
                for (child in node.elements()) {
                    processNode(e, child, c);
                }
                e;
            }
            case "drawcall" : {
                var gldo = handlers[node.get("type")](e, node);
                if (container != null)
                    container.addChild(gldo);
                else {
                    var dc = gldoBuilder.getDrawcalls(e);
                    e.addComponent(gldo);
                }
                e;
            }
            case _ :
                throw "wrong " + node.nodeName;
        }
    }


    public function regHandler(t, h) {
        handlers[t] = h;
    }

}

class GldoBuilder {
    var shaders:IShaderRegistry ;

    public function new(s) {
        this.shaders = s;
    }

    public function getDrawcalls(e:Entity) {
        if (e.hasComponent(RenderableBinder)) return e.getComponent(RenderableBinder);
        var dc = new RenderableBinder();
        e.addComponent(dc);
        return dc;
    }

    public function getGldo(e:Entity, type, aspect, name) {
        var attrs = shaders.getAttributeSet(type);
        var dc = getDrawcalls(e);
        var gldo = dc.findLayer(attrs, name);
        if (gldo != null) return gldo;
        var gldo = new GLDisplayObject(attrs, shaders.getState.bind(attrs, _, type), aspect);
        gldo.name = name;
        var dc = getDrawcalls(e);
        dc.addLayer(attrs, gldo, name);
        return gldo;
    }
}

class TextureStorage {
    var locations:Map<String, GLTexture> = new Map();

    public function new() {}

    public function get(gl:WebGLRenderContext, filename:String) {
        if (locations.exists(filename)) return locations.get(filename);
        var tex = gl.createTexture();
        var image = lime.utils.Assets.getImage(filename);
        gl.bindTexture(gl.TEXTURE_2D, tex);
        gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, image.buffer.width, image.buffer.height, 0, gl.RGBA, gl.UNSIGNED_BYTE, image.data);
        gl.bindTexture(gl.TEXTURE_2D, null);
        locations[filename] = tex;
        return tex;
    }
}

class InputRoot {
    var factors:AspectRatio;
    var input:InputTarget<Point>;
    var pos = new Point();
    var stg:openfl.display.Stage;


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