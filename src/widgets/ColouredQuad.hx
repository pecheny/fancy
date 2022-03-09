package widgets;
import al.al2d.Axis2D;
import al.al2d.Widget2D;
import crosstarget.Widgetable;
import data.aliases.AttribAliases;
import ec.CtxBinder;
import gl.ec.DrawcallDataProvider;
import gl.ec.Drawcalls;
import gl.Renderable;
import gl.RenderDataTarget;
import gl.RenderTargets;
import gl.sets.ColorSet;
import gl.ValueWriter.AttributeWriters;
import graphics.shapes.QuadGraphicElement;
import haxe.io.Bytes;
import mesh.MeshUtilss;
import mesh.providers.AttrProviders.SolidColorProvider;
import transform.AspectRatioProvider;
import transform.LiquidTransformer;

class ColouredQuad extends Widgetable implements Renderable<ColorSet> {
    public var q:QuadGraphicElement<ColorSet>;
    var color:Int;
    var buffer:Bytes;
    var posWriter:AttributeWriters;

    public function new(w:Widget2D, color) {
        this.color = color;
        super(w);
        buffer = Bytes.alloc(4 * ColorSet.instance.stride);
        posWriter = ColorSet.instance.getWriter(AttribAliases.NAME_POSITION);
    }

    @:once var ratioProvider:AspectRatioProvider;

    override function init() {
        var aspectRatio = ratioProvider.getFactorsRef();
        var fluidTransform = new LiquidTransformer(aspectRatio);
        var e = w.entity;
        var renderTarget = new RenderDataTarget();
        q = new QuadGraphicElement(ColorSet.instance, fluidTransform.transformValue);
        for (a in Axis2D.keys) {
            w.axisStates[a].addSibling(fluidTransform.getAxisApplier(a));
        }
        var drawcallsData = DrawcallDataProvider.get(ColorSet.instance, w.entity);
        drawcallsData.views.push(this);
        new CtxBinder(Drawcalls, w.entity);
        cp = new SolidColorProvider(0, 0, 0);
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
