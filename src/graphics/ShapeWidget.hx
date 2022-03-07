package graphics;
import gl.AttribSet;
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

class ShapeWidget<T:AttribSet> extends Widgetable implements Renderable<T> {
    var buffer:Bytes;
    var posWriter:AttributeWriters;
    var children:Array<Shape> = [];
    var vertsCount:Int = 0;
    var inds:IndexCollection;
    var cp:SolidColorProvider;
    var attrs = ColorSet.instance;
    var fluidTransform:GFluidTransform;
    var inited = false;

    public function new(w:Widget2D) {
        super(w);
        posWriter = attrs.getWriter(AttribAliases.NAME_POSITION);
    }

    public function addChild(shape:Shape) {
        if (inited) throw "Can't add children after initialization";
        children.push(shape);
    }

    @:once var ratioProvider:AspectRatioProvider;

    override function init() {
        var aspectRatio = ratioProvider.getFactorsRef();
        fluidTransform = new GFluidTransform(aspectRatio);
        for (a in Axis2D.keys) {
            var applier2 = fluidTransform.getAxisApplier(a);
            w.axisStates[a].addSibling(applier2);
        }
        createShapes();
        initChildren();
        inited = true;
        onShapesDone();
    }

    function createShapes() {}

    function onShapesDone() {}

    function initChildren() {
        var indsCount = 0;
        vertsCount = 0;
        for (sh in children) {
            vertsCount += sh.getVertsCount();
            indsCount += sh.getIndices().length;
        }
        buffer = Bytes.alloc(vertsCount * attrs.stride);
        inds = new IndexCollection(indsCount);
        fillIndices();
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


    public function render(targets:RenderTargets<T>):Void {
        targets.blitIndices(inds, inds.length);
        var pos = 0;
        for (sh in children) {
            sh.writePostions(buffer, posWriter, pos);
            pos += sh.getVertsCount();
        }
        targets.blitVerts(buffer, vertsCount);
    }

    function printVerts(n) {
        for (i in 0...n)
            trace(i + " " + attrs.printVertex(buffer, i));
    }
}
