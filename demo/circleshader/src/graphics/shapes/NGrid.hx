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
