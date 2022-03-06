package ;
import al.al2d.Axis2D;
import al.al2d.LineThicknessCalculator;
import al.al2d.Widget2D;
import crosstarget.Widgetable;
import data.AttribAliases;
import gl.Renderable;
import gl.RenderTargets;
import gl.sets.ColorSet;
import gl.ValueWriter.AttributeWriters;
import graphics.shapes.Bar;
import haxe.io.Bytes;
import mesh.providers.AttrProviders.SolidColorProvider;
import transform.AspectRatioProvider;
import transform.GAspectTransform;

class ColorBars extends Widgetable implements Renderable<ColorSet>{
    public var q:Bar;
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
        var fluidTransform = new GFluidTransform(aspectRatio);
        for (a in Axis2D.keys) {
            var applier2:GTransformAxisApplier = cast fluidTransform.getAxisApplier(a);
            w.axisStates[a].addSibling(applier2);
        }

        var lineCalc = new LineThicknessCalculator(w, aspectRatio);
        var bb = new BarsBuilder(aspectRatio, lineCalc.lineScales());
        cp = new SolidColorProvider(0, 0, 0);

//        q = new QuadGraphicElement(ColorSet.instance, fluidTransform.transformValue);
        var elements = [
        new BarContainer(FixedThikness(new BarAxisSlot ({pos:0., thikness:1.}, null)), Portion(new BarAxisSlot ({start:0., end:1.}, null)))
        ];
        q = bb.create(ColorSet.instance, fluidTransform.transformValue, elements[0]);
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
