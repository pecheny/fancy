package;

import ec.macros.InitMacro;
import dkit.Dkit;
import FuiBuilder;
import a2d.ContainerFactory;
import a2d.Placeholder2D;
import a2d.PlaceholderBuilder2D;
import a2d.Stage;
import a2d.Widget2DContainer;
import a2d.Widget;
import al.animation.AnimatedSwitcher;
import al.animation.AnimationTree;
import al.layouts.PortionLayout;
import al.layouts.WholefillLayout;
import al.layouts.data.LayoutData.FixedSize;
import al.layouts.data.LayoutData.FractionSize;
import ec.Entity;
import fu.PropStorage;
import fu.Signal;
import htext.style.TextStyleContext;
import openfl.display.Sprite;
import widgets.WonderButton;
import widgets.WonderQuad;
import utils.MacroGenericAliasConverter as MGA;

using a2d.transform.LiquidTransformer;
using al.Builder;

class ClickAndButt extends Sprite {
    var s1:Placeholder2D;
    var s2:Placeholder2D;

    public function new() {
        super();
        var fuiBuilder = new FuiBuilder();
        BaseDkit.inject(fuiBuilder);
        var root:Entity = fuiBuilder.createDefaultRoot();
        root.addComponent(new al.openfl.display.FlashDisplayRoot(this));

        var uikit = new FlatUikitExtended(fuiBuilder);

        uikit.configure(root);
        uikit.createContainer(root);

        WonderKit.configure(root);
        ClickAndButtPreset.configure(root);

        var conts = new ContainerFactory();
        conts.regStyle("v", new WholefillLayout(new FractionSize(.2)), new PortionLayout(Forward, new FixedSize(0.1)));
        conts.regStyle("h", new PortionLayout(Forward, new FixedSize(0.)), new WholefillLayout(new FractionSize(0.)));
        root.addComponent(conts);

        var buts = new ButtonFactory(fuiBuilder.placeholderBuilder, fuiBuilder.ar, fuiBuilder.s("fit"));
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

class ClickAndButtPreset {
    public static function configure(e:Entity) {
        var props = e.getComponentByNameUpward(MGA.toAlias(PropStorage, AnimationPreset));
        var preset = new AnimationPreset({
            layout: "portion",
            name: "screen-one",
            children: [
                {
                    size: {value: 1.5},
                    name: "buttons",
                    layout: "offset",
                    children: []
                },
                {size: {value: 1.5}, name: "content"},
            ]
        });

        // {size: {value: .1}, name: "flick"},
        preset.addChildBinder(WonderButton, "", AnimationSlotSelectors.nameSelector.bind("buttons"));
        preset.addChildBinder(WonderQuad, "", AnimationSlotSelectors.nameSelector.bind("content"));
        props.set(AnimationPreset.getId(ScreenOne), preset);
        
        var preset = new AnimationPreset({
            layout: "portion",
            name: "screen-two",
            children: [
                {
                    size: {value: 1.5},
                    name: "buttons",
                    layout: "offset",
                    children: []
                },
                {size: {value: 1.5}, name: "content"},
            ]
        });
        preset.addChildBinder(WonderButton, "", AnimationSlotSelectors.nameSelector.bind("buttons"));
        props.set(AnimationPreset.getId(ScreenTwo), preset);
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
        addButton("Broccoli");

        var content = new WonderQuad(Builder.widget().withLiquidTransform(stage.getAspectRatio()), 0x505050);
        binder.addChild(content);

        containerFactory.create(ph, "h").withChildren([pnl.ph, content.ph]);
    }

    function addButton(text) {
        var b1 = buttonFactory.button(text, () -> onClick.dispatch());
        Builder.addWidget(pnl, b1.ph);
        binder.addChild(b1);
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
        binder.addChild(b1);
    }
}

class Screen extends Widget implements Channels {
    var b:PlaceholderBuilder2D;
    var stage:Stage;

    public var tree(default, null):AnimationTreeProp;
    public var channels(default, null):Array<Float->Void> = [];

    var binder:TreeBinderComponent;

    @:once var fuiBuilder:FuiBuilder;

    public var onClick = new Signal<Void->Void>();

    public function new(ph) {
        super(ph);
        this.tree = AnimationTreeProp.getOrCreate(ph.entity);
    }

    override function init() {
        binder = new TreeBinderComponent(entity, this);
        new TreeBuilderComponent(entity, this);
        this.b = fuiBuilder.placeholderBuilder;
        this.stage = fuiBuilder.ar;
    }
}
