package ;
import widgets.Button;
import al.al2d.Axis2D;
import al.Builder;
import al.openfl.StageAspectResizer;
import ec.Entity;
import FuiBuilder;
import input.al.ButtonPanel;
import openfl.display.Sprite;
import text.Align;
import text.style.Pivot.ForwardPivot;
import text.style.Pivot;
import transform.AspectRatioProvider;
import utils.DummyEditorField;
import widgets.ColorBars;
import widgets.Label;
import widgets.SomeButton;
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


        var quads = [for (i in 0...1)new ColorBars(b.widget().withLiquidTransform(ar.getFactorsRef()), Std.int(0xffffff * Math.random())).widget()];
        quads.push(new Label(b.widget(), pcStyle).withText(sampleText).widget());
        quads.push(new Label(b.widget(), pcStyleC).withText(sampleText).widget());
        quads.push(new Label(b.widget(), pcStyleR).withText(sampleText).widget());
        quads.push(new Button(b.widget().withLiquidTransform(ar.getFactorsRef()), null, "Button caption", fitStyle).widget());
//        quads.push(new ColouredQuad(b.widget().withLiquidTransform(ar.getFactorsRef()), 0x303090).widget());
        var rw = b.align(vertical).container(quads);
        ButtonPanel.make(rw);
        root.addChild(rw.entity);
        new StageAspectResizer(rw, 2);
        new DummyEditorField();

    }

    function getSampleText() {
        return lime.utils.Assets.getText("Assets/heaps-fonts/Rich-text-sample.xml");
    }
}