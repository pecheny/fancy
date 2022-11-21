package ;

import gl.sets.ColorSet;
import graphics.shapes.Bar;
import a2d.Stage;
import a2d.WindowSizeProvider;
import al.al2d.Widget2DContainer;
import al.al2d.Widget2D;
import algl.TransformatorAxisApplier;
import al.Builder;
import al.openfl.StageAspectResizer;
import algl.Builder.PlaceholderBuilderGl;
import algl.PixelSize;
import algl.WidgetSizeTypeGl;
import Axis2D;
import ec.Entity;
import FuiBuilder;
import htext.Align;
import input.al.ButtonPanel;
import openfl.display.Sprite;
import scroll.ScrollableContent.W2CScrollableContent;
import scroll.ScrollboxItem;
import a2d.AspectRatioProvider;
import utils.DummyEditorField;
import widgets.Button;
import widgets.ColorBars;
import widgets.Label;
using transform.LiquidTransformer;
using FancyPg.Utils;
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
        root.addComponentByType(AspectRatioProvider, fuiBuilder.ar);
        root.addComponentByType(WindowSizeProvider, fuiBuilder.ar);
        root.addComponentByType(Stage, fuiBuilder.ar);
//        root.addComponentByName("ROAxisCollection2D_windowSize", fuiBuilder.ar.getWindowSize());
        fuiBuilder.configureInput(root);

        var dl =
        '<container>
        <drawcall type="color"/>
        <drawcall type="text" font=""/>
        </container>';
        fuiBuilder.createContainer(root, Xml.parse(dl).firstElement());

        var container:Sprite = root.getComponent(Sprite);
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

        var elements = () -> [
            new BarContainer(FixedThikness(new BarAxisSlot ({pos:.5, thikness:1.}, null)), Portion(new BarAxisSlot ({start:0., end:1.}, null))),
            new BarContainer(FixedThikness(new BarAxisSlot ({pos:0., thikness:1.}, null)), Portion(new BarAxisSlot ({start:0., end:1.}, null)) ),
        ];

        function cqFac() {
            var cq = new ColorBars(b.h(sfr, 1).v(sfr, 0.5).b().withLiquidTransform(ar.getFactorsRef()), Std.int(0xffffff * Math.random()), elements());
            var colors = new ShapesColorAssigner(ColorSet.instance, 0, cq.getBuffer());
            return cq;
        }
        var quads = [for (i in 0...1)cqFac().widget()];
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

class Utils {
    public static function withLiquidTransform(w:Widget2D, aspectRatio) {
        var transformer = new LiquidTransformer(aspectRatio);
        for (a in Axis2D) {
            var applier2 = new TransformatorAxisApplier(transformer, a);
            w.axisStates[a].addSibling(applier2);
        }
        w.entity.addComponent(transformer);
        return w;
    }
}

