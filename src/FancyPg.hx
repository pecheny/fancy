package;

import data.aliases.AttribAliases;
import gl.sets.TexSet;
import graphics.shapes.QuadGraphicElement;
import widgets.ShapeWidget;
import a2d.AspectRatioProvider;
import a2d.Stage;
import a2d.WindowSizeProvider;
import al.al2d.Placeholder2D;
import al.al2d.Widget2DContainer;
import al.Builder;
import al.openfl.StageAspectResizer;
import algl.Builder.PlaceholderBuilderGl;
import algl.PixelSize;
import algl.ScreenMeasureUnit;
import algl.TransformatorAxisApplier;
import Axis2D;
import ec.Entity;
import gl.sets.ColorSet;
import graphics.shapes.Bar;
import graphics.ShapesColorAssigner;
import htext.Align;
import openfl.display.Sprite;
import scroll.ScrollableContent.W2CScrollableContent;
import scroll.ScrollboxItem;
import utils.DummyEditorField;
import widgets.BarWidget;
import widgets.Button;
import widgets.Label;

using transform.LiquidTransformer;
using widgets.utils.Utils;
using al.Builder;

class FancyPg extends Sprite {
    var fuiBuilder = new FuiBuilder();

    function createTextStyles() {
        fuiBuilder.addBmFont("", "Assets/heaps-fonts/robo.fnt"); // todo
        var pxStyle = fuiBuilder.textStyles.newStyle("px").withSize(px, 64).build();

        var pcStyle = fuiBuilder.textStyles.newStyle("pcl") //        .withAlign(vertical, Center)
            .withSize(sfr, .1)
            .withPadding(horizontal, sfr, 0.3)
            .build();

        var pcStyleR = fuiBuilder.textStyles.newStyle("pcr").withAlign(horizontal, Backward).build();

        var pcStyleC = fuiBuilder.textStyles.newStyle("pcc").withAlign(horizontal, Center).build();

        //        var fitStyle = fuiBuilder.textStyles.newStyle("fit")
        //        .withSize(pfr, .75)
        //        .withAlign(horizontal, Center)
        //        .withAlign(vertical, Center)
        //        .build();

        var fitStyle = fuiBuilder.textStyles.newStyle("fit")
            .withSize(pfr, .5)
            .withAlign(horizontal, Forward)
            .withAlign(vertical, Backward)
            .withPadding(horizontal, pfr, 0.33)
            .withPadding(vertical, pfr, 0.33)
            .build();
    }

    function sty(name) {
        // fuiBuilder.textStyles.
        return fuiBuilder.textStyles.getStyle(name);
    }

