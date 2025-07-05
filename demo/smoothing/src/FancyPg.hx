package;

import a2d.AspectRatioProvider;
import a2d.PlaceholderBuilder2D;
import al.ec.WidgetSwitcher;
import backends.openfl.SpriteAspectKeeper;
import ec.Entity;
import fu.gl.GuiDrawcalls;
import fu.graphics.BarWidget;
import fu.ui.Slider;
import fu.ui.Button;
import fu.ui.Label;
import gl.sets.ColorSet;
import graphics.ShapesColorAssigner;
import graphics.shapes.Bar;
import openfl.Lib;
import openfl.display.Sprite;

using a2d.transform.LiquidTransformer;
using al.Builder;
using fu.ui.Slider.FlatSlider;


class FancyPg extends Sprite {
    var fuiBuilder = new FuiBuilder();
    var sampleText = "FoEo Bar AbAb Aboo Distance Field texture Ad Ae Af Bd Be Bf Bb Ab Dd De Df Cd Ce Cf";
    var b:PlaceholderBuilder2D;
    var ar:AspectRatioProvider;
    var pictureFile = "Assets/bunie.png";

    public function new() {
        super();
        ar = fuiBuilder.ar;
        b = new PlaceholderBuilder2D(fuiBuilder.ar);
        var root:Entity = fuiBuilder.createDefaultRoot();
        var uikit = new FlatUikit(fuiBuilder);
        uikit.drawcallsLayout.addChild(Xml.parse(PictureDrawcalls.DRAWCALLS_LAYOUT(pictureFile)).firstElement());
        uikit.configure(root);
        uikit.createContainer(root);
        createTextStyles();

        var rw = Builder.h();

        var container = b.b("c1").createContainer(vertical, Forward);
        fuiBuilder.makeClickInput(container.ph);
        var scrollPlaceholder = fuiBuilder.createScrollbox(container, b.b(), uikit.drawcallsLayout);
        rw.addWidget(scrollPlaceholder);
        for (ch in createMixedContentArray())
            container.addWidget(ch);

        var cright = Builder.v().withChildren([
            new Label(b.b(), sty("pcr")).withText(sampleText).ph,
            fuiBuilder.texturedQuad(b.h(pfr, 1).v(sfr, 0.5).b().withLiquidTransform(ar.getAspectRatio()), pictureFile).ph,
        ]);
        rw.addWidget(cright);
        root.getComponent(WidgetSwitcher).switchTo(rw.ph);
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

    function createMixedContentArray() {
        return [
            new Button(b.h(sfr, 1).v(px, 60).b().withLiquidTransform(ar.getAspectRatio()), null, "Button caption", sty("fit")).ph,
            spriteAdapter(b.h(pfr, 1).v(sfr, 0.1).b()).ph,
            new Button(b.h(pfr, 1).v(px, 60).b().withLiquidTransform(ar.getAspectRatio()), null, "Button caption", sty("fit")).ph,
            new Label(b.h(sfr, 1).v(sfr, 0.4).b(), sty("pcl")).withText(sampleText).ph,
            new Label(b.h(sfr, 1).v(sfr, 0.4).b(), sty("pcc")).withText(sampleText).ph,
            new Label(b.h(sfr, 1).v(sfr, 0.4).b(), sty("pcr")).withText(sampleText).ph,
            new SliderInput(b.v(sfr, 0.1).b("slider r").withLiquidTransform(ar.getAspectRatio()), horizontal).withFlat().withProgress(0.5).ph,
            fuiBuilder.texturedQuad(b.h(sfr, 1).v(sfr, 0.5).b().withLiquidTransform(ar.getAspectRatio()), pictureFile).ph,
            new Button(b.h(sfr, 1).v(px, 60).b().withLiquidTransform(ar.getAspectRatio()), null, "Button caption", sty("fit")).ph,
            new Button(b.h(sfr, 1).v(sfr, 0.2).b().withLiquidTransform(ar.getAspectRatio()), null, "Button", sty("fit")).ph,
            createBarWidget().ph,
        ];
    }

    function lineHeightSample() {
        // todo
        return new Button(b.h(sfr, 1)
            .v(sfr, 0.5)
            .b()
            .withLiquidTransform(ar.getAspectRatio()), null, "<font lineHeight=\"0.1\">Button </font>", sty("fit")).ph;
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
