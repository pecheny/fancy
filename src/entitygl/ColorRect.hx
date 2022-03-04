package entitygl;
import al.al2d.Axis2D;
import al.core.AxisApplier;
import al.layouts.data.LayoutData.Size;
import data.AttribAliases;
import data.IndexCollection;
import datatools.AttributeWriter.Attribute4Writer;
import datatools.ExtensibleBytes;
import datatools.ValueWriter;
import gltools.sets.ColorSet;
import gltools.VertIndDataProvider;
import haxe.io.Bytes;
import mesh.VertDataProviderBase;
class ColorRect implements VertIndDataProvider<ColorSet> extends VertDataProviderBase<ColorSet> {
    var axisStates = new Map<Axis2D, RectAxis>();

    public function new() {
        super(ColorSet.instance);
        vertData = Bytes.alloc(4 * attributes.stride);
        var xw = ValueWriter.create(vertData, attributes.getDescr(AttribAliases.NAME_POSITION), 0, attributes.stride);
        var xa = new RectAxis(xw, [0, 0, 1, 1]);
        axisStates[Axis2D.horizontal] = xa;
        var yw =  ValueWriter.create(vertData, attributes.getDescr(AttribAliases.NAME_POSITION), 1, attributes.stride);
        var ya = new RectAxis(yw, [0, 1, 0, 1]);
        axisStates[Axis2D.vertical] = ya;
        var colorWriter = new Attribute4Writer(vertData, attributes.getDescr(AttribAliases.NAME_COLOR_IN), attributes.stride);
        for (i in 0...4) {
            colorWriter.setValue(i, Std.int(Math.random() * 255), 23, 23, 255);
        }
        indData = IndexCollection.forQuadsOdd(1);
        indCount = 6;
        vertCount = 4;
    }

    public function getAxisStates():Map<Axis2D, RectAxis> {
        return axisStates;
    }

    public function gatherIndices(target:ExtensibleBytes, startFrom:Int, offset) {
        IndicesFetcher.gatherIndices(target, startFrom, offset, indData, getIndsCount());
    }
}
class RectAxis implements AxisApplier {
    var weights:Array<Float>;
    var writer:IValueWriter;
    var pos:Float = 0;
    var size:Float = 1;
    var sizeInstance = new Size();

    public function new(writer, weights) {
        this.writer = writer;
        this.weights = weights;
        this.sizeInstance.setWeight(1);
    }

    public function setValue(pos:Float, size:Float) {
        for (i in 0...weights.length)
            writer.setValue(i, pos + size * weights[i]);
    }

    public function apply(pos, size):Void {
        this.pos = pos;
        this.size = size;
        setValue(pos, size);
    }

    public function getSize():Float {
        return size;
    }

    public function getPos():Float {
        return pos;
    }

    public function isArrangable():Bool {
        return true;
    }
}
