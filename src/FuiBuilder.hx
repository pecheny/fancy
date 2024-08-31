package;

import gl.aspects.AlphaBlendingAspect;
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
import fu.graphics.ShapeWidget;
import gl.AttribSet;
import gl.GLNode;
import gl.OflGLNodeAdapter;
import gl.RenderingPipeline;
import gl.aspects.RenderingAspect;
import gl.aspects.ScissorAspect;
import gl.aspects.TextureBinder;
import gl.passes.FlatColorPass;
import gl.passes.ImagePass;
import gl.passes.MsdfPass;
import gl.sets.ColorSet;
import gl.sets.TexSet;
import graphics.ShapesColorAssigner;
import graphics.shapes.QuadGraphicElement;
import htext.style.TextContextBuilder;
import openfl.Lib;
import openfl.display.Sprite;
import shaderbuilder.ShaderElement;
import shimp.ClicksInputSystem;
import shimp.InputSystem;
import shimp.InputSystemsContainer;
import shimp.Point;
import update.RealtimeUpdater;
import update.UpdateBinder;
import update.Updater;

class XmlLayerLayouts {
	public static final COLOR_AND_TEXT = '<container>
    <drawcall type="color"/>
    <drawcall type="text" font=""/>
    </container>';
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
		pipeline.addAspect(sc);
	}

	public dynamic function regDefaultDrawcalls():Void {
		pipeline.addPass(new FlatColorPass());
		pipeline.addPass(new MsdfPass().withAspectRegistrator(fontTextureExtractor).withLayerNameExtractor(fontLayerAliasExtractor));
		pipeline.addPass(new ImagePass().withAspectRegistrator(imageTextureExtractor));
	}

	public function createContainer(e:Entity, descr):Entity {
        RenderableBinder.getOrCreate(e); // to prevent
		var node = pipeline.createContainer(descr); 
        node.addAspect(new AlphaBlendingAspect());
		bindLayer(e, node);
		var adapter = new OflGLNodeAdapter();
		adapter.addNode(node);
		Lib.current.stage.addChild(adapter);
		return e;
	}

    function bindLayer(e, glnode:GLNode) {
		var binder = RenderableBinder.getOrCreate(e);
		if (Std.isOfType(glnode, ContainerGLNode)) {
			var c = cast(glnode, ContainerGLNode);
			for (ch in c.children)
				bindLayer(e, ch);
		}
		if (Std.isOfType(glnode, ShadedGLNode)) {
			var gldo:ShadedGLNode<AttribSet> = cast glnode;
			binder.bindLayer(e, gldo.set, glnode.name, gldo);
		}
	}


	public function addBmFont(fontName, fntPath) {
		var font = fonts.initFont(fontName, fntPath, null);
		return this;
	}

	function imageTextureExtractor(xml:Xml, aspects:RenderAspectBuilder) {
		if (!xml.exists("path"))
			throw '<image /> gldo should have path property';
		aspects.add(new TextureBinder(pipeline.textureStorage, xml.get("path")));
	}

	function fontLayerAliasExtractor(xml:Xml) {
		var fontName = xml.get("font");
		var font = fonts.getFont(fontName);
		if (font == null)
			throw 'there is no font $fontName';
		return font.getId();
	}

	function fontTextureExtractor(xml:Xml, aspects:RenderAspectBuilder) {
		var fontName = xml.get("font");
		var font = fonts.getFont(fontName);
		if (font == null)
			throw 'there is no font $fontName';
		aspects.add(new TextureBinder(pipeline.textureStorage, font.texturePath));
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