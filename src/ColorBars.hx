package ;
import data.IndexCollection;
import graphics.shapes.Shape;
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

class ColorBars extends Widgetable implements Renderable<ColorSet> {
    public var q:Bar;
    var color:Int;
    var buffer:Bytes;
    var posWriter:AttributeWriters;
    var children:Array<Shape> = [];
    var vertsCount:Int = 0;
    var inds:IndexCollection;
    var cp:SolidColorProvider;
    var attrs = ColorSet.instance;

    public function new(w:Widget2D, color) {
        this.color = color;
        super(w);
        posWriter = attrs.getWriter(AttribAliases.NAME_POSITION);
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
        cp = SolidColorProvider.fromInt(color, 128);

//        q = new QuadGraphicElement(attrs, fluidTransform.transformValue);
        var elements = [
            new BarContainer(FixedThikness(new BarAxisSlot ({pos:.5, thikness:1.}, null)), Portion(new BarAxisSlot ({start:0., end:1.}, null))),
            new BarContainer(FixedThikness(new BarAxisSlot ({pos:0., thikness:1.}, null)), Portion(new BarAxisSlot ({start:0., end:1.}, null)) ),
        ];
        var indsCount = 0;
        for (e in elements) {
            var sh = bb.create(attrs, fluidTransform.transformValue, e);
            children.push(sh);
            vertsCount += sh.getVertsCount();
            indsCount += sh.getIndices().length;
        }
        buffer = Bytes.alloc(vertsCount * attrs.stride);
        inds = new IndexCollection(indsCount);
        fillIndices();
        trace(inds);
        setColor(color);
    }

    function fillIndices() {
        var indNum = 0;
        var vertNum = 0;
        for (sh in children) {
            var shInds = sh.getIndices();
            for (i in 0...shInds.length) {
                inds[indNum + i] = shInds[i] + vertNum;
            }
            vertNum += sh.getVertsCount();
            indNum += shInds.length;
        }
    }


    public function setColor(c:Int) {
        cp.setColor(c);
        MeshUtilss.writeInt8Attribute(attrs, buffer, AttribAliases.NAME_COLOR_IN, 0, vertsCount, cp.getValue);
    }

    public function render(targets:RenderTargets<ColorSet>):Void {
        targets.blitIndices(inds, inds.length);
//        targets.verts.grantCapacity(attrs.stride * (targets.verts.pos + vertsCount));
        var pos = 0;
        for (sh in children) {
            sh.writePostions(buffer, posWriter, pos);
            pos += sh.getVertsCount();
        }
        targets.blitVerts(buffer, vertsCount );
    }

    function printVerts(n) {
        for (i in 0...n)
            trace(i  + " " + attrs.printVertex(buffer, i));
    }
}
