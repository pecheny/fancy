package widgets;
import a2d.AspectRatioProvider;
import al.al2d.Placeholder2D;
import ec.CtxWatcher;
import ecbind.RenderableBinder;
import ecbind.RenderablesComponent;
import gl.AttribSet;
import gl.Renderable;
import gl.RenderTarget;
import graphics.ShapeRenderer;
import graphics.shapes.Shape;
import graphics.ShapesBuffer;
import transform.LiquidTransformer;
import widgets.Widget;

class ShapeWidget<T:AttribSet> extends Widget implements Renderable<T> {

    var attrs:T;
    var inited = false;
    var shapeRenderer:ShapeRenderer<T>;

    public function new(attrs:T, w:Placeholder2D) {
        this.attrs = attrs;
        shapeRenderer = new ShapeRenderer(attrs);
        super(w);
        var drawcallsData = RenderablesComponent.get(attrs, w.entity);
        drawcallsData.views.push(this);
        new CtxWatcher(RenderableBinder, w.entity);
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
