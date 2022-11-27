package ;
import a2d.AspectRatioProvider;
import a2d.Stage;
import a2d.WindowSizeProvider;
import al.al2d.Widget2DContainer;
import al.animation.Animation.AnimContainer;
import al.animation.Animation.AnimWidget;
import al.animation.AnimationTreeBuilder;
import al.Builder;
import al.core.Placeholder;
import al.core.WidgetContainer.AxisKeyBase;
import al.layouts.OffsetLayout;
import al.openfl.StageAspectResizer;
import algl.Builder.PlaceholderBuilderGl;
import algl.ScreenMeasureUnit;
import Axis2D;
import ec.Entity;
import FuiBuilder;
import htext.style.TextStyleContext;
import input.al.ButtonPanel;
import openfl.display.Sprite;
import openfl.events.Event;
import utils.Updatable.Updater;
import utils.Updatable;
import widgets.Widget;
import widgets.WonderButton;
import widgets.WonderQuad;

using FancyPg.Utils;
using transform.LiquidTransformer;
using al.Builder;
class ClickAndButt extends FuiAppBase implements Updater {
    public inline static var OFFSET:String = "offset";
    var upds:Array<Float -> Void> = [];

    public function new() {
        super();
        var sampleText = "FoEo Bar AbAb Aboo Distance Field texture Ad Ae Af Bd Be Bf Bb Ab Dd De Df Cd Ce Cf";
        var root:Entity = new Entity();
        var ar = fuiBuilder.ar;
        var b = new PlaceholderBuilderGl(ar);
//        fuiBuilder.addBmFont("", "Assets/heaps-fonts/monts.fnt"); // todo
        fuiBuilder.addBmFont("", "Assets/heaps-fonts/robo.fnt"); // todo
        root.addComponentByType(AspectRatioProvider, fuiBuilder.ar);
        root.addComponentByType(WindowSizeProvider, fuiBuilder.ar);
        root.addComponentByType(Stage, fuiBuilder.ar);
        fuiBuilder.configureInput(root);

        var dl =
        '<container>
        <drawcall type="color"/>
        <drawcall type="text" font=""/>
        </container>';
        fuiBuilder.createContainer(root, Xml.parse(dl).firstElement());
        var container:Sprite = root.getComponent(Sprite);
        addChild(container);

        var fitStyle = fuiBuilder.textStyles.newStyle("fit")
//        .withSizeInPixels(48)
        .withSize(pfr, .5)
        .withAlign(horizontal, Forward)
        .withAlign(vertical, Backward)
        .withPadding(horizontal, pfr, 0.33)
        .withPadding(vertical, pfr, 0.33)
        .build();


        root.addComponent(fitStyle);


        var stage = ar;

        root.addComponentByType(Updater, this);
        var animBuilder = new AnimationTreeBuilder();
        animBuilder.addLayout(OFFSET, new OffsetLayout(0.1));
        root.addComponent(animBuilder);
        root.addComponent(new algl.Builder.PlaceholderBuilderGl(stage));
        var rw = Builder.widget();
        root.addChild(rw.entity);
        var screens = new Screens(new WidgetSwitcher(rw));
        upds.push(screens.update);
        root.addComponent(screens);

        var s1 = new ScreenOne(Builder.widget());
        var s2 = new ScreenTwo(Builder.widget());
        screens.add(Screens.ONE, s1);
        screens.add(Screens.TWO, s2);
        screens.switchTo(Screens.ONE);
//        b.addWidget(rw.entity.getComponent(Widget2DContainer), s1.widget());

        var v = new StageAspectResizer(rw, 2);
//        v.onResize(null);
        openfl.Lib.current.stage.addEventListener(Event.ENTER_FRAME, update);
    }


    function update(e) {
        for (u in upds)
            u(1 / 60);
    }

    public function addUpdatable(e:Updatable):Void {
        upds.push(e.update);
    }

    public function removeUpdatable(e:Updatable):Void {
        upds.remove(e.update);
    }
}
class WidgetSwitcher<T:AxisKeyBase> {
    var root:Placeholder<T>;
    var current:Placeholder<T>;

    public function new(root:Placeholder<T>) {
        this.root = root;
    }

    public function switchTo(target:Placeholder<T>) {
        if (current != null) {
            unbind(current);
            current = null;
        }

        if (target != null) {
            bind(target);
            current = target;
        }
    }

    public function bind(target:Placeholder<T>) {
        for (a in root.axisStates.axes()) {
            var state = root.axisStates[a];
            var chState = target.axisStates[a];
            state.addSibling(chState);
            chState.apply(state.getPos(), state.getSize());
        }
        root.entity.addChild(target.entity);
    }

