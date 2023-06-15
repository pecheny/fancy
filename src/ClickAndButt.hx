package;

import FuiBuilder;
import al.al2d.Widget2DContainer;
import al.animation.Animation.AnimContainer;
import al.ec.WidgetSwitcher;
import ec.Entity;
import htext.style.TextStyleContext;
import openfl.display.Sprite;
import ui.Screens;
import widgets.WonderButton;
import widgets.WonderQuad;

using al.Builder;
using transform.LiquidTransformer;
using widgets.utils.Utils;

class ScreenNames {
    public inline static var ONE:String = "one";
    public inline static var TWO:String = "TWO";
}

class ClickAndButt extends Sprite {
    public function new() {
        super();
        var fuiBuilder = new FuiBuilder();
        var root:Entity = fuiBuilder.createDefaultRoot(XmlLayerLayouts.COLOR_AND_TEXT);

        var container:Sprite = root.getComponent(Sprite);
        addChild(container);

        var screens = new Screens(root.getComponent(WidgetSwitcher));
        fuiBuilder.updater.addUpdatable(screens);
        root.addComponent(screens);

        var s1 = new ScreenOne(Builder.widget());
        var s2 = new ScreenTwo(Builder.widget());
        screens.add(ScreenNames.ONE, s1);
        screens.add(ScreenNames.TWO, s2);
        screens.switchTo(ScreenNames.ONE);
    }
}

class ScreenOne extends Screen {
    @:once var screens:Screens;
    @:once var textStyleContext:TextStyleContext;
    var pnl:Widget2DContainer;
    var animContainer:AnimContainer;

    override public function init() {
        super.init();
        var gap = () -> b.h(pfr, 0.1).v(sfr, 0.1).b();
        pnl = Builder.v();

        animContainer = tree.entity.getComponent(AnimContainer);

        var content = new WonderQuad(Builder.widget().withLiquidTransform(stage.getAspectRatio()), 0x505050);

        fuiBuilder.makeClickInput(pnl.widget());
        var wc = Builder.createContainer(w, horizontal, Forward).withChildren([gap(), pnl.widget(), gap(), content.widget()]);

        addButton("Carrot");
        addButton("Zucchini");
        addButton("Potato");
        addButton("Broccoli");
        addAnim(content.setTime);
        animContainer.refresh();
    }

    function addButton(text) {
        var b1 = new WonderButton(b.h(pfr, 1).v(sfr, 0.15).b().withLiquidTransform(stage.getAspectRatio()), () -> screens.switchTo(ScreenNames.TWO), text,
            textStyleContext);
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
    @:once var screens:Screens;
    @:once var textStyleContext:TextStyleContext;
    var pnl:Widget2DContainer;
    var animContainer:AnimContainer;

    override public function init() {
        super.init();
        var gap = () -> b.h(pfr, 0.1).v(sfr, 0.1).b();
        pnl = Builder.v();

        animContainer = tree.entity.getComponent(AnimContainer);

        fuiBuilder.makeClickInput(pnl.widget());

        var wc = Builder.createContainer(w, horizontal, Forward).withChildren([gap(), pnl.widget(), gap(),]);

        addButton("Pork");
        addButton("Fish");
        animContainer.refresh();
    }

    function addButton(text) {
        var b1 = new WonderButton(b.h(pfr, 1).v(sfr, 0.25).b().withLiquidTransform(stage.getAspectRatio()), () -> screens.switchTo(ScreenNames.ONE), text,
            textStyleContext);
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
