package ;
import gl.RenderTargets;
import gl.Renderable;
import data.IndexCollection;
import data.IndexCollection.SimpleIndexProvider;
import gltools.SimpleBlitRenderer;
import gltools.VertDataRenderer;
import entitygl.DrawcallDataProvider;
import graphics.shapes.QuadGraphicElement;
import transform.GAspectTransform;
import crosstarget.Widgetable;
import al.al2d.Axis2D;
import al.al2d.Widget2D;
import data.AttribAliases;
import ec.CtxBinder;
import gl.sets.ColorSet;
import gltools.VertDataTarget.RenderDataTarget;
import mesh.providers.AttrProviders.SolidColorProvider;
import transform.AspectRatioProvider;

class ColouredQuad extends Widgetable implements Renderable<ColorSet>{
    public var q:QuadGraphicElement<ColorSet>;
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
        var qq = new QuadGraphicElement(ColorSet.instance);

        q = fluidTransform.addChild(qq);
//        colorContainer.build();

        for (a in Axis2D.keys) {
            var applier2:GTransformAxisApplier = cast fluidTransform.getAxisApplier(a);
            w.axisStates[a].addSibling(applier2);
        }
        cp = new SolidColorProvider(0, 0, 0);
//        new CtxBinder(Drawcalls, w.entity);
//        setColor(Std.int(0x90a030 * Math.random()));
//        var dp = new DrawcallDataProvider(ColorSet.instance);
//        dp.views.push(new VertDataRenderer(ColorSet.instance, new SimpleBlitRenderer(ColorSet.instance, renderTarget.getBytes()), new SimpleIndexProvider(IndexCollection.forQuadsOdd(1))));
//        w.entity.addComponentByType(DrawcallDataProvider, dp);
        trace("done");
        setColor(color);
    }

    var cp:SolidColorProvider;


    public function setColor(c:Int) {
        cp.setColor(c);
    }

    public function render(targets:RenderTargets<ColorSet>):Void {
        MeshUtilss.writeInt8Attribute(ColorSet.instance, targets.verts.getBytes(), AttribAliases.NAME_COLOR_IN, targets.verts.pos, 4, cp.getValue);
        q.render(targets);
    }


}
