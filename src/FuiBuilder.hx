package;

import ecbind.RenderableBinder;
import a2d.transform.LiquidTransformer;
import fu.graphics.ShapeWidget;
import gl.GldoBuilder;
import gl.XmlProc;
import backends.openfl.OpenflBackend;
import a2d.PlaceholderBuilder2D;
import openfl.display.Sprite;
import al.openfl.display.FlashDisplayRoot;
import al.openfl.display.DrawcallDataProvider;
import data.aliases.AttribAliases;
import update.UpdateBinder;
import graphics.ShapesColorAssigner;
import graphics.shapes.QuadGraphicElement;
import al.openfl.StageAspectResizer;
import al.ec.WidgetSwitcher;
import al.Builder;
import gl.aspects.TextureBinder;
import shaderbuilder.TextureFragment;
import gl.sets.TexSet;
import a2d.AspectRatioProvider;
import a2d.Stage;
import a2d.WindowSizeProvider;
import a2d.Placeholder2D;
import al.animation.AnimationTreeBuilder;
import al.layouts.OffsetLayout;
import ec.CtxWatcher;
import ec.Entity;
import ecbind.ClickInputBinder;
import ecbind.InputBinder;
import font.bmf.BMFont.BMFontFactory;
import font.FontStorage;
import gl.aspects.RenderingAspect;
import gl.AttribSet;
import gl.GLDisplayObject;
import gl.sets.ColorSet;
import gl.sets.MSDFSet;
import gl.ShaderRegistry;
import htext.style.TextContextBuilder;
import gl.aspects.ScissorAspect;
import shaderbuilder.MSDFShader;
import shaderbuilder.ShaderElement;
import shaderbuilder.SnaderBuilder;
import shimp.ClicksInputSystem;
import shimp.InputSystem;
import shimp.InputSystemsContainer;
import update.RealtimeUpdater;
import update.Updater;
import utils.TextureStorage;
import al2d.WidgetHitTester2D;
import shimp.Point;

class XmlLayerLayouts {
    public static final COLOR_AND_TEXT = '<container>
    <drawcall type="color"/>
    <drawcall type="text" font=""/>
    </container>';
}

class RenderingPipeline {
    public var renderAspectBuilder(default, null):RenderAspectBuilder;
    public var textureStorage:TextureStorage;
    public var shaderRegistry:ShaderRegistry;
    var gldoBuilder:GldoBuilder;
    var pos:ShaderElement = PosPassthrough.instance;
    var xmlProc:XmlProc;
    var sharedAspects:Array<RenderingAspect>;
    public function new() {
    
        textureStorage = new TextureStorage();
        shaderRegistry = new ShaderRegistry();
        // gldoBuilder = new GldoBuilder(shaderRegistry);
        xmlProc = new XmlProc();
        setAspects([]);

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


    public function createContainer(e:Entity, descr):Entity {
        RenderableBinder.getOrCreate(e); // to prevent
        xmlProc.processNode(e, descr);
        return e;
    }
    
    public function createGldo<T:AttribSet>(attrs:T, e:Entity, type:String, aspect:RenderingAspect, name:String):GLDisplayObject<T> {
        renderAspectBuilder.newChain();
        if (aspect != null)
            renderAspectBuilder.add(aspect);
        var aspects = renderAspectBuilder.build();
        var gldo = new GLDisplayObject(attrs, shaderRegistry.getState.bind(attrs, _, type), aspects);
        var binder = RenderableBinder.getOrCreate(e);
        binder.bindLayer(e, attrs, type, name, gldo);
        return gldo;
    }
}

class FuiBuilder {
    public var pipeline:RenderingPipeline;
    public var ar:Stage = new StageImpl(1);
    public var fonts(default, null) = new FontStorage(new BMFontFactory());
    public var placeholderBuilder(default, null):PlaceholderBuilder2D;
    public var textStyles:TextContextBuilder;
    public var updater(default, null):Updater;


    public function new() {
        this.pipeline = new RenderingPipeline();
        placeholderBuilder = new PlaceholderBuilder2D(ar);
        textStyles = new TextContextBuilder(fonts, ar);
        var updater = new RealtimeUpdater();
        updater.update();
        this.updater = updater;
        #if openfl
        openfl.Lib.current.stage.addEventListener(openfl.events.Event.ENTER_FRAME, _ -> updater.update());
        #end
    }

