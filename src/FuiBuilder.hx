package;

import fu.FuCtx;
import backends.openfl.DrawcallUtils;
import al.animation.AnimatedSwitcher;
import a2d.Widget.ResizableWidget2D;
import fu.ui.scroll.ScrollboxItem;
import a2d.Widget2DContainer;
import fu.ui.scroll.ScrollableContent.W2CScrollableContent;
import htext.FontAspectsFactory;
import gl.passes.ImagePass;
import gl.aspects.ExtractionUtils;
import a2d.AspectRatioProvider;
import a2d.Placeholder2D;
import a2d.PlaceholderBuilder2D;
import a2d.Stage;
import a2d.WindowSizeProvider;
import a2d.transform.LiquidTransformer;
import al.Builder;
import al.animation.AnimationTreeBuilder;
import al.ec.WidgetSwitcher;
import al.layouts.OffsetLayout;
import al.openfl.StageAspectResizer;
import al.openfl.display.DrawcallDataProvider;
import al.openfl.display.FlashDisplayRoot;
import al2d.WidgetHitTester2D;
import backends.openfl.OpenflBackend;
import data.aliases.AttribAliases;
import ec.CtxWatcher;
import ec.Entity;
import ecbind.ClickInputBinder;
import ecbind.InputBinder;
import ecbind.RenderableBinder;
import font.FontStorage;
import font.bmf.BMFont.BMFontFactory;
import fu.gl.GuiDrawcalls;
import fu.graphics.ShapeWidget;
import gl.AttribSet;
import gl.GLNode;
import gl.OflGLNodeAdapter;
import gl.RenderingPipeline;
import gl.aspects.AlphaBlendingAspect;
import gl.aspects.ScissorAspect;
import gl.aspects.TextureBinder;
import gl.passes.FlatColorPass;
import gl.passes.MsdfPass;
import gl.sets.ColorSet;
import gl.sets.TexSet;
import graphics.ShapesColorAssigner;
import graphics.shapes.QuadGraphicElement;
import htext.style.TextContextBuilder;
import openfl.Lib;
import openfl.display.Sprite;
import shimp.ClicksInputSystem;
import shimp.InputSystem;
import shimp.InputSystemsContainer;
import shimp.Point;
import update.RealtimeUpdater;
import update.UpdateBinder;
import update.Updater;


class FuiBuilder implements FuCtx {
	public var fonts(default, null) = new FontStorage(new BMFontFactory());

	public var pipeline:RenderingPipeline;
	public var ar:Stage = new StageImpl(1);
	public var placeholderBuilder(default, null):PlaceholderBuilder2D;
	public var textStyles:TextContextBuilder;
	public var updater(default, null):Updater;

	public function new() {
		pipeline = new RenderingPipeline();
		placeholderBuilder = new PlaceholderBuilder2D(ar);
		textStyles = new TextContextBuilder(fonts, ar);
		var updater = new RealtimeUpdater();
		updater.update();
		this.updater = updater;
		#if openfl
		openfl.Lib.current.stage.addEventListener(openfl.events.Event.ENTER_FRAME, _ -> updater.update());
		#end
	}

	public function createDefaultRoot() {
		var rw = Builder.widget();
		var rootEntity = rw.entity;
		// this.regDefaultDrawcalls();
		var ar = this.ar;
		// this.addBmFont("", font); // todo
		this.configureInput(rootEntity);
		this.configureScreen(rootEntity);
		this.configureAnimation(rootEntity);
		rootEntity.addComponent(this);

		rootEntity.addComponent(new UpdateBinder(updater));
		var v = new StageAspectResizer(rw, 2);
		var switcher = new WidgetSwitcher(rw);
		rootEntity.addComponent(switcher);
        
        var screens = new AnimatedSwitcher(switcher);
        updater.addUpdatable(screens);
        rootEntity.addComponent(screens);

		rootEntity.addComponentByType(TextContextStorage, textStyles);
		return rootEntity;
	}

	public function addScissors(w:Placeholder2D) {
		var sc = new ScissorAspect(w, ar.getAspectRatio());
		pipeline.addAspect(sc);
	}



	// public function addBmFont(fontName, fntPath) {
	// 	var font = fonts.initFont(fontName, fntPath, null);
	// 	return this;
	// }

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

/**
    @param createGldo - if true, GLNode of Image type with apropriate TextureAspect would be created. 
    Can be useful if the image used just once in this place. Otherwise, if the image can be reused in other gui elements, this layer can be added to the default xml descr of ui
    Do not usse createGldo if the quad meant to be used in a scrollbox, add layer to the xmldesc argument instead.
**/
	public function texturedQuad(w, filename, createGldo = false):ShapeWidget<TexSet> {
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
			DrawcallUtils.createContainer(pipeline, w.entity, Xml.parse(PictureDrawcalls.DRAWCALLS_LAYOUT(filename)).firstElement());
		}
		return shw;
	}
    
    public function createScrollbox(content:ResizableWidget2D, placeholder:Placeholder2D,  dl) {
        var scroll = new W2CScrollableContent(content, placeholder);

        placeholder.entity.name = "placeholder";
        var scroller = new ScrollboxItem(placeholder, scroll, ar.getAspectRatio());
        addScissors(scroller.ph);
        DrawcallUtils.createContainer(pipeline, scroller.ph.entity, dl);
        pipeline.renderAspectBuilder.reset();
        return placeholder;
    }

}
