package ;
import scroll.ScissorAspect;
import al.al2d.Widget2D;
import text.style.TextContextBuilder;
import al.al2d.AspectRatio;
import al.al2d.Axis2D;
import bindings.GLTexture;
import bindings.WebGLRenderContext;
import ec.Entity;
import font.bmf.BMFont.BMFontFactory;
import font.FontStorage;
import gl.aspects.RenderingAspect;
import gl.AttribSet;
import gl.ec.Drawcalls;
import gl.GLDisplayObject;
import gl.sets.ColorSet;
import gl.sets.MSDFSet;
import gl.ShaderRegistry;
import haxe.ds.ReadOnlyArray;
import input.core.InputSystemsContainer;
import input.core.InputTarget;
import input.ec.binders.SwitchableInputBinder;
import input.Point;
import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;
import openfl.display.Stage;
import openfl.events.Event;
import openfl.events.MouseEvent;
import shaderbuilder.MSDFShader.LogisticSmoothnessCalculator;
import shaderbuilder.MSDFShader.MSDFFrag;
import shaderbuilder.MSDFShader.MSDFRenderingElement;
import shaderbuilder.ShaderElement;
import shaderbuilder.SnaderBuilder.ColorPassthroughFrag;
import shaderbuilder.SnaderBuilder.ColorPassthroughVert;
import shaderbuilder.SnaderBuilder.PosPassthrough;
import shaderbuilder.SnaderBuilder.Uv0Passthrough;
import transform.AspectRatioProvider;

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
interface Size2D {
    function getValue(a:Axis2D):Float;
}
class StageAspectKeeper implements AspectRatioProvider implements Size2D {
    var base:Float;
    var factors:Array<Float> = [1, 1];
    var width:Float;
    var height:Float;

    public function new(base:Float = 1) {
        this.base = base;
        openfl.Lib.current.stage.addEventListener(Event.RESIZE, onResize);
        onResize(null);
    }

    function onResize(e) {
        var stage = openfl.Lib.current.stage;
        width = stage.stageWidth;
        height = stage.stageHeight;
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

    public function getValue(a:Axis2D):Float {
        return if (a == horizontal) width else height;
    }
}

class FuiAppBase extends Sprite {
    var fuiBuilder:FuiBuilder;

    public function new() {
        super();
        fuiBuilder = new FuiBuilder();
        fuiBuilder.regDrawcallType(
            "color",
            {
                type:"color",
                attrs:ColorSet.instance,
                vert:[ColorPassthroughVert.instance, PosPassthrough.instance],
                frag:[cast ColorPassthroughFrag.instance],
            }, (e, xml) -> fuiBuilder.createGldo(ColorSet.instance, e, "color", null, "")
        );

        fuiBuilder.regDrawcallType(
            "text",
            {
                type:"msdf",
                attrs:MSDFSet.instance,
                vert:[Uv0Passthrough.instance, PosPassthrough.instance, LogisticSmoothnessCalculator.instance],
                frag:[cast MSDFFrag.instance],
                uniforms: ["color" ]
            }, fuiBuilder.createTextGldo
        );
    }
}

class FuiBuilder {
    public var ar = new StageAspectKeeper(1);
    public var renderAspectBuilder(default, null):RenderAspectBuilder;
    public var textureStorage:TextureStorage;
    public var shaderRegistry:ShaderRegistry;
    public var fonts(default, null) = new FontStorage(new BMFontFactory());
    public var textStyles:TextContextBuilder;
    var gldoBuilder:GldoBuilder ;
    var pos:ShaderElement = PosPassthrough.instance;
    var xmlProc:XmlProc;
    var sharedAspects:Array<RenderingAspect>;


    public function new() {
        textureStorage = new TextureStorage();
        shaderRegistry = new ShaderRegistry();
        gldoBuilder = new GldoBuilder(shaderRegistry);
        xmlProc = new XmlProc(gldoBuilder);
        textStyles = new TextContextBuilder(fonts, ar);
        setAspects([]);
    }

    public function regDrawcallType<T:AttribSet>(drawcallType:String, shaderDesc:ShaderDescr<T>, gldoFactory:GldoFactory<T>) {
        shaderRegistry.reg(shaderDesc);
        xmlProc.regHandler(drawcallType, gldoFactory);
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
        var font = fonts.getFont(fontName);
        if (font == null)
            throw 'there is no font $fontName';
        var aspect = renderAspectBuilder.newChain().add(new MSDFRenderingElement(textureStorage, font.texturePath)).build();
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
        var aspects = root.getComponent(AspectRatioProvider);
        var s = new InputSystemsContainer(new Point(), null);
        root.addComponent(new SwitchableInputBinder<Point>(s));
        new InputRoot(s, aspects.getFactorsRef());
    }

    public function addScissors(w:Widget2D) {
        var  sc = new ScissorAspect(w, ar.getFactorsRef());
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
                if (container != null) container.addChild(gldo);
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
        if (e.hasComponent(Drawcalls)) return e.getComponent(Drawcalls);
        var dc = new Drawcalls();
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