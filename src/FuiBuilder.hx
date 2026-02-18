package;

import fu.UikitBase;
import al.openfl.display.FlashBinder;
import openfl.display.DisplayObjectContainer;
import a2d.AspectRatioProvider;
import a2d.Placeholder2D;
import a2d.PlaceholderBuilder2D;
import a2d.Stage;
import a2d.Widget.ResizableWidget2D;
import a2d.WindowSizeProvider;
import a2d.transform.LiquidTransformer;
import al.Builder;
import al.animation.AnimatedSwitcher;
import al.animation.AnimationTreeBuilder;
import al.ec.WidgetSwitcher;
import al.layouts.OffsetLayout;
import al.openfl.StageAspectResizer;
import al2d.WidgetHitTester2D;
import backends.lime.MouseRoot;
import backends.openfl.DrawcallUtils;
import data.aliases.AttribAliases;
import ec.CtxWatcher;
import ec.Entity;
import ecbind.ClickInputBinder;
import ecbind.InputBinder;
import fu.Uikit;
import fu.gl.GuiDrawcalls;
import fu.graphics.ShapeWidget;
import fu.input.FocusInputRoot;
import fu.input.MainPointer;
import fu.ui.PlaceholderBuilderUi;
import fu.ui.scroll.ScrollableContent.W2CScrollableContent;
import fu.ui.scroll.ScrollboxItem;
import gl.aspects.ScissorAspect;
import gl.sets.ColorSet;
import gl.sets.TexSet;
import graphics.ShapesColorAssigner;
import graphics.shapes.QuadGraphicElement;
import htext.style.TextContextBuilder;
import shimp.ClicksInputSystem;
import shimp.InputSystem;
import shimp.InputSystemsContainer;
import shimp.Point;
import update.RealtimeUpdater;
import update.UpdateBinder;
import update.Updater;
#if ginp
import fu.input.ButtonSignals;
import fu.input.NavigationButtons;
import ginp.ButtonInputBinder;
import ginp.ButtonsMapper;
import ginp.presets.BasicGamepad;
import utils.MacroGenericAliasConverter as MGA;
#end

class FuiBuilder {
    public var stage(get, null):Stage;
    @:deprecated public var ar:Stage;
    public var placeholderBuilder(default, null):PlaceholderBuilderUi;
    public var updater(default, null):Updater;
    public var uikit(default, null):UikitBase;

    public function new(stage:Stage, uikit = null) {
        this.ar = stage;
        this.uikit = uikit ?? new Uikit(stage);
        placeholderBuilder = new PlaceholderBuilderUi(ar);
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
        var ar = this.ar;
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
        return rootEntity;
    }

    public function configureInput(root:Entity) {
        var s = new InputSystemsContainer(new Point(), null);
        root.addComponent(new InputBinder<Point>(s));
        var mouse = new MouseRoot(s, stage);
        root.addComponentByType(MainPointer, mouse);
        root.addComponent(new FocusInputRoot(s));
    }

    public function makeClickInput(w:Placeholder2D, ?hits:Placeholder2D) {
        var input = new ClicksInputSystem(new Point());
        w.entity.addComponent(new ClickInputBinder(input));
        var outside = new Point();
        outside.x = -9999999;
        outside.y = -9999999;
        w.entity.addComponentByType(InputSystemTarget, new SwitchableInputAdapter(input, new WidgetHitTester2D(hits ?? w), new Point(), outside));
        new CtxWatcher(InputBinder, w.entity);
        return w;
    }

    #if ginp
    public function createArrowNavigationSignals(e:Entity, align:Axis2D) {
        switch align {
            case horizontal:
                createHorizontalNavigationSignals(e);
            case vertical:
                createVerticalNavigationSignals(e);
        }
    }

    public function createVerticalNavigationSignals(e:Entity) {
        createNavigationButtonSignals(e, [down => forward, up => backward]);
    }

    public function createHorizontalNavigationSignals(e:Entity) {
        createNavigationButtonSignals(e, [right => forward, left => backward]);
    }

    public function createTabNavigationSignals(e:Entity) {
        createNavigationButtonSignals(e, [tright => forward, tleft => backward]);
    }

    /**
        Creates ButtonSignals<NavigationButtons> with given mapping, listening for BasicGamepadButtons ctx.
    **/
    public function createNavigationButtonSignals(e:Entity, mapping:Map<BasicGamepadButtons, NavigationButtons>) {
        var input:ButtonsMapper<BasicGamepadButtons, NavigationButtons> = new ButtonsMapper(mapping);
        ButtonInputBinder.addListener(BasicGamepadButtons, e, input);
        var buttonsToSignals = new ButtonSignals();
        input.addListener(buttonsToSignals);
        e.addComponentByName(MGA.toAlias(ButtonSignals, NavigationButtons), buttonsToSignals);
    }
    #end

    public function configureScreen(root:Entity) {
        root.addComponentByType(Stage, ar);
        root.addComponentByType(AspectRatioProvider, ar);
        root.addComponentByType(WindowSizeProvider, ar);
        root.addComponentByType(PlaceholderBuilder2D, placeholderBuilder);
        return root;
    }

    public function configureDisplayRoot(root:Entity, target:DisplayObjectContainer) {
        var fdr = root.getComponent(FlashBinder);
        if (fdr != null) {
            var canvas = fdr.container;
            target.addChild(canvas);
        } else {
            fdr = new FlashBinder(target);
            root.addComponent(fdr);
        }
        fdr.bind(root);
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
        return name == null ? uikit.textStyles.defaultStyle() : uikit.textStyles.getStyle(name);
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
        };
        if (createGldo) {
            uikit.createContainer(w.entity, Xml.parse(PictureDrawcalls.DRAWCALLS_LAYOUT(filename)).firstElement());
        }
        return shw;
    }

    function get_stage():Stage {
        return ar;
    }
}
