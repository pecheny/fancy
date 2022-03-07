package ;
import al.al2d.Axis2D;
import al.al2d.Widget2D;
import crosstarget.Widgetable;
import data.AttribAliases;
import gl.Renderable;
import gl.RenderTargets;
import gl.sets.ColorSet;
import gl.ValueWriter.AttributeWriters;
import gltools.VertDataTarget.RenderDataTarget;
import graphics.shapes.QuadGraphicElement;
import haxe.io.Bytes;
import mesh.providers.AttrProviders.SolidColorProvider;
import transform.AspectRatioProvider;
import transform.ProportionalTransformer;

class ColouredQuad extends Widgetable implements Renderable<ColorSet>{
    public var q:QuadGraphicElement<ColorSet>;
    var color:Int;
    var buffer:Bytes;
    var posWriter:AttributeWriters;
    public function new(w:Widget2D, color) {
        this.color = color;
        super(w);
        buffer =  Bytes.alloc(4*ColorSet.instance.stride);
        posWriter = ColorSet.instance.getWriter(AttribAliases.NAME_POSITION);
    }

    @:once var ratioProvider:AspectRatioProvider;

    override function init() {
        var aspectRatio = ratioProvider.getFactorsRef();
        var fluidTransform = new LiquidTransformator(aspectRatio);
        var e = w.entity;
        var renderTarget = new RenderDataTarget();
        q = new QuadGraphicElement(ColorSet.instance, fluidTransform.transformValue);

//        q = fluidTransform.addChild(qq);
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
        MeshUtilss.writeInt8Attribute(ColorSet.instance, buffer, AttribAliases.NAME_COLOR_IN, 0, 4, cp.getValue);
    }

    public function render(targets:RenderTargets<ColorSet>):Void {
        var inds = q.getIndices();
        targets.blitIndices(inds, inds.length);
        q.writePostions(buffer, posWriter);
        targets.blitVerts(buffer, 4);
    }


}
