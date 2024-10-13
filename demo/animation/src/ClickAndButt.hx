package;

import al.animation.Animator;
import a2d.Widget;
import fu.Signal;
import a2d.Placeholder2D;
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
import al.animation.AnimatedSwitcher;
import widgets.WonderButton;
import widgets.WonderQuad;

using al.Builder;
using a2d.transform.LiquidTransformer;
using a2d.transform.LiquidTransformer;

class ClickAndButt extends Sprite {
    var s1:Placeholder2D;
    var s2:Placeholder2D;

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

        var buts = new ButtonFactory(fuiBuilder.placeholderBuilder, fuiBuilder.ar, fuiBuilder.s());
        root.addComponent(buts);

        var screens = root.getComponent(AnimatedSwitcher);

        s1 = {
            var s = new ScreenOne(Builder.widget());
            s.onClick.listen(() -> screens.switchTo(s2));
            s.watch(root);
            s.ph;
        };
        s2 = {
            var s = new ScreenTwo(Builder.widget());
            s.onClick.listen(() -> screens.switchTo(s1));
            s.watch(root);
            s.ph;
        };

        screens.switchTo(s1);
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
    @:once var screens:AnimatedSwitcher;
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
        // addButton("Broccoli");

        // var b1 = new WonderButton(b.h(sfr, 0.6).v(sfr, 0.3).b().withLiquidTransform(stage.getAspectRatio()), () -> {}, "Boo-boom",
        //     ph.entity.getComponentUpward(TextStyleContext));
        // Builder.addWidget(pnl, b1.ph);
        // animator.addAnim(b1.setTime);

        var content = new WonderQuad(Builder.widget().withLiquidTransform(stage.getAspectRatio()), 0x505050);
        animator.addAnim(content.setTime);

        containerFactory.create(ph, "h").withChildren([pnl.ph, content.ph]);
    }

    function addButton(text) {
        var b1 = buttonFactory.button(text, () -> onClick.dispatch());
        // var b1 = buttonFactory.button(text, null);
        Builder.addWidget(pnl, b1.ph);
        animator.addAnim(b1.setTime);
    }
}

class ScreenTwo extends Screen {
    @:once var screens:AnimatedSwitcher;
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
        var b1 = buttonFactory.button(text, () -> onClick.dispatch());
        Builder.addWidget(pnl, b1.ph);
        animator.addAnim(b1.setTime);
    }
}

class Screen extends Widget {
    var b:PlaceholderBuilder2D;
    var stage:Stage;
    var animator:Animator;
    @:once var fuiBuilder:FuiBuilder;

    public var onClick = new Signal<Void->Void>();

    override function init() {
        animator = Animator.getOrCreate(entity, entity);
        this.b = fuiBuilder.placeholderBuilder;
        this.stage = fuiBuilder.ar;
    }
}
