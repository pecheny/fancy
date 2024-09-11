package;

import fu.GuiDrawcalls;
import a2d.PlaceholderBuilder2D;
import FuiBuilder;
import a2d.Stage;
import a2d.ContainerFactory;
import a2d.Widget2DContainer;
import al.animation.Animation.AnimContainer;
import al.ec.WidgetSwitcher;
import al.layouts.PortionLayout;
import al.layouts.WholefillLayout;
import al.layouts.data.LayoutData.FixedSize;
import al.layouts.data.LayoutData.FractionSize;
import ec.Entity;
import htext.style.TextStyleContext;
import openfl.display.Sprite;
import ui.Screens;
import widgets.WonderButton;
import widgets.WonderQuad;

using al.Builder;
using a2d.transform.LiquidTransformer;
using a2d.transform.LiquidTransformer;

class ScreenNames {
    public inline static var ONE:String = "one";
    public inline static var TWO:String = "TWO";
}

class ClickAndButt extends Sprite {
    public function new() {
        super();
        var fuiBuilder = new FuiBuilder();
        var root:Entity = fuiBuilder.createDefaultRoot(Xml.parse(GuiDrawcalls.DRAWCALLS_LAYOUT).firstChild());

        // var container:Sprite = root.getComponent(Sprite);
        // addChild(container);

        var conts = new ContainerFactory();
        conts.regStyle("v", new WholefillLayout(new FractionSize(.2)), new PortionLayout(Forward, new FixedSize(0.1)));
        conts.regStyle("h", new PortionLayout(Forward, new FixedSize(0.)), new WholefillLayout(new FractionSize(0.)));
        root.addComponent(conts);

        var buts = new ButtonFactory(fuiBuilder.placeholderBuilder, fuiBuilder.ar, root.getComponent(TextStyleContext));
        root.addComponent(buts);

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

class ButtonFactory {
    var b:PlaceholderBuilder2D;
    var stage:Stage;
    var textStyleContext:TextStyleContext;

    public function new(b, s, t) {
        this.b = b;
        this.stage = s;
        this.textStyleContext = t;
    }

    public function button(text, cb, w = null) {
        var b1 = new WonderButton(b.h(pfr, 1).v(sfr, 0.15).b().withLiquidTransform(stage.getAspectRatio()), cb, text, textStyleContext);
        return b1;
    }
}

class ScreenOne extends Screen {
    @:once var screens:Screens;
    @:once var containerFactory:ContainerFactory;
    @:once var buttonFactory:ButtonFactory;

    var pnl:Widget2DContainer;

    override public function init() {
        super.init();
        pnl = containerFactory.create(Builder.widget(), "v");
        fuiBuilder.makeClickInput(pnl.ph);

        addButton("Carrot");
        addButton("Zucchini");
        addButton("Potato");
        addButton("Broccoli");

        var content = new WonderQuad(Builder.widget().withLiquidTransform(stage.getAspectRatio()), 0x505050);
        addAnim(content.setTime);

        containerFactory.create(ph, "h").withChildren([pnl.ph, content.ph]);
    }

    function addButton(text) {
        var b1 = buttonFactory.button(text, () -> screens.switchTo(ScreenNames.TWO));
        Builder.addWidget(pnl, b1.ph);
        addAnim(b1.setTime);
    }
}

class ScreenTwo extends Screen {
    @:once var screens:Screens;
    @:once var containerFactory:ContainerFactory;
    @:once var buttonFactory:ButtonFactory;
    var pnl:Widget2DContainer;

    override public function init() {
        super.init();
        pnl = containerFactory.create(ph, "v");
        fuiBuilder.makeClickInput(pnl.ph);

        addButton("Pork");
        addButton("Fish");
    }

    function addButton(text) {
        var b1 = buttonFactory.button(text, () -> screens.switchTo(ScreenNames.ONE));
        Builder.addWidget(pnl, b1.ph);
        addAnim(b1.setTime);
    }
}
