package graphics;
import IGT.IGraphicsTransform;
import al.core.AxisApplier;
import al.al2d.Axis2D;
import al.al2d.GlAxis2DDirection;
import al.appliers.PropertyAccessors.FloatPropertyReader;
import data.AttribAliases;
import data.AttribSet;
import data.AttributeDescr;
import data.IndexCollection;
import datatools.ExtensibleBytes;
import datatools.ValueWriter.TransformValueWriter;
import datatools.ValueWriter;
import ec.Entity;
import gltools.SimpleBlitRenderer;
import gltools.VertDataRenderer;
import gltools.VertDataTarget.RenderDataTarget;
import haxe.ds.ReadOnlyArray;
import haxe.io.Bytes;


class GraphicsContainer<T:AttribSet> implements IGraphicsTransform {
    var children:Array<GraphicsElement<T>>;
    var renderTarget:RenderDataTarget;
    var attrs:T;
    var layerId = "";
    var e:Entity;

    public function new(attrs:T, e:Entity, renderTarget:RenderDataTarget, layerId = "") {
        this.attrs = attrs;
        this.e = e;
        this.layerId = layerId;
        children = [];
        this.renderTarget = renderTarget;
    }

    public function addGraphic<TG:GraphicsElement<T>>(ge:TG):TG {
        children.push(ge);
        return ge;
    }

    public function bytes() {
        return renderTarget.getBytes();
    }


    public function applyTransform(a:Axis2D, tr:Float -> Float) {
        for (ch in children) {
            ch.applyTransform(a, tr);
        }
    }

    public inline function getChildren():ReadOnlyArray<GraphicsElement<T>> return children;


/**
*  Prepare indices and make children ready to create writers
**/
    public function build(firstVert = 0) {
        var vertCount = 0;
        var indCount = 0;
        for (ge in children) {
            vertCount += ge.vertCount();
            indCount += ge.indexCollection().length;
        }

        renderTarget.grantCapacity(attrs.stride * (firstVert + vertCount));
        var inds = new ExtensibleBytes(indCount * IndexCollection.ELEMENT_SIZE);
        var pos = firstVert;
        var indPos = 0;
        for (ge in children) {
            ge.add(pos);
            ge.createWriters(renderTarget.getBytes());
            var indCount = ge.indexCollection().length;
            IndicesFetcher.gatherIndices(inds, indPos, pos, ge.indexCollection(), indCount);
            pos += ge.vertCount();
            indPos += indCount;
        }
        var view = new VertDataRenderer(attrs, new SimpleBlitRenderer(attrs, renderTarget.getBytes()), new SimpleIndexProvider(inds.bytes));
//        var drawcallsData = DrawcallDataProvider.get(attrs, e, layerId);
//        drawcallsData.views.push(view);
        return pos;
    }

}

typedef AttributeWriters = Array<IValueWriter>;

class GraphicsElement<T:AttribSet> implements IGraphicsTransform {
    var writers:Map<String, AttributeWriters> = new Map();
    public var pos:Int = -1;
    var attrs:T;

    public function new(attrs:T) {
        this.attrs = attrs;

    }

    public function posInTarget():Int {
        if (pos == -1)
            throw "add to container first";
        return pos;
    }

    public function vertCount():Int {
        throw "n/a";
    }

    public function applyTransform(a:Axis2D, tr:Float -> Float) {}


    public function add(pos:Int) {
        this.pos = pos;
    }

    public function indexCollection():IndexCollection {
        throw "n/a";
    }

    public function createWriter<T:AttribSet>(bytes:Bytes, attr, cmpId):IValueWriter {
        //todo WRONG!: cant use getBytes(). extensibleBytes can rebuild it and link would be broken
        var tr = ValueWriter.create(bytes, attrs.getDescr(attr), cmpId, attrs.stride, pos * attrs.stride);
//        tr.replaceTransform(tr);
        return tr;
    }

    public function getWriter(alias:String, target:Bytes):AttributeWriters {
        if (writers.exists(alias))
            return writers[alias];
        for (descr in attrs.attributes) {
            if (descr.name == alias) {
                writers[descr.name] = createWritersForAttribute(descr, target);
                return writers[descr.name];
            }
        }
        throw "wrong attr " + alias;
    }

    inline function createWritersForAttribute(descr:AttributeDescr, target:Bytes):AttributeWriters {
        var wrs = [];
        for (i in 0...descr.numComponents) {
            wrs.push(createWriter(target, descr.name, i));
        }
        return wrs;
    }

    public function createWriters(target:Bytes) {
        for (descr in attrs.attributes) {
            writers[descr.name] = createWritersForAttribute(descr, target);
        }
    }
}


