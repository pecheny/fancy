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
import graphics.shapes.WeightedGrid;
import haxe.io.Bytes;
import macros.AVConstructor;
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
