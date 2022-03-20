package ;
import data.DataType;
import bindings.GLTexture;
import bindings.WebGLRenderContext;
import ec.Entity;
import font.bmf.BMFont.BMFontFactory;
import font.FontInstance;
import font.FontStorage;
import font.IFont;
import gl.aspects.RenderingAspect;
import gl.AttribSet;
import gl.ec.Drawcalls;
import gl.GLDisplayObject;
import gl.sets.ColorSet;
import gl.sets.MSDFSet;
import gl.ShaderRegistry;
import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;
import shaderbuilder.MSDFShader.LogisticSmoothnessCalculator;
import shaderbuilder.MSDFShader.MSDFFrag;
import shaderbuilder.MSDFShader.MSDFRenderingElement;
import shaderbuilder.ShaderElement;
import shaderbuilder.SnaderBuilder.ColorPassthroughFrag;
import shaderbuilder.SnaderBuilder.ColorPassthroughVert;
import shaderbuilder.SnaderBuilder.PosPassthrough;
import shaderbuilder.SnaderBuilder.Uv0Passthrough;
import text.h2d.H2dTextLayouter.H2dCharsLayouterFactory;
import text.TextLayouter.CharsLayouterFactory;

class DummyFrag implements ShaderElement {
    public function new() {}

    public function getDecls():String {
        return "";
    }

    public function getExprs():String {
        return 'gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);';
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
            }, createTextGldo
        );
    }

    function createTextGldo(e, descr:Xml) {
        var fontName = descr.get("font");
        var font = fuiBuilder.fonts.getFont(fontName);
        if (font == null)
            throw 'there is no font $fontName';
        var aspect = fuiBuilder.renderAspectBuilder.newChain().add(new MSDFRenderingElement(fuiBuilder.textureStorage, font.texturePath)).build();
        return fuiBuilder.createGldo(MSDFSet.instance, e, "msdf", aspect, font.getId());
    }
}

class FuiBuilder {
    public var renderAspectBuilder(default, null):RenderAspectBuilder;
    public var textureStorage:TextureStorage;
    public var shaderRegistry:ShaderRegistry;
    public var fonts(default, null) = new FontStorage(new BMFontFactory());
    var gldoBuilder:GldoBuilder ;
    var pos:ShaderElement = PosPassthrough.instance;
    var xmlProc:XmlProc ;

    public function new() {
        textureStorage = new TextureStorage();
        shaderRegistry = new ShaderRegistry();
        gldoBuilder = new GldoBuilder(shaderRegistry);
        xmlProc = new XmlProc(gldoBuilder);
        setAspects([]);
    }

    public function regDrawcallType<T:AttribSet>(drawcallType:String, shaderDesc:ShaderDescr<T>, gldoFactory:GldoFactory<T>) {
        shaderRegistry.reg(shaderDesc);
        xmlProc.regHandler(drawcallType, gldoFactory);
    }

//    function shaderDescrs(pos) {
//        var descrs = [
//        {
//            type:"texture",
//            attrs:TexSet.instance,
//            vert:[Uv0Passthrough.instance, pos],
//            frag:[cast TextureFragment.get(0, 0)] // todo check
//        },
//        {
//            type:"msdf",
//            attrs:MSDFSet.instance,
//            vert:[Uv0Passthrough.instance, pos, LogisticSmoothnessCalculator.instance],
//            frag:[cast MSDFFrag.instance]
//        } ] ;
//        return descrs;
//    }


    public function setAspects(a:Array<RenderingAspect>) {
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

    public function createContainer(e:Entity, descr) {
        xmlProc.processNode(e, descr);
        return e;
    }

    public function addBmFont(fontName, fntPath) {
        var font = fonts.initFont(fontName, fntPath, null, 8);
        return this;
    }

    public function createTextStyle(fontName) {
        var font = fonts.getFont(fontName);
        return new TextStyleContext(new H2dCharsLayouterFactory(font.font), font) ;
    }
}

class TextStyleContext {
    public var layouterFactory(default, null):CharsLayouterFactory;
    var font:FontInstance<IFont>;

    public function new(lf, f) {
        this.layouterFactory = lf;
        this.font = f;
    }

    public function getDrawcallName() {
        return font.getId();
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
