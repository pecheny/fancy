package fu.graphics;

import haxe.ds.ReadOnlyArray;
import a2d.AspectRatioProvider;
import a2d.Placeholder2D;
import ec.CtxWatcher;
import ecbind.RenderableBinder;
import ecbind.RenderablesComponent;
import gl.AttribSet;
import gl.Renderable;
import gl.RenderTarget;
import graphics.ShapeRenderer;
import graphics.shapes.Shape;
import graphics.ShapesBuffer;
import a2d.transform.LiquidTransformer;
import a2d.Widget;

class ShapeWidget<T:AttribSet> extends Widget implements Renderable<T> {
    public var onShapesDone:Signal<Void->Void> = new Signal();
    @:once var ratioProvider:AspectRatioProvider;
    @:once var transformer:LiquidTransformer;
    var attrs:T;
    var inited = false;
    var shapeRenderer:ShapeRenderer<T>;
    var children:Array<Shape> = [];
    // do not call initialization before manual call in order to construct shapes on placeholder with all deps.
    var delayInit = false;

    public function new(attrs:T, w:Placeholder2D, delayInit = false) {
        var drawcallsData = RenderablesComponent.get(attrs, w.entity);
        this.attrs = attrs;
        this.delayInit = delayInit;
        shapeRenderer = new ShapeRenderer(attrs);
        super(w);
        var drawcallsData = RenderablesComponent.get(attrs, w.entity);
        drawcallsData.views.push(this);
        new CtxWatcher(RenderableBinder, w.entity);
    }

    public function addChild(shape:Shape) {
        if (inited)
            throw "Can't add children after initialization";
        children.push(shape);
    }

    override function init() {
        if (delayInit)
            return;
        if (inited)
            return;
        shapeRenderer.transform = transformer.transformValue;
        createShapes();
        shapeRenderer.initChildren(children);
        inited = true;
        onShapesDone.dispatch();
    }

    public function manInit() {
        delayInit = false;
        if (_inited)
            init();
    }

    function createShapes() {}

    public function getBuffer():ShapesBuffer<T> {
        return shapeRenderer;
    }

    public function render(targets:RenderTarget<T>):Void {
        shapeRenderer.render(targets);
    }

    public function getChildren():ReadOnlyArray<Shape> {
        return children;
    }

    //    function printVerts(n) {
    //        for (i in 0...n)
    //            trace(i + " " + attrs.printVertex(buffer, i));
    //    }
}