    public function unbind(target:Placeholder<T>) {
        for (a in root.axisStates.axes()) {
            var state = root.axisStates[a];
            var chState = target.axisStates[a];
            state.removeSibling(chState);
        }
        root.entity.removeChild(target.entity);
    }
}
class Screens implements Updatable {
    var tree:AnimWidget;
    var time:Float = 0;
    var e1 = (t:Float) -> {
        var a1 = Math.abs((Math.sin(Math.PI * t / 2)));
        return Math.pow(a1, 2);
    }

    var e2 = t -> {
        var a1 = Math.abs((Math.sin(Math.PI * t / 2)));
        return Math.pow(a1, 2);
    }

    var duration = 2.;
    public inline static var ONE:String = "one";
    public inline static var TWO:String = "TWO";

    public var screens:Map<String, Screen> = new Map();
    public var switcher:WidgetSwitcher<Axis2D>;
    var prev:Screen;
//    var next:Screen;
    var current:Screen;

    public function new(switcher) {
        this.switcher = switcher;
        tree = new AnimationTreeBuilder().build(
            {
                layout:"portion",
                children:[
                    {size:{value:1. }},
                    {size:{value:1. }},
                ]
            }
        );
        tree.bindAnimation(0, t -> {if (prev != null) prev.setT(1 - t);});
        tree.bindAnimation(1, t -> {if (current != null) current.setT(t);});
    }

    public function add(name, screen) {
        screens[name] = screen;
        switcher.bind(screen.widget());
        switcher.unbind(screen.widget());
    }

    public function switchTo(name) {
        time = current != null ? 0 : 0.5;
        prev = current;
        current = screens[name];
        switcher.bind(current.widget());
    }

    public function update(dt:Float):Void {
        if (time == 1 || current == null)
            return;
        time += dt / duration;
        if (time >= 1) time = 1;
        tree.setTime(time);
        if (time == 1 && prev != null) {
            switcher.unbind(prev.widget());
            prev = null;
        }
    }
}


class Screen extends Widget {
    var tree:AnimWidget;

    public function setT(t:Float) {
        if (tree == null)
            return;
        tree.setTime(t);
        for (a in Axis2D) {
            var axis = w.axisStates[a];
            axis.apply(axis.getPos(), axis.getSize());
        }
    }
}
class ScreenOne extends Screen {

    @:once var b:PlaceholderBuilderGl;
    @:once var screens:Screens;
    @:once var animationTreeBuilder:AnimationTreeBuilder;
    @:once var textStyleContext:TextStyleContext;
    @:once var stage:Stage;

    var pnl:Widget2DContainer;
    var animContainer:AnimContainer;

    override public function init() {
        var gap = () -> b.h(pfr, 0.1).v(sfr, 0.1).b();
        pnl = Builder.v();
        tree = animationTreeBuilder.build(
            {
                layout:ClickAndButt.OFFSET,
                children:[ ]
            }
        );
        animContainer = tree.entity.getComponent(AnimContainer);

        var content = new WonderQuad(Builder.widget().withLiquidTransform(stage.getAspectRatio()), 0x505050);

        ButtonPanel.make(pnl.widget());
        var wc = Builder.createContainer(w, horizontal).withChildren([
            gap(),
            pnl.widget(),
            gap(),
            content.widget()
        ]);

        addButton("Carrot");
        addButton("Zucchini");
        addButton("Potato");
        addButton("Broccoli");
        addAnim(content.setTime);
        animContainer.refresh();
    }

    function addButton(text) {
        var b1 = new WonderButton(b.h(pfr, 1).v(sfr, 0.3).b().withLiquidTransform(stage.getAspectRatio()), () -> screens.switchTo(Screens.TWO), text, textStyleContext);
        Builder.addWidget(pnl, b1.widget());
        Builder.addWidget(pnl, b.h(pfr, 0.1).v(sfr, 0.1).b());
        addAnim(b1.setTime);
    }

    function addAnim(h) {
        var anim = animationTreeBuilder.animationWidget(new Entity(), {});
        animationTreeBuilder.addChild(animContainer, anim);
        anim.animations.channels.push(h);
    }

}

class ScreenTwo extends Screen {

    @:once var stage:Stage;
    @:once var b:PlaceholderBuilderGl;
    @:once var screens:Screens;
    @:once var animationTreeBuilder:AnimationTreeBuilder;
    @:once var textStyleContext:TextStyleContext;
    var pnl:Widget2DContainer;
    var animContainer:AnimContainer;

