package ;
import widgets.Button;
import al.al2d.Axis2D;
import al.al2d.Widget2DContainer;
import al.Builder;
import al.layouts.data.LayoutData.Size;
import al.layouts.data.LayoutData.SizeType;
import al.openfl.StageAspectResizer;
import ec.Entity;
import FuiBuilder;
import input.al.ButtonPanel;
import openfl.display.Sprite;
import scroll.ScrollableContent.W2CScrollableContent;
import scroll.ScrollboxItem;
import text.Align;
import transform.AspectRatioProvider;
import utils.DummyEditorField;
import widgets.Label;
using transform.LiquidTransformer;

class FancyPg extends FuiAppBase {
    public function new() {
        super();
        var sampleText = "FoEo Bar AbAb Aboo Distance Field texture Ad Ae Af Bd Be Bf Bb Ab Dd De Df Cd Ce Cf";
        var b = new Builder();
        var root:Entity = new Entity();
        var ar = fuiBuilder.ar;
//        fuiBuilder.addBmFont("", "Assets/heaps-fonts/monts.fnt"); // todo
        fuiBuilder.addBmFont("", "Assets/heaps-fonts/robo.fnt"); // todo
        root.addComponentByName(Entity.getComponentId(AspectRatioProvider), fuiBuilder.ar);
        root.addComponentByType(Size2D, fuiBuilder.ar);
        fuiBuilder.configureInput(root);

        var dl =
        '<container>
        <drawcall type="color"/>
        <drawcall type="text" font=""/>
        </container>';
        fuiBuilder.createContainer(root, Xml.parse(dl).firstElement());
        var container:Sprite = root.getComponent(Sprite);
        for (i in 0...container.numChildren) {
            trace(container.getChildAt(i));
        }
        addChild(container);
        var pxStyle = fuiBuilder.textStyles.newStyle("px")
        .withSizeInPixels(64)
        .build();

        var pcStyle = fuiBuilder.textStyles.newStyle("pc")
//        .withAlign(vertical, Center)
        .withPercentFontScale(.1)
        .withPadding(horizontal, 0.3)
        .build();

        var pcStyleR = fuiBuilder.textStyles.newStyle("pc")
        .withAlign(horizontal, Backward)
        .build();

        var pcStyleC = fuiBuilder.textStyles.newStyle("pc")
        .withAlign(horizontal, Center)
        .build();

        var fitStyle = fuiBuilder.textStyles.newStyle("fit")
        .withFitFontScale(.75)
        .withAlign(horizontal, Center)
        .withAlign(vertical, Center)
        .build();

        var pxW = b.widget();
        @:privateAccess pxW.axisStates[vertical].size = new PixelSize(vertical, ar);
        @:privateAccess pxW.axisStates[vertical].size.setFixed(600);


        var quads = [] ;//[for (i in 0...1)new ColorBars(b.widget().withLiquidTransform(ar.getFactorsRef()), Std.int(0xffffff * Math.random())).widget()];
//        quads.push(new Label(b.widget(), pcStyle).withText(sampleText).widget());
//        quads.push(new Label(b.widget(), pcStyleC).withText(sampleText).widget());
//        quads.push(new Label(b.widget(), pcStyleR).withText(sampleText).widget());
        quads.push(new Button(b.widget(fixed, 1, SizeType.fixed, 0.5).withLiquidTransform(ar.getFactorsRef()), null, "Button caption", fitStyle).widget());
        quads.push(new Button(b.widget(fixed, 1, SizeType.fixed, 0.5).withLiquidTransform(ar.getFactorsRef()), null, "Button caption", fitStyle).widget());
//        quads.push(new Button(b.widget(fixed, 1).withLiquidTransform(ar.getFactorsRef()), null, "Button caption", fitStyle).widget());
        quads.push(new Button(pxW.withLiquidTransform(ar.getFactorsRef()), null, "Button caption", fitStyle).widget());
//        quads.push(new ColouredQuad(b.widget().withLiquidTransform(ar.getFactorsRef()), 0x303090).widget());


        var container1 = b.align(vertical).container(quads);
        ButtonPanel.make(container1);
        container1.entity.name = "c1";
        var placeholder = b.widget(portion, 1, portion, 1);
        var scroll = new W2CScrollableContent(
        container1.entity.getComponent(Widget2DContainer),
        placeholder
        );

        placeholder.entity.name = "placeholder";
        var scroller = new ScrollboxItem(placeholder, scroll, ar.getFactorsRef());
        fuiBuilder.addScissors(scroller.widget());
        fuiBuilder.createContainer(scroller.widget().entity, Xml.parse(dl).firstElement());

        var spr:Sprite = scroller.widget().entity.getComponent(Sprite);
        addChild(spr);
        var rw = b.align(horizontal).container([ scroller.widget(), new Label(b.widget(), pcStyleR).withText(sampleText).widget()]);
        root.addChild(rw.entity);
        new StageAspectResizer(rw, 2);
        new DummyEditorField();
    }

    function getSampleText() {
        return lime.utils.Assets.getText("Assets/heaps-fonts/Rich-text-sample.xml");
    }


}

class PixelSize extends Size {
    var screen:StageAspectKeeper;
    var a:Axis2D;

    public function new(a, s) {
        super();
        this.a = a;
        this.screen = s;
    }

    override public function setWeight(w:Float) {
        throw "wrong";
    }

    override public function setFixed(w:Float) {
        super.setFixed(w);
    }

    override public function getPortion() {
        return 0;
    }

    override public function getFixed() {
        return 2 * screen.getFactor(a) * value / screen.getValue(a);
    }


}