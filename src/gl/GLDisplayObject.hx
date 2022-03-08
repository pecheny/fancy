package gl;
#if lime
import gl.sets.ColorSet;
import lime.graphics.opengl.GL;
import openfl.display.OpenGLRenderer;
import openfl.events.RenderEvent;
#end
import bindings.GLBuffer;
import bindings.GLProgram;
import bindings.GLUniformLocation;
import bindings.WebGLRenderContext;
import data.aliases.AttribAliases;
import gl.AttribSet;
import data.ShadersAttrs;
import flash.events.Event;
import openfl.display.DisplayObject;

#if nme
         import nme.gl.GL as gl;
#end
class GLDisplayObject<T:AttribSet> extends DisplayObject {
    var program:GLProgram;
    var children:Array<Renderable<T>> = [];
    var gl:WebGLRenderContext;
    var viewport:ViewportRect;

    public var srcAlpha = GL.SRC_ALPHA;
    public var dstAlpha = GL.ONE_MINUS_SRC_ALPHA;

    var buffer:GLBuffer;
    var set:T;
    var attrsState:ShadersAttrs;
    private var indicesBuffer:GLBuffer;
    var screenTIdx:GLUniformLocation;
    var shaderBuilder:WebGLRenderContext -> GLProgram;
    var renderingAspect:RenderingElement;
    var one:Bool;

    public function new(set:T, shaderBuilder:WebGLRenderContext -> GLProgram, aspect:RenderingElement, one = false) {
        super();
        this.one = one;
        this.renderingAspect = aspect;
        this.set = set;
        this.shaderBuilder = shaderBuilder;
        this.targets  = new RenderTargets(set);
        addEventListener(RenderEvent.RENDER_OPENGL, render);
        addEventListener(Event.ENTER_FRAME, onEnterFrame);
    }
    var err:String;
    function init(gl:WebGLRenderContext) {
//        trace(stage.context3D.driverInfo);
        try {
            this.program = shaderBuilder(gl);
        } catch (e:Dynamic) {
           err = ""+e;
        }
        if (err!= null){
            trace(err);
            return;
        }

        attrsState = set.buildState(gl, program);
        buffer = gl.createBuffer();
        indicesBuffer = gl.createBuffer();
        screenTIdx = gl.getUniformLocation(program, AttribAliases.NAME_SCREENSPACE_T);
        if (renderingAspect != null)
            renderingAspect.init(gl, program);
    }

    function onEnterFrame(e) {
        invalidate();
    }

    public function update() {
        #if !flash
        invalidate();
        #end
    }

    public function addView(v:Renderable<T>) {
        children.push(v) ;
    }

    public function removeView(v:Renderable<T>) {
        children.remove(v) ;
    }

    var targets:RenderTargets<T> ;
//    var inds = new DynamicBytes(64);


    public function render(event:RenderEvent) {
        var renderer:OpenGLRenderer = cast event.renderer;
        if (err != null) {
            trace("shader error: " + err);
            throw err;
        }
        gl = renderer.gl;
        if (program == null) {
            init(gl);
        }

        targets.flush();

        for (child in children) {
            child.render(targets);
        }
        var indCount = targets.indsCount();//;gatherIndices(inds, 0, 0);
        bind();
        if (viewport != null)
            gl.viewport(viewport.x, viewport.y, viewport.width, viewport.height);

        gl.bufferData(gl.ARRAY_BUFFER, targets.verts.getView(), gl.STREAM_DRAW);
//         set uniforms
        gl.blendFunc(srcAlpha, dstAlpha);
        gl.uniform1f(screenTIdx, 0);
        gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, indicesBuffer);
        gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, targets.inds.getView(), gl.DYNAMIC_DRAW);
        gl.drawElements(gl.TRIANGLES, indCount, gl.UNSIGNED_SHORT, 0);
        gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, null);
        unbind();
    }

    function printVerts(n) {
        for (i in 0...n)
            trace( set.printVertex(targets.verts.getBytes(), i) );
    }

    public function setViewport(x, y, w, h) {
        this.viewport = new ViewportRect(x, y, w, h);
    }


    public function bind() {
        gl.useProgram(program);
        gl.bindBuffer(gl.ARRAY_BUFFER, buffer);
        set.enableAttributes(gl, attrsState);
        if (renderingAspect != null)
            renderingAspect.bind();
    }

    public function unbind() {
        gl.useProgram(null);
        gl.bindBuffer(gl.ARRAY_BUFFER, null);
        if (renderingAspect != null)
            renderingAspect.unbind();
    }
}

class ViewportRect {
    public var x:Int;
    public var y:Int;
    public var width:Int;
    public var height:Int;

    public function new(x, y, w, h) {
        this.x = x;
        this.y = y;
        this.width = w;
        this.height = h;
    }
}

interface Bindable {
    function bind():Void;

    function unbind():Void;
}

interface GLInitable {
    public function init(gl:WebGLRenderContext, program:GLProgram):Void;
}

interface RenderingElement extends Bindable extends GLInitable {}




