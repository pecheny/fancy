package graphics.shapes;

import Axis2D;
import a2d.Placeholder2D;
import a2d.WidgetInPixels;
import a2d.transform.WidgetToScreenRatio;
import al.core.MultiRefresher;
import al.core.WidgetContainer.Refreshable;
import data.IndexCollection;
import data.aliases.AttribAliases;
import fu.graphics.ShapeWidget;
import gl.AttribSet;
import gl.sets.CircleSet;
import graphics.shapes.WeightedAttWriter;
import haxe.io.Bytes;
import macros.AVConstructor;

class WeightedGrid implements Shape {
    var inds:IndexCollection;
    var wwr:WeightedAttWriter;
    var count:Int;

    public function new(wwr) {
        this.wwr = wwr;
        inds = IndexCollection.qGrid(wwr.weights[horizontal].length, wwr.weights[vertical].length);
        count = wwr.weights[horizontal].length * wwr.weights[vertical].length;
    }

    public function writePostions(target:haxe.io.Bytes, vertOffset = 0, tr) {
        wwr.writeAtts(target, vertOffset, tr);
        writeAttributes(target, vertOffset, tr);
    }

    public dynamic function writeAttributes(target:Bytes, vertOffset = 0, transformer) {}

    public function getVertsCount():Int {
        return count;
    }

    public function getIndices() {
        return inds;
    }
}

class TGridWeightsWriter implements Refreshable {
    var wwr:WeightedAttWriter;
    var ph:Placeholder2D;

    public function new(ph, wwr) {
        this.ph = ph;
        this.wwr = wwr;
    }

    public function refresh() {
        var w = ph.axisStates[horizontal].getSize();
        var h = ph.axisStates[vertical].getSize();
        var dir = w > h ? horizontal : vertical;
        wwr.direction = dir;
        var cdir = dir.other();
        var so = ph.axisStates[cdir].getSize() / ph.axisStates[dir].getSize();
        var aw = wwr.weights[horizontal];
        aw[1] = so * 0.5;
        aw[2] = 1 - so * 0.5;
    }
}

class GridFactoryBase<T:AttribSet> {
    var attrs:T;
    var uvWeights:AVector2D<Array<Float>>;
    var aaAttrRequired = false;

    public function new(attrs) {
        this.attrs = attrs;
        aaAttrRequired = attrs.hasAttr(CircleSet.AASIZE_IN);
        uvWeights = createUVWeights();
    }

    public function create(ph:Placeholder2D) {
        var shw = new ShapeWidget(attrs, ph);
        var writers = attrs.getWriter(AttribAliases.NAME_POSITION);
        var posWeights = createPosWeights();
        var wwr = new WeightedAttWriter(writers, posWeights);
        var s = new WeightedGrid(wwr);
        shw.addChild(s);
        var sa = createGridWriter(ph, wwr);
        var rr = new MultiRefresher();
        rr.add(sa.refresh);
        ph.axisStates[vertical].addSibling(rr);
        if (aaAttrRequired)
            addAACalculator(ph, s, wwr, rr);
        shw.getBuffer().onInit.listen(addUV.bind(shw));
        return shw;
    }

    function createUVWeights():AVector2D<Array<Float>> {
        throw "abstract: N/A";
    }

    function createPosWeights():AVector2D<Array<Float>> {
        throw "abstract: N/A";
    }

    function createGridWriter(ph, wwr):Refreshable {
        throw "abstract: N/A";
    }

    function addAACalculator(ph, s, wwr, rr) {
        var wip = new WidgetInPixels(ph);
        rr.add(wip.refresh);
        var piuv = new WGridPixelDensity(wwr.weights, uvWeights, wip);
        rr.add(() -> {
            piuv.direction = wwr.direction;
        });
        rr.add(piuv.refresh);
        s.writeAttributes = new PhAntialiasing(attrs, s.getVertsCount(), piuv).writePostions;
    }

    function addUV(shw:ShapeWidget<T>) {
        var buffer:ShapesBuffer<T> = shw.getBuffer();
        var vertOffset = 0;
        var writers = attrs.getWriter(AttribAliases.NAME_UV_0);
        var wwr = new WeightedAttWriter(writers, uvWeights);
        wwr.writeAtts(buffer.getBuffer(), vertOffset, (_, v) -> v);
    }
}