    override public function init() {
        var gap = () -> b.h(pfr, 0.1).v(sfr, 0.1).b();
        pnl = Builder.v();

        tree = animationTreeBuilder.build(
            {
                layout:ClickAndButt.OFFSET,
                children:[ ]
            }
        );
        animContainer = tree.entity.getComponent(AnimContainer);

        ButtonPanel.make(pnl.widget());

        var wc = Builder.createContainer(w, horizontal).withChildren([
            gap(),
            pnl.widget(),
            gap(),
        ]);

        addButton("Pork");
        addButton("Fish");
        animContainer.refresh();
    }

    function addButton(text) {
        var b1 = new WonderButton(b.h(pfr, 1).v(sfr, 0.5).b().withLiquidTransform(stage.getAspectRatio()), () -> screens.switchTo(Screens.ONE), text, textStyleContext);
        Builder.addWidget(pnl, b1.widget());
        Builder.addWidget(pnl, b.h(pfr, 0.1).v(sfr, 0.1).b());
        addAnim(b1.setTime);
    }

    function addAnim(h) {
        var anim = animationTreeBuilder.animationWidget(new Entity(), {});
        animationTreeBuilder.addChild(animContainer, anim);
        anim.animations.channels.push(h);
    }


//    @:once var b:Builder;
//    @:once var screens:Screens;
//
//    override public function init() {
//        trace("INIT");
//        var gap = b.widget.bind(portion, 0.1, fixed, 0.1);
//        var pnl:Widget2D = b.widget();
//        var b1 = new WonderButton(b.widget(portion, 1, fixed, 0.5), () -> screens.switchTo(Screens.ONE));
//        var b2 = new WonderButton(b.widget(portion, 1, fixed, 0.5), () -> screens.switchTo(Screens.ONE));
//        b.align(vertical).makeContainer(pnl, [
//            gap(),
//            b1.widget(),
//            gap(),
//            b2.widget(),
////            new WonderButton(b.widget(portion, 1, fixed, 0.5), ()->screens.switchTo(Screens.ONE)).widget(),
//        ]);
//        ButtonPanel.make(pnl);
//        var wc = b.makeContainer(w, [
//            gap(),
//            pnl,
//            gap()
//        ]);
//
//
//        tree = new AnimationTreeBuilder().build(
//            {
//                layout:"portion",
//                children:[
//                    {size:{value:1. }},
//                    {size:{value:1. }},
//                ]
//            }
//        );
//
//        function bindAnimation(id, handler:Float -> Void) {
//            tree.entity.getChildren()[id].getComponent(AnimWidget).animations.channels.push(handler);
//        }
//        bindAnimation(0, b1.setTime);
//        bindAnimation(1, b2.setTime);
//    }
}

//class Panel extends Widgetable {
//    public function new (w:Widget2D) {
//        super (w);
//    }
//}
//
//
//
//class ScrollbarView {
//
//    static var bgColor = new RGB(200,200,200);
//    static var hndColor = new RGB(250,250,250);
//    static var colors = new ColorArrayProvider([for (i in 0...8) if (i < 4) bgColor else hndColor]);
//
//    public function new(w:Widget2D, ar) {
//        var hndlSlot = new BarAxisSlot ({start:0., end:0.5}, null);
//        var elements = [
//            new BarContainer(FixedThikness(new BarAxisSlot ({pos:1., thikness:1.}, null)), Portion(new BarAxisSlot ({start:0., end:1.}, null))),
//            new BarContainer(FixedThikness(new BarAxisSlot ({pos:1., thikness:1.}, null)), Portion(hndlSlot)),
//        ];
//        var bars = new BarsItem(w, elements, ar, colors.getValue);
//    }
//}


//class WheelGlOffset {
//    public var target:Float -> Void;
//
//    public function new(t) {
//        this.target = t;
//        openfl.Lib.current.stage.addEventListener(MouseEvent.MOUSE_WHEEL, onWheel);
//    }
//
//    function onWheel(e:MouseEvent) {
//        target(e.delta);
//    }
//}


//class BoundsRO {
//    public var size(default, null):ReadOnlyArray<Float>;
//    public var pos(default, null):ReadOnlyArray<Float>;
//
//    function new(x, y, w, h) {
//        pos = [x, y];
//        size = [w, h];
//    }
//
//    public static var CENTER = new BoundsRO(-0.5, -0.5, 1, 1);
//    public static var TOP_LEFT = new BoundsRO(0, 0, 1, 1);
//}

