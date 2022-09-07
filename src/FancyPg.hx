package ;
import Axis.ROAxisCollection2D;
import al.layouts.data.LayoutData.FixedSize;
import algl.Builder.PlaceholderBuilderGl;
import algl.PixelSize;
import al.al2d.Axis2D;
import al.al2d.Widget2DContainer;
import al.Builder;
import al.openfl.StageAspectResizer;
import ec.Entity;
import FuiBuilder;
import input.al.ButtonPanel;
import openfl.display.Sprite;
import scroll.ScrollableContent.W2CScrollableContent;
import scroll.ScrollboxItem;
import htext.Align;
import transform.AspectRatioProvider;
import utils.DummyEditorField;
import widgets.Button;
import widgets.Label;
import algl.WidgetSizeTypeGl;
using transform.LiquidTransformer;
using al.Builder;

class FancyPg extends FuiAppBase {
    public function new() {
        super();
        var sampleText = "FoEo Bar AbAb Aboo Distance Field texture Ad Ae Af Bd Be Bf Bb Ab Dd De Df Cd Ce Cf";
        var root:Entity = new Entity();
        var ar = fuiBuilder.ar;
        var b = new PlaceholderBuilderGl(ar);
//        fuiBuilder.addBmFont("", "Assets/heaps-fonts/monts.fnt"); // todo
        fuiBuilder.addBmFont("", "Assets/heaps-fonts/robo.fnt"); // todo
        root.addComponentByName(Entity.getComponentId(AspectRatioProvider), fuiBuilder.ar);
        root.addComponentByName("ROAxisCollection2D_windowSize", fuiBuilder.ar.getWindowSize());
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

        var pxW = b.b();
        @:privateAccess pxW.axisStates[vertical].size = new PixelSize(vertical, ar, 600);


        var quads = [] ;//[for (i in 0...1)new ColorBars(b.widget().withLiquidTransform(ar.getFactorsRef()), Std.int(0xffffff * Math.random())).widget()];
//        quads.push(new Label(b.b(), pcStyle).withText(sampleText).widget());
//        quads.push(new Label(b.b(), pcStyleC).withText(sampleText).widget());
//        quads.push(new Label(b.b(), pcStyleR).withText(sampleText).widget());
        quads.push(new Button(b.h(sfr, 1).v(sfr, 0.5).b().withLiquidTransform(ar.getFactorsRef()), null, "Button caption", fitStyle).widget());
        quads.push(new Button(b.h(sfr, 1).v(sfr, 0.5).b().withLiquidTransform(ar.getFactorsRef()), null, "Button caption", fitStyle).widget());
        quads.push(new Button(pxW.withLiquidTransform(ar.getFactorsRef()), null, "Button caption", fitStyle).widget());


//        quads.push(new ColouredQuad(b.b().withLiquidTransform(ar.getFactorsRef()), 0x303090).widget());


        var container1 = Builder.v().withChildren(quads);
        ButtonPanel.make(container1);
        container1.entity.name = "c1";
        var placeholder = b.b();
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
        var rw = Builder.h().withChildren([ scroller.widget(), new Label(b.b(), pcStyleR).withText(sampleText).widget()]);
        root.addChild(rw.entity);
        new StageAspectResizer(rw, 2);
        new DummyEditorField();
    }

    function getSampleText() {
        return lime.utils.Assets.getText("Assets/heaps-fonts/Rich-text-sample.xml");
    }
}

