package ;
import data.IndexCollection;
import data.IndexCollection.SimpleIndexProvider;
import gltools.SimpleBlitRenderer;
import gltools.VertDataRenderer;
import entitygl.DrawcallDataProvider;
import graphics.shapes.QuadGraphicElement;
import graphics.GraphicsLayer;
import transform.GAspectTransform;
import crosstarget.Widgetable;
import al.al2d.Axis2D;
import al.al2d.Widget2D;
import data.AttribAliases;
import ec.CtxBinder;
import gltools.sets.ColorSet;
import gltools.VertDataTarget.RenderDataTarget;
import mesh.providers.AttrProviders.SolidColorProvider;
import transform.AspectRatioProvider;

class ColouredQuad extends Widgetable {
    var q:GraphicsElement<ColorSet>;
    var colorContainer:GraphicsContainer<ColorSet>;
    var color:Int;

    public function new(w:Widget2D, color) {
        this.color = color;
        super(w);
    }

    @:once var ratioProvider:AspectRatioProvider;

    override function init() {
        var aspectRatio = ratioProvider.getFactorsRef();
        var fluidTransform = new GFluidTransform(aspectRatio);
        var e = w.entity;
        var renderTarget = new RenderDataTarget();
        colorContainer = new GraphicsContainer(ColorSet.instance, e, renderTarget);
        var qq = new QuadGraphicElement(ColorSet.instance);
        var tt = colorContainer.addGraphic(qq);

        q = fluidTransform.addChild(qq);
        colorContainer.build();

        for (a in Axis2D.keys) {
            var applier2:GTransformAxisApplier = cast fluidTransform.getAxisApplier(a);
            w.axisStates[a].addSibling(applier2);
        }
        cp = new SolidColorProvider(0, 0, 0);
//        new CtxBinder(Drawcalls, w.entity);
//        setColor(Std.int(0x90a030 * Math.random()));
        var dp = new DrawcallDataProvider(ColorSet.instance);
        dp.views.push(new VertDataRenderer(ColorSet.instance, new SimpleBlitRenderer(ColorSet.instance, renderTarget.getBytes()), new SimpleIndexProvider(IndexCollection.forQuadsOdd(1))));
        w.entity.addComponentByType(DrawcallDataProvider, dp);
        trace("done");
        setColor(color);
    }

    var cp:SolidColorProvider;


    public function setColor(c:Int) {
        cp.setColor(c);
        MeshUtils.writeInt8Attribute(ColorSet.instance, colorContainer.bytes(), AttribAliases.NAME_COLOR_IN, q.pos, q.vertCount(), cp.getValue);
    }
}
