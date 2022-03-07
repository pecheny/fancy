package graphics.shapes;
import gl.sets.ColorSet;
import gl.ValueWriter;
import al.al2d.Axis2D;
import al.al2d.Widget2D.AxisCollection2D;
import al.al2d.Widget2D;
import data.IndexCollection;
import graphics.shapes.RectWeights;
import haxe.ds.ReadOnlyArray;
import haxe.io.Bytes;
import transform.AspectRatio;

class Bar implements Shape {
    var axis:AxisCollection2D<BarAxisBase> = new AxisCollection2D();
    var transformators:(Axis2D, Float) -> Float;

    public function new(att, xt, yt, transformators) {
        this.transformators = transformators;
        axis[horizontal] = xt;
        axis[vertical] = yt;
    }

    public function writePostions(target:Bytes, writer:AttributeWriters, vertOffset = 0) {
        for (a in Axis2D.keys) {
            axis[a].writePositions(a, transformators, target, writer, vertOffset);
        }
    }

    public function getVertsCount():Int {
        return 4;
    }

    public function getIndices() {
        return IndexCollections.QUAD_ODD;
    }
}

class BarContainer {
    public var axis:AxisCollection2D<BarAxisType>;

    public function new(x:BarAxisType, y:BarAxisType) {
        axis = [
            horizontal => x,
            vertical => y ];
    }
}

enum BarAxisType {
    Portion(slot:BarAxisSlot<PortionBarAxisDescr, PortionTransformApplier>);
    FixedThikness(slot:BarAxisSlot<FixedThiknessDescr, FixedThiknessTransformApplier>);
}

class BarAxisSlot<TDescr, TInst:BarAxisBase> {
    public var descr:TDescr;
    public var instance:TInst;

    public function new(d, i) {
        this.descr = d;
        this.instance = i;
    }
}

class BarAxisBase {
    public var componentWriter:IValueWriter;

    public function writePositions(a:Axis2D, tr:(Axis2D, Float) -> Float, target:Bytes, writer:AttributeWriters, vertOffset = 0):Void {
        throw "not implemented";
    }
}

typedef FixedThiknessDescr = {
    var thikness:Float;
    var pos:Float;
}

class FixedThiknessTransformApplier extends BarAxisBase {
    var weights:ReadOnlyArray<Float>;
    public var pos:Float = 0;
    public var thikness:Float = 0.1;
    var lineScales:ReadOnlyArray<Float>;


    public function new(weights, lineScales) {
        this.weights = weights;
        this.lineScales = lineScales;
    }

    override public function writePositions(a:Axis2D, tr:(Axis2D, Float) -> Float, target:Bytes, writer:AttributeWriters, vertOffset = 0):Void {
        var localTh = lineScales[a] * thikness;
        var totalWidth = 1 - localTh;
        var lPos = totalWidth * pos;
        for (i in 0...weights.length) {
            writer[a].setValue(target, vertOffset + i, tr(a, lPos + weights[i] * (lineScales[a] )));
        }
    }
}

typedef PortionBarAxisDescr = {
    var start:Float;
    var end:Float;
}

class PortionTransformApplier extends BarAxisBase {
    var weights:ReadOnlyArray<Float>;
    public var start:Float = 0;
    public var end:Float = 1;

    public function new(weights) {
        this.weights = weights;
    }

    override public function writePositions(a:Axis2D, tr:(Axis2D, Float) -> Float, target:Bytes, writer:AttributeWriters, vertOffset = 0):Void {
        for (i in 0...weights.length) {
            writer[a].setValue(target, vertOffset + i, tr(a, start + weights[i] * (end - start)));
        }
    }
}

class BarsBuilder {
    var lineScales:ReadOnlyArray<Float>;

    public function new(aspectRatio:AspectRatio, lineScales:ReadOnlyArray<Float>) {
        this.lineScales = lineScales;
    }

    public function createAxis(axis:Axis2D, input:BarAxisType):BarAxisBase {
        switch input {
            case Portion(slot) :
                var apl = new PortionTransformApplier(RectWeights.weights[axis]);
                apl.start = slot.descr.start;
                apl.end = slot.descr.end;
                slot.instance = apl;
                return apl;
            case FixedThikness(slot):
                var apl = new FixedThiknessTransformApplier(RectWeights.weights[axis], lineScales);
                apl.pos = slot.descr.pos;
                apl.thikness = slot.descr.thikness;
                slot.instance = apl;
                return apl;
        }
    }

    public function create(attrs, tr, container:BarContainer) {
        return new Bar(attrs,
        createAxis(horizontal, container.axis[horizontal]),
        createAxis(vertical, container.axis[vertical]),
        tr);
    }
}

class BarAnimationUtils {
    public static function directUnfold(bar:BarContainer, axis = null):Float -> Void {
        if (axis != null) {
            switch bar.axis[axis] {
                case Portion(slot):
                    return (t) -> slot.instance.end = t * slot.descr.end;
                case _:
            }
        }
        for (a in Axis2D.keys) {
            switch bar.axis[a] {
                case Portion(slot):
                    return (t) -> slot.instance.end = t * slot.descr.end;
                case _:
            }
        }
        return (_) -> {};
    }
}