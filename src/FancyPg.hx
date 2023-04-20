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
    var sampleText = "FoEo Bar AbAb Aboo Distance Field texture Ad Ae Af Bd Be Bf Bb Ab Dd De Df Cd Ce Cf";
    var b:PlaceholderBuilderGl;
    var ar:AspectRatioProvider;
    var dl = '<container>
        <drawcall type="color"/>
        <drawcall type="text" font=""/>
        </container>';

    public function new() {
        super();
        var rw = prepareRootContainer();

        var scrollPlaceholder = createScrollbox(fuiBuilder.makeClickInput(b.b("c1").createContainer(vertical, Forward).widget()), b.b(), ar, dl,
            createMixedContentArray);
        rw.addWidget(scrollPlaceholder);

        var cright = Builder.v().withChildren([
            new Label(b.b(), sty("pcr")).withText(sampleText).widget(),
            texturedQuad(fuiBuilder, b.h(pfr, 1).v(sfr, 0.5).b().withLiquidTransform(ar.getAspectRatio()), "bunie.png").widget(),
        ]);
        rw.addWidget(cright);
    }

    function prepareRootContainer() {
        var root:Entity = new Entity();
        fuiBuilder.regDefaultDrawcalls();
        ar = fuiBuilder.ar;
        b = new PlaceholderBuilderGl(fuiBuilder.ar);
        createTextStyles();

        root.addComponentByType(AspectRatioProvider, fuiBuilder.ar);
        root.addComponentByType(WindowSizeProvider, fuiBuilder.ar);
        root.addComponentByType(Stage, fuiBuilder.ar);
        fuiBuilder.configureInput(root);
        fuiBuilder.createContainer(root, Xml.parse(dl).firstElement());
        var container:Sprite = root.getComponent(Sprite);
        addChild(container);
        var rw = Builder.h();
        root.addChild(rw.entity);
        new StageAspectResizer(rw.widget(), 2);
        return rw;
    }

    function createScrollbox(container1:Placeholder2D, placeholder:Placeholder2D, ar, dl, childrenFactory:FuiBuilder->Array<Placeholder2D>) {
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
        return placeholder;
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

    function createBarWidget() {
        var elements = () -> [
            new BarContainer(FixedThikness(new BarAxisSlot({pos: .5, thikness: 1.}, null)), Portion(new BarAxisSlot({start: 0., end: 1.}, null))),
            new BarContainer(FixedThikness(new BarAxisSlot({pos: 0., thikness: 1.}, null)), Portion(new BarAxisSlot({start: 0., end: 1.}, null))),
        ];

        var attrs = ColorSet.instance;
        var cq = new BarWidget(attrs, b.h(sfr, 1).v(sfr, 0.5).b("bars").withLiquidTransform(ar.getAspectRatio()), elements());
        var colors = new ShapesColorAssigner(attrs, 0, cq.getBuffer());
        return cq;
    }

    function createMixedContentArray(fuiBuilder) {
        return [
            new Label(b.h(sfr, 1).v(sfr, 0.4).b(), sty("pcl")).withText(sampleText).widget(),
            new Label(b.h(sfr, 1).v(sfr, 0.4).b(), sty("pcc")).withText(sampleText).widget(),
            new Label(b.h(sfr, 1).v(sfr, 0.4).b(), sty("pcr")).withText(sampleText).widget(),
            new widgets.Slider(b.v(sfr, 0.1).b("slider r").withLiquidTransform(ar.getAspectRatio()), horizontal,
                f -> trace("" + f)).withProgress(0.5).widget(),
            texturedQuad(fuiBuilder, b.h(sfr, 1).v(sfr, 0.5).b().withLiquidTransform(ar.getAspectRatio()), "bunie.png").widget(),
            new Button(b.h(sfr, 1).v(px, 60).b().withLiquidTransform(ar.getAspectRatio()), null, "Button caption", sty("fit")).widget(),
            new Button(b.h(sfr, 1).v(sfr, 0.2).b().withLiquidTransform(ar.getAspectRatio()), null, "Button", sty("fit")).widget(),
            createBarWidget().widget(),
        ];
    }

    function lineHeightSample() {
        // todo
        return new Button(b.h(sfr, 1).v(sfr, 0.5).b().withLiquidTransform(ar.getAspectRatio()), null, "<font lineHeight=\"0.1\">Button </font>",
            sty("fit")).widget();
    }

    function sty(name) {
        // fuiBuilder.textStyles.
        return fuiBuilder.textStyles.getStyle(name);
    }

    function getSampleText() {
        return lime.utils.Assets.getText("Assets/heaps-fonts/Rich-text-sample.xml");
    }
}
