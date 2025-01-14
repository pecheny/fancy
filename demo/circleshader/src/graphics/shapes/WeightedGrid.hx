package graphics.shapes;

import Axis2D;
import SquareShape;
import a2d.Placeholder2D;
import a2d.WidgetInPixels;
import a2d.transform.WidgetToScreenRatio;
import al.core.MultiRefresher;
import al.core.WidgetContainer.Refreshable;
import data.IndexCollection;
import data.aliases.AttribAliases;
import fu.graphics.ShapeWidget;
import gl.AttribSet;
import graphics.ShapesColorAssigner;
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

class TGridFactory {
    var attrs:AttribSet;
    public function new(attrs) {
        this.attrs = attrs;
    }
    public function create(ph:Placeholder2D) {
        var steps = WidgetToScreenRatio.getOrCreate(ph.entity, ph, 0.05);

        var shw = new ShapeWidget(attrs, ph);
        var writers = attrs.getWriter(AttribAliases.NAME_POSITION);
        var posWeights = AVConstructor.create(Axis2D, [0, 0.5, 0.5, 1], [0., 1]);
        var uvWeights = AVConstructor.create(Axis2D, [0, 0.5, 0.5, 1], [0., 1]);
        var wwr = new WeightedAttWriter(writers, posWeights);
        var s = new WeightedGrid(wwr);
        var sa = new TGridWeightsWriter(ph, wwr);
        new ShapesColorAssigner(attrs, 0x77DEC7FF, shw.getBuffer());

        var rr = new MultiRefresher();
        rr.add(sa);
        ph.axisStates[vertical].addSibling(rr);
        shw.addChild(s);
        var wip = new WidgetInPixels(ph);
        rr.add(wip);
        var piuv = new WGridPixelDensity(posWeights, uvWeights, wip);
        rr.add(piuv);
        s.writeAttributes = new PhAntialiasing(attrs, s.getVertsCount(), piuv).writePostions;
        var uvs = new graphics.DynamicAttributeAssigner(attrs, shw.getBuffer());
        uvs.fillBuffer = (attrs, buffer) -> {
            var vertOffset = 0;
            var writers = attrs.getWriter(AttribAliases.NAME_UV_0);
            var wwr = new WeightedAttWriter(writers, uvWeights);
            wwr.writeAtts(buffer.getBuffer(), vertOffset, (_, v) -> v);
            var rad = new RadiusAtt(attrs, buffer.getVertCount());
            rad.writePostions(buffer.getBuffer(), 0, null);
            new fu.graphics.CircleThicknessCalculator(ph, steps, cast rad, buffer.getBuffer());
        };

        return shw;
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

class WGridPixelDensity implements PixelSizeInUVSpace implements Refreshable {
    var weights:AVector2D<Array<Float>>;
    var uvweights:AVector2D<Array<Float>>;
    var direction:Axis2D = horizontal;
    var wip:WidgetInPixels;

    public var pixelSizeInUVSpace(default, null):Float;

    public function new(wgs, uvwgs, wip) {
        this.weights = wgs;
        this.uvweights = uvwgs;
        this.wip = wip;
    }

    public function refresh() {
        var wgs = weights[direction];
        var size = wgs[1] - wgs[0];
        var pxPerQuad = wip.size[direction] * size;

        var wgs = uvweights[direction];
        var size = wgs[1] - wgs[0];
        var uvuPerQuad = size;

        trace('pqPq: $pxPerQuad, uvpq: $uvuPerQuad, wip: ${wip.size[direction]}');
        if (uvuPerQuad == 0)
            return;
        pixelSizeInUVSpace = uvuPerQuad / pxPerQuad;
    }
}