package ;
import a2d.Stage;
import al.al2d.Widget2DContainer;
import al.animation.Animation.AnimContainer;
import al.animation.AnimationTreeBuilder;
import al.Builder;
import al.ec.WidgetSwitcher;
import al.openfl.StageAspectResizer;
import algl.Builder.PlaceholderBuilderGl;
import algl.ScreenMeasureUnit;
import Axis2D;
import ec.Entity;
import FuiBuilder;
import htext.style.TextStyleContext;
import openfl.display.Sprite;
import ui.Screens;
import widgets.WonderButton;
import widgets.WonderQuad;

using FancyPg.Utils;
using transform.LiquidTransformer;
using al.Builder;
class ClickAndButt extends FuiAppBase {
    public inline static var OFFSET:String = "offset";

    public function new() {
        super();
        var sampleText = "FoEo Bar AbAb Aboo Distance Field texture Ad Ae Af Bd Be Bf Bb Ab Dd De Df Cd Ce Cf";
        var root:Entity = new Entity();
        var ar = fuiBuilder.ar;
//        fuiBuilder.addBmFont("", "Assets/heaps-fonts/monts.fnt"); // todo
        fuiBuilder.addBmFont("", "Assets/heaps-fonts/robo.fnt"); // todo
        fuiBuilder.configureInput(root);
        fuiBuilder.configureScreen(root);
        fuiBuilder.configureAnimation(root);
        root.addComponent(fuiBuilder);

        var dl =
        '<container>
        <drawcall type="color"/>
        <drawcall type="text" font=""/>
        </container>';
        fuiBuilder.createContainer(root, Xml.parse(dl).firstElement());
        var container:Sprite = root.getComponent(Sprite);
        addChild(container);

        var fitStyle = fuiBuilder.textStyles.newStyle("fit")
        .withSize(pfr, .5)
        .withAlign(horizontal, Forward)
        .withAlign(vertical, Backward)
        .withPadding(horizontal, pfr, 0.33)
        .withPadding(vertical, pfr, 0.33)
        .build();
        root.addComponent(fitStyle);

        var rw = Builder.widget();
        root.addChild(rw.entity);

        var screens = new Screens(new WidgetSwitcher(rw));
        fuiBuilder.updater.addUpdatable(screens);
        root.addComponent(screens);

        var s1 = new ScreenOne(Builder.widget());
        var s2 = new ScreenTwo(Builder.widget());
        screens.add(Screens.ONE, s1);
        screens.add(Screens.TWO, s2);
        screens.switchTo(Screens.ONE);

        var v = new StageAspectResizer(rw, 2);
    }
}


class ScreenOne extends Screen {

    @:once var b:PlaceholderBuilderGl;
    @:once var screens:Screens;
    @:once var animationTreeBuilder:AnimationTreeBuilder;
    @:once var textStyleContext:TextStyleContext;
    @:once var stage:Stage;
    @:once var fuiBuilder:FuiBuilder;

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

        fuiBuilder.makeClickInput(pnl.widget());
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
    @:once var fuiBuilder:FuiBuilder;
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

        fuiBuilder.makeClickInput(pnl.widget());

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
}
