package fu;

import a2d.ContainerStyler;
import a2d.Placeholder2D;
import a2d.Stage;
import a2d.Widget.ResizableWidget2D;
import al.openfl.display.DrawcallDataProvider;
import al.openfl.display.FlashBinder;
import al.openfl.display.FlashDisplayRoot;
import backends.openfl.DrawcallUtils;
import dkit.Dkit;
import ec.CtxWatcher;
import ec.Entity;
import ecbind.RenderableBinder;
import font.FontStorage;
import font.bmf.BMFont.BMFontFactory;
import fu.PropStorage;
import fu.ui.scroll.ScrollableContent;
import fu.ui.scroll.ScrollboxItem;
import gl.GLNode;
import gl.OflGLNodeAdapter;
import gl.RenderingPipeline;
import gl.aspects.AlphaBlendingAspect;
import gl.aspects.ScissorAspect;
import htext.style.TextContextBuilder;
import openfl.display.DisplayObject;
import openfl.display.Sprite;

class UikitBase {
    public var pipeline:RenderingPipeline;
    public var fonts(default, null) = new FontStorage(new BMFontFactory());
    public var textStyles(default, null):TextContextBuilder;
    public var containers(default, null):ContainerStyler;
    public var properties(default, null):MultiPropStorage;
    public var stage:Stage;

    var drawcallsLayout(default, null):Xml;
    var fontPath:String;

    public function new(stage:Stage, defaultDcLayout:Xml, defaultFontPath:String, ?pipeline:RenderingPipeline) {
        this.stage = stage;
        this.pipeline = pipeline ?? new RenderingPipeline();
        this.drawcallsLayout = defaultDcLayout;
        this.fontPath = defaultFontPath;
        textStyles = new TextContextBuilder(fonts, stage);
        properties = new MultiPropStorage();
        containers = new ContainerStyler();
    }

    public function configure(e:Entity) {
        fonts.initFont("", fontPath, null);
        regDefaultDrawcalls();
        regStyles(e);
        regLayouts(e);
        e.addComponent(properties);
        e.addComponent(containers);
        e.addComponentByType(TextContextStorage, textStyles);
        e.addComponent(textStyles.getStyle(TextContextBuilder.DEFAULT_STYLE));
    }

    function regStyles(e:Entity) {
        textStyles.newStyle(TextContextBuilder.DEFAULT_STYLE)
            .withSize(sfr, .07)
            .withPadding(horizontal, sfr, 0.1)
            .withAlign(vertical, Center)
            .build();
        textStyles.resetToDefaults();
        properties.setString(Dkit.TEXT_STYLE, TextContextBuilder.DEFAULT_STYLE);
    }

    function regLayouts(e:Entity) {}

    function regDefaultDrawcalls():Void {}

    function addScissors(ph:Placeholder2D) {
        var sc = new ScissorAspect(ph, stage.getAspectRatio());
        pipeline.addAspect(sc);
    }

    public function createScrollbox(content:ResizableWidget2D, placeholder:Placeholder2D, ?dl:Xml) {
        var scroll = new W2CScrollableContent(content, placeholder);
        placeholder.entity.name = "placeholder";
        var scroller = new ScrollboxItem(placeholder, scroll, stage.getAspectRatio());
        addScissors(placeholder);
        createContainer(scroller.ph.entity, dl);
        pipeline.renderAspectBuilder.reset();
        return placeholder;
    }

    public function createContainer(e, ?layout:Xml) {
        layout = layout ?? drawcallsLayout;
        RenderableBinder.getOrCreate(e); // to prevent
        var node:GLNode = null;
        var hasFlash = layout.elementsNamed("openfl").hasNext();
        pipeline.unknownNodeHandler = defaultNodeHandler;

        var adapter:DisplayObject = null;
        if (hasFlash) {
            pipeline.unknownNodeHandler = xmlNodeHandler.bind(e);
            var mixer = new OflGLNodeMixer();
            adapter = mixer;
            node = mixer;
            for (xmln in layout.elements()) {
                pipeline.processNode(xmln, mixer);
            }
            pipeline.renderAspectBuilder.reset();
            pipeline.unknownNodeHandler = defaultNodeHandler;
        } else {
            node = pipeline.createContainer(drawcallsLayout);
            var _adapter = new OflGLNodeAdapter();
            adapter = _adapter;
            _adapter.addNode(node);
        }
        DrawcallUtils.bindLayer(e, node);
        node.addAspect(new AlphaBlendingAspect());
        DrawcallDataProvider.get(e).addView(adapter);
        new CtxWatcher(FlashDisplayRoot, e, true);
        return e;
    }

    function defaultNodeHandler(node:Xml, ?container:Null<ContainerGLNode>) {
        throw "wrong " + node.nodeName;
    }

    function xmlNodeHandler(e:Entity, node:Xml, ?container:Null<ContainerGLNode>) {
        switch node.nodeName {
            case "openfl":
                var container:OflGLNodeMixer = cast container;
                var canvas = new Sprite();
                container.addChild(canvas);
                var froot = new FlashBinder(canvas);
                e.addComponent(froot);
                if (!e.hasComponent(FlashDisplayRoot))
                    e.addComponentByType(FlashDisplayRoot, froot);
            case _:
                throw "wrong " + node.nodeName;
        }
    }
}
