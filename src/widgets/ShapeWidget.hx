package widgets;
import graphics.ShapesBuffer;
import graphics.ShapeRenderer;
import al.al2d.Placeholder2D;
import widgets.Widget;
import ec.CtxWatcher;
import gl.AttribSet;
import ecbind.DrawcallDataProvider;
import ecbind.Drawcalls;
import gl.Renderable;
import gl.RenderTarget;
import graphics.shapes.Shape;
import a2d.AspectRatioProvider;
import transform.LiquidTransformer;

class ShapeWidget<T:AttribSet> extends Widget implements Renderable<T> {

    var attrs:T;
    var inited = false;
    var shapeRenderer:ShapeRenderer<T>;

    public function new(attrs:T, w:Placeholder2D) {
        this.attrs = attrs;
        shapeRenderer = new ShapeRenderer(attrs);
        super(w);
        var drawcallsData = DrawcallDataProvider.get(attrs, w.entity);
        drawcallsData.views.push(this);
        new CtxWatcher(Drawcalls, w.entity);
    }

    public function addChild(shape:Shape) {
        if (inited) throw "Can't add children after initialization";
        shapeRenderer.addChild(shape);
    }

    @:once var ratioProvider:AspectRatioProvider;
    @:once var transformer:LiquidTransformer;

    override function init() {
        shapeRenderer.transform = transformer.transformValue;
        createShapes();
        shapeRenderer.initChildren();
        inited = true;
        onShapesDone();
    }

    function createShapes() {}

    function onShapesDone() {}

    public function getBuffer():ShapesBuffer<T> {
        return shapeRenderer;
    }

    public function render(targets:RenderTarget<T>):Void {
        shapeRenderer.render(targets);
    }

//    function printVerts(n) {
//        for (i in 0...n)
//            trace(i + " " + attrs.printVertex(buffer, i));
//    }
}