    public function new() {
        super();
        var sampleText = "FoEo Bar AbAb Aboo Distance Field texture Ad Ae Af Bd Be Bf Bb Ab Dd De Df Cd Ce Cf";
        var root:Entity = new Entity();
        fuiBuilder.regDefaultDrawcalls();
        var ar = fuiBuilder.ar;
        var b = new PlaceholderBuilderGl(ar);
        //        fuiBuilder.addBmFont("", "Assets/heaps-fonts/monts.fnt"); // todo
        createTextStyles();
        root.addComponentByType(AspectRatioProvider, fuiBuilder.ar);
        root.addComponentByType(WindowSizeProvider, fuiBuilder.ar);
        root.addComponentByType(Stage, fuiBuilder.ar);
        fuiBuilder.configureInput(root);

        var dl = '<container>
        <drawcall type="color"/>
        <drawcall type="text" font=""/>
        </container>';
        fuiBuilder.createContainer(root, Xml.parse(dl).firstElement());

        var container:Sprite = root.getComponent(Sprite);
        addChild(container);

        function cqFac() {
            var elements = () -> [
                new BarContainer(FixedThikness(new BarAxisSlot({pos: .5, thikness: 1.}, null)), Portion(new BarAxisSlot({start: 0., end: 1.}, null))),
                new BarContainer(FixedThikness(new BarAxisSlot({pos: 0., thikness: 1.}, null)), Portion(new BarAxisSlot({start: 0., end: 1.}, null))),
            ];

            var attrs = ColorSet.instance;
            var cq = new BarWidget(attrs, b.h(sfr, 1).v(sfr, 0.5).b("bars").withLiquidTransform(ar.getAspectRatio()), elements());
            var colors = new ShapesColorAssigner(attrs, 0, cq.getBuffer());
            return cq;
        }

        var pxW = b.b();
        @:privateAccess pxW.axisStates[vertical].size = new PixelSize(vertical, ar, 60);
        function createContent(fuiBuilder) {
            return [
                cqFac().widget(),
                // new Label(b.b(), sty("pcc")).withText(sampleText).widget(),
                // new Label(b.b(), sty("pcr")).withText(sampleText).widget(),
                // new Button(b.h(sfr, 1).v(sfr, 0.5).b().withLiquidTransform(ar.getAspectRatio()), null, "<font lineHeight=\"0.1\">Button </font>",
                //     sty("fit")).widget(),
                texturedQuad(fuiBuilder, b.h(sfr, 1).v(sfr, 0.5).b().withLiquidTransform(ar.getAspectRatio()), "bunie.png").widget(),
                new Button(pxW.withLiquidTransform(ar.getAspectRatio()), null, "Button caption", sty("fit")).widget(),
                new Label(b.b(), sty("pcl")).withText(sampleText).widget(),
                new Button(b.h(sfr, 1).v(sfr, 0.5).b().withLiquidTransform(ar.getAspectRatio()), null, "Button", sty("fit")).widget(),
                new Button(b.h(sfr, 1).v(sfr, 0.5).b().withLiquidTransform(ar.getAspectRatio()), null, "Button", sty("fit")).widget(),
                new Button(b.h(sfr, 1).v(sfr, 0.5).b().withLiquidTransform(ar.getAspectRatio()), null, "Button", sty("fit")).widget(),
            ];
        }
        //        quads.push(new ColouredQuad(b.b().withLiquidTransform(ar.getAspectRatio()), 0x303090).widget());

        var container1 = Builder.v().widget();
        fuiBuilder.makeClickInput(container1);
        container1.entity.name = "c1";
        var placeholder = b.b();
        createScrollbox(fuiBuilder, container1, placeholder, ar, dl, createContent);

        var cright = Builder.v().withChildren([
            new Label(b.b(), sty("pcr")).withText(sampleText).widget(),
            new widgets.Slider(b.v(sfr, 0.1).b("slider r").withLiquidTransform(ar.getAspectRatio()), horizontal,
                f -> trace("" + f)).withProgress(0.5).widget(),
            texturedQuad(fuiBuilder, b.h(pfr, 1).v(sfr, 0.5).b().withLiquidTransform(ar.getAspectRatio()), "bunie.png").widget(),
        ]);
        var rw = Builder.h().withChildren([placeholder, cright]);
        root.addChild(rw.entity);
        new StageAspectResizer(rw, 2);
        new DummyEditorField();
    }

    function createScrollbox(fuiBuilder:FuiBuilder, container1:Placeholder2D, placeholder:Placeholder2D, ar, dl,
            childrenFactory:FuiBuilder->Array<Placeholder2D>) {
        var cont = container1.entity.getComponent(Widget2DContainer);
        var scroll = new W2CScrollableContent(cont, placeholder);

        placeholder.entity.name = "placeholder";
        var scroller = new ScrollboxItem(placeholder, scroll, ar.getAspectRatio());
        fuiBuilder.addScissors(scroller.widget());
        fuiBuilder.createContainer(scroller.widget().entity, Xml.parse(dl).firstElement());
        for (ch in childrenFactory(fuiBuilder))
            cont.addWidget(ch);
        var spr:Sprite = scroller.widget().entity.getComponent(Sprite);
        addChild(spr);
        fuiBuilder.setAspects([]);
    }

    public function texturedQuad(fuiBuilder:FuiBuilder, w:Placeholder2D, filename, createGldo = true):ShapeWidget<TexSet> {
        var attrs = TexSet.instance;
        var shw = new ShapeWidget(attrs, w);
        shw.addChild(new QuadGraphicElement(attrs));
        var uvs = new graphics.DynamicAttributeAssigner(attrs, shw.getBuffer());
        uvs.fillBuffer = (attrs:TexSet, buffer) -> {
            var writer = attrs.getWriter(AttribAliases.NAME_UV_0);
            QuadGraphicElement.writeQuadPostions(buffer.getBuffer(), writer, 0, (a, wg) -> wg);
        };
        if (createGldo) {
            fuiBuilder.createContainer(w.entity, Xml.parse('<container><drawcall type="image" path="Assets/$filename" /></container>').firstElement());
            var spr:Sprite = w.entity.getComponent(Sprite);
            addChild(spr);
        }
        return shw;
    }

    function getSampleText() {
        return lime.utils.Assets.getText("Assets/heaps-fonts/Rich-text-sample.xml");
    }
}