    public function createDefaultRoot(dl, font = "Assets/fonts/robo.fnt") {
        var rw = Builder.widget();
        var rootEntity = rw.entity;
        this.regDefaultDrawcalls();
        var ar = this.ar;
        this.addBmFont("", font); // todo
        this.configureInput(rootEntity);
        this.configureScreen(rootEntity);
        this.configureAnimation(rootEntity);
        rootEntity.addComponent(this);

        this.createContainer(rootEntity, Xml.parse(dl).firstElement());

        rootEntity.addComponent(new UpdateBinder(updater));

        var fitStyle = this.textStyles.newStyle("fit")
            .withSize(pfr, .5)
            .withAlign(horizontal, Forward)
            .withAlign(vertical, Backward)
            .withPadding(horizontal, pfr, 0.33)
            .withPadding(vertical, pfr, 0.33)
            .build();
        rootEntity.addComponent(fitStyle);

        textStyles.resetToDefaults();

        var v = new StageAspectResizer(rw, 2);
        var switcher = new WidgetSwitcher(rw);
        rootEntity.addComponent(switcher);
        rootEntity.addComponentByType(TextContextStorage, textStyles);
        return rootEntity;
    }
    public function addScissors(w:Placeholder2D) {
        var sc = new ScissorAspect(w, ar.getAspectRatio());
        @:privateAccess pipeline.sharedAspects.push(sc);
    }

    public dynamic function regDefaultDrawcalls():Void {
        new FlatColorPass(pipeline).register();
        new MsdfPass(pipeline, fonts).register();
        new ImagePass(pipeline).register();
    }

    public function createContainer(e:Entity, descr):Entity {
        return pipeline.createContainer(e, descr);
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
        w.entity.addComponentByType(InputSystemTarget, new SwitchableInputAdapter(input, new WidgetHitTester2D(w), new Point(), outside));
        new CtxWatcher(InputBinder, w.entity);
        return w;
    }

    public function configureScreen(root:Entity) {
        root.addComponentByType(Stage, ar);
        root.addComponentByType(AspectRatioProvider, ar);
        root.addComponentByType(WindowSizeProvider, ar);
        root.addComponentByType(PlaceholderBuilder2D, placeholderBuilder);

        return root;
    }

    public function configureAnimation(root:Entity) {
        root.addComponentByType(Updater, updater);
        var animBuilder = new AnimationTreeBuilder();
        animBuilder.addLayout(OffsetLayout.NAME, new OffsetLayout(0.1));
        root.addComponent(animBuilder);
        return root;
    }


    /// Shortcuts
    public inline function s(name = null) {
        return name == null ? textStyles.defaultStyle() : textStyles.getStyle(name);
    }

    public function lqtr(ph) {
        return LiquidTransformer.withLiquidTransform(ph, ar.getAspectRatio());
    }

    public function quad(ph:Placeholder2D, color) {
        lqtr(ph);
        var attrs = ColorSet.instance;
        var shw = new ShapeWidget(attrs, ph, true);
        shw.addChild(new QuadGraphicElement(attrs));
        var colors = new ShapesColorAssigner(attrs, color, shw.getBuffer());
        ph.entity.addComponent(colors);
        shw.manInit();
        return shw;
    }

    public function texturedQuad(w, filename, createGldo = true):ShapeWidget<TexSet> {
        var attrs = TexSet.instance;
        var shw = new ShapeWidget(attrs, w);
        shw.addChild(new QuadGraphicElement(attrs));
        var uvs = new graphics.DynamicAttributeAssigner(attrs, shw.getBuffer());
        uvs.fillBuffer = (attrs:TexSet, buffer) -> {
            var writer = attrs.getWriter(AttribAliases.NAME_UV_0);
            QuadGraphicElement.writeQuadPostions(buffer.getBuffer(), writer, 0, (a, wg) -> wg);
            trace(attrs.printVertex(buffer.getBuffer(), 1));
        };
        if (createGldo) {
            createContainer(w.entity, Xml.parse('<container><drawcall type="image" font="" path="$filename" /></container>').firstElement());
            var spr:Sprite = w.entity.getComponent(Sprite);
            var dp = DrawcallDataProvider.get(w.entity);
            new CtxWatcher(FlashDisplayRoot, w.entity);
            dp.views.push(spr);
        }
        return shw;
    }
}

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
