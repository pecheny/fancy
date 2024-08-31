package;

import backends.openfl.SpriteAspectKeeper;
import fu.graphics.Slider;
import fu.ui.Button;
import fu.graphics.BarWidget;
import fu.graphics.ShapeWidget;
import a2d.PlaceholderBuilder2D;
import FuiBuilder.XmlLayerLayouts;
import al.ec.WidgetSwitcher;
import a2d.Boundbox;
import macros.AVConstructor;
import al.core.AxisApplier;
import openfl.Lib;
import Axis2D;
import a2d.AspectRatioProvider;
import a2d.Stage;
import a2d.WindowSizeProvider;
import a2d.Placeholder2D;
import a2d.Widget2DContainer;
import al.openfl.StageAspectResizer;
import data.aliases.AttribAliases;
import ec.Entity;
import gl.sets.ColorSet;
import gl.sets.TexSet;
import graphics.ShapesColorAssigner;
import graphics.shapes.Bar;
import graphics.shapes.QuadGraphicElement;
import openfl.display.Sprite;
import fu.ui.scroll.ScrollableContent.W2CScrollableContent;
import fu.ui.scroll.ScrollboxItem;
import fu.ui.Label;


using al.Builder;
using a2d.transform.LiquidTransformer;
using a2d.transform.LiquidTransformer;

class FancyPg extends Sprite {
    var fuiBuilder = new FuiBuilder();
    var sampleText = "FoEo Bar AbAb Aboo Distance Field texture Ad Ae Af Bd Be Bf Bb Ab Dd De Df Cd Ce Cf";
    var b:PlaceholderBuilder2D;
    var ar:AspectRatioProvider;

    public function new() {
        super();
        
        ar = fuiBuilder.ar;
        b = new PlaceholderBuilder2D(fuiBuilder.ar);
        var root:Entity = fuiBuilder.createDefaultRoot(XmlLayerLayouts.COLOR_AND_TEXT);
        createTextStyles();

        // var container:Sprite = root.getComponent(Sprite);
        // addChild(container);

        var rw = Builder.h();

        var scrollPlaceholder = createScrollbox(fuiBuilder.makeClickInput(b.b("c1").createContainer(vertical, Forward).widget()), b.b(), ar, XmlLayerLayouts.COLOR_AND_TEXT,
            createMixedContentArray);
        rw.addWidget(scrollPlaceholder);

        var cright = Builder.v().withChildren([
            new Label(b.b(), sty("pcr")).withText(sampleText).ph,
            texturedQuad(fuiBuilder, b.h(pfr, 1).v(sfr, 0.5).b().withLiquidTransform(ar.getAspectRatio()), "bunie.png").ph,
        ]);
        rw.addWidget(cright);
        root.getComponent(WidgetSwitcher).switchTo(rw.widget());
    }


    function createScrollbox(container1:Placeholder2D, placeholder:Placeholder2D, ar, dl, childrenFactory:FuiBuilder->Array<Placeholder2D>) {
        var cont = container1.entity.getComponent(Widget2DContainer);
        var scroll = new W2CScrollableContent(cont, placeholder);

        placeholder.entity.name = "placeholder";
        var scroller = new ScrollboxItem(placeholder, scroll, ar.getAspectRatio());
        fuiBuilder.addScissors(scroller.ph);
        fuiBuilder.createContainer(scroller.ph.entity, Xml.parse(dl).firstElement());
        for (ch in childrenFactory(fuiBuilder))
            cont.addWidget(ch);
        // var spr:Sprite = scroller.ph.entity.getComponent(Sprite);
        // addChild(spr);
        // fuiBuilder.pipeline.setAspects([]);
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
            // var spr:Sprite = w.entity.getComponent(Sprite);
            // addChild(spr);
        }
        return shw;
    }

    function createTextStyles() {
        var pxStyle = fuiBuilder.textStyles.newStyle("px").withSize(px, 64).build();

        var pcStyle = fuiBuilder.textStyles.newStyle("pcl") //        .withAlign(vertical, Center)
            .withSize(sfr, .1)
            .withPadding(horizontal, sfr, 0.3)
            .build();

        var pcStyleR = fuiBuilder.textStyles.newStyle("pcr").withAlign(horizontal, Backward).build();
        var pcStyleC = fuiBuilder.textStyles.newStyle("pcc").withAlign(horizontal, Center).build();
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
            new Button(b.h(sfr, 1).v(px, 60).b().withLiquidTransform(ar.getAspectRatio()), null, "Button caption", sty("fit")).ph,
            spriteAdapter(b.h(pfr, 1).v(sfr, 0.1).b()).ph,
            new Button(b.h(pfr, 1).v(px, 60).b().withLiquidTransform(ar.getAspectRatio()), null, "Button caption", sty("fit")).ph,
            new Label(b.h(sfr, 1).v(sfr, 0.4).b(), sty("pcl")).withText(sampleText).ph,
            new Label(b.h(sfr, 1).v(sfr, 0.4).b(), sty("pcc")).withText(sampleText).ph,
            new Label(b.h(sfr, 1).v(sfr, 0.4).b(), sty("pcr")).withText(sampleText).ph,
            new Slider(b.v(sfr, 0.1).b("slider r").withLiquidTransform(ar.getAspectRatio()), horizontal,
                f -> trace("" + f)).withProgress(0.5).ph,
            texturedQuad(fuiBuilder, b.h(sfr, 1).v(sfr, 0.5).b().withLiquidTransform(ar.getAspectRatio()), "bunie.png").ph,
            new Button(b.h(sfr, 1).v(px, 60).b().withLiquidTransform(ar.getAspectRatio()), null, "Button caption", sty("fit")).ph,
            new Button(b.h(sfr, 1).v(sfr, 0.2).b().withLiquidTransform(ar.getAspectRatio()), null, "Button", sty("fit")).ph,
            createBarWidget().ph,
        ];
    }

    function lineHeightSample() {
        // todo
        return new Button(b.h(sfr, 1).v(sfr, 0.5).b().withLiquidTransform(ar.getAspectRatio()), null, "<font lineHeight=\"0.1\">Button </font>",
            sty("fit")).ph;
    }

    function sty(name) {
        // fuiBuilder.textStyles.
        return fuiBuilder.textStyles.getStyle(name);
    }

    function getSampleText() {
        return lime.utils.Assets.getText("Assets/heaps-fonts/Rich-text-sample.xml");
    }

    function spriteAdapter(w) {
        var spr = new Sprite();
        spr.graphics.beginFill(0xff0000);
        spr.graphics.drawRect(0, 0, 30, 30);
        spr.graphics.endFill();
        Lib.current.addChild(spr);
        return new SpriteAspectKeeper(w, spr);
        // return new SpriteAdapter(w, spr);
    }
}