class TGridFactory<T:AttribSet> extends GridFactoryBase<T> {
    override function createUVWeights() {
        return AVConstructor.create(Axis2D, [0, 0.5, 0.5, 1], [0., 1]);
    }

    override function createPosWeights() {
        return AVConstructor.create(Axis2D, [0, 0.5, 0.5, 1], [0., 1]);
    }

    override function createGridWriter(ph:Placeholder2D, wwr:WeightedAttWriter):Refreshable {
        return new TGridWeightsWriter(ph, wwr);
    }

    override function addAACalculator(ph, s, wwr, rr) {
        var wip = new WidgetInPixels(ph);
        rr.add(wip.refresh);
        var piuv = new WGridPixelDensity(wwr.weights, uvWeights, wip);
        rr.add(() -> {
            piuv.direction = wwr.direction;
        });
        rr.add(piuv.refresh);
        s.writeAttributes = new PhAntialiasing(attrs, s.getVertsCount(), piuv).writePostions;
    }

    override function addUV(shw:ShapeWidget<T>) {
        var buffer:ShapesBuffer<T> = shw.getBuffer();
        var vertOffset = 0;
        var writers = attrs.getWriter(AttribAliases.NAME_UV_0);
        var wwr = new WeightedAttWriter(writers, uvWeights);
        wwr.writeAtts(buffer.getBuffer(), vertOffset, (_, v) -> v);
    }
}

class NGridWeightsWriter implements Refreshable {
    var weights:AVector2D<Array<Float>>;
    var lineScale:ReadOnlyAVector2D<Float>;
    var cornerSize:Float;

    public function new(weights, lineScale, cornerSize) {
        this.weights = weights;
        this.lineScale = lineScale;
        this.cornerSize = cornerSize;
    }

    public function refresh() {
        for (a in Axis2D) {
            weights[a][1] = Math.min(cornerSize * lineScale[a], 0.5);
            weights[a][2] = Math.max(1 - cornerSize * lineScale[a], 0.5);
        }
    }
}

class NGridFactory<T:AttribSet> extends GridFactoryBase<T> {
    public var cornerSize = 3;

    public function new(attrs, cornerSize) {
        super(attrs);
        this.cornerSize = cornerSize;
    }

    override function createGridWriter(ph:Placeholder2D, wwr:WeightedAttWriter):Refreshable {
        var steps = WidgetToScreenRatio.getOrCreate(ph.entity, ph, 0.05);
        return new NGridWeightsWriter(wwr.weights, steps.getRatio(), cornerSize);
    }

    override function createPosWeights():AVector2D<Array<Float>> {
        return AVConstructor.create(Axis2D, [0, 0.5, 0.5, 1], [0, 0.5, 0.5, 1]);
    }

    override function createUVWeights():AVector2D<Array<Float>> {
        return AVConstructor.create(Axis2D, [0, 0.4999, 0.50001, 1], [0, 0.4999, 0.50001, 1]);
    }
}

class WGridPixelDensity implements PixelSizeInUVSpace implements Refreshable {
    var weights:AVector2D<Array<Float>>;
    var uvweights:AVector2D<Array<Float>>;
    var wip:WidgetInPixels;

    public var direction:Axis2D = horizontal;
    public var pixelSizeInUVSpace(default, null):Float;

    public function new(wgs, uvwgs, wip) {
        this.weights = wgs;
        this.uvweights = uvwgs;
        this.wip = wip;
    }

    public function refresh() {
        // current direction impl supposed for tgrid
        // which swaps weights according to the ratio
        // so primary weights applied to given direction is always horizontal
        var wgs = weights[horizontal];
        var size = wgs[1] - wgs[0];
        var pxPerQuad = wip.size[direction] * size;
        var wgs = uvweights[horizontal];
        var uvuPerQuad = wgs[1] - wgs[0];
        pixelSizeInUVSpace = uvuPerQuad / pxPerQuad;
    }
}
