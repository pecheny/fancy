package;

import a2d.Boundbox;
import macros.AVConstructor;
import al.core.AxisApplier;
import openfl.Lib;
import Axis2D;
import a2d.AspectRatioProvider;
import a2d.Stage;
import a2d.WindowSizeProvider;
import al.al2d.Placeholder2D;
import al.al2d.Widget2DContainer;
import al.openfl.StageAspectResizer;
import algl.Builder.PlaceholderBuilderGl;
import data.aliases.AttribAliases;
import ec.Entity;
import gl.sets.ColorSet;
import gl.sets.TexSet;
import graphics.ShapesColorAssigner;
import graphics.shapes.Bar;
import graphics.shapes.QuadGraphicElement;
import openfl.display.Sprite;
import scroll.ScrollableContent.W2CScrollableContent;
import scroll.ScrollboxItem;
import widgets.BarWidget;
import widgets.Button;
import widgets.Label;
import widgets.ShapeWidget;
import widgets.Widget;

using al.Builder;
using transform.LiquidTransformer;
using widgets.utils.Utils;

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
            new Button(b.h(sfr, 1).v(px, 60).b().withLiquidTransform(ar.getAspectRatio()), null, "Button caption", sty("fit")).widget(),
            spriteAdapter(b.h(pfr, 1).v(sfr, 0.1).b()).widget(),
            new Button(b.h(pfr, 1).v(px, 60).b().withLiquidTransform(ar.getAspectRatio()), null, "Button caption", sty("fit")).widget(),
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

    function spriteAdapter(w) {
        var spr = new Sprite();
        spr.graphics.beginFill(0xff0000);
        spr.graphics.drawRect(0, 0, 30, 30);
        spr.graphics.endFill();
        Lib.current.addChild(spr);
        return new AspectKeeper(w, spr);
        // return new SpriteAdapter(w, spr);
    }
}

class AspectKeeper extends Widget {
    var spr:Sprite;
    var bounds:a2d.Boundbox;
    var size = AVConstructor.create(Axis2D, 1., 1.);
    var pos = AVConstructor.create(Axis2D, 0., 0.);
    var ownSizeAppliers:AVector2D<AxisApplier>;
    @:once var s:Stage;

    public function new(w:Placeholder2D, spr:Sprite, bounds = null) {
        super(w);
        this.spr = spr;
        this.bounds = if (bounds == null) {
            var b = spr.getBounds(spr);
            new Boundbox(b.left, b.top, b.width, b.height);
        } else bounds;

        for (a in Axis2D) {
            w.axisStates[a].addSibling(new KeeperAxisApplier(pos, size, this, a));
        }
    }

    public function refresh() {
        if (!_inited)
            return;
        var scale = 9999.;
        for (a in Axis2D) {
            var _scale = size[a] / bounds.size[a];
            if (_scale < scale)
                scale = _scale;
        }

        for (a in Axis2D) {
            var free = size[a] - bounds.size[a] * scale;
            var pos = pos[a] + free / 2;
            trace(a, pos, scale);
            apply(a, pos, scale);
        }
    }

    inline function apply(a:Axis2D, pos:Float, scale:Float) {
        switch a {
            case horizontal:
                spr.x = w2scr(a, pos);
                spr.scaleX = w2scr(a, scale);
            case vertical:
                spr.y = w2scr(a, pos);
                spr.scaleY = w2scr(a, scale);
        }
        // trace(this.pos[a]  + " " + size[a]);
        // trace(spr.x  +" " + spr.scaleX  + " " + spr.width);
    }

    inline function w2scr(a, val:Float) {
        return val * s.getWindowSize()[a] / s.getAspectRatio()[a] / 2;
    }

    public function getApplier(a:Axis2D) {
        return ownSizeAppliers[a];
    }
}

class KeeperAxisApplier implements AxisApplier {
    var key:Axis2D;
    var keeper:AspectKeeper;

    var size:AVector2D<Float>;
    var pos:AVector2D<Float>;

    public function new(p, s, k, a) {
        this.pos = p;
        this.size = s;
        this.keeper = k;
        this.key = a;
    }

    public function apply(pos:Float, size:Float):Void {
        this.pos[key] = pos;
        this.size[key] = size;
        keeper.refresh();
    }
}
