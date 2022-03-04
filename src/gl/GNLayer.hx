package gl;
#if lime
import data.IndexCollection.IndicesFetcher;
import lime.graphics.opengl.GL;
import openfl.display.OpenGLRenderer;
import openfl.events.RenderEvent;
#end
import bindings.GLBuffer;
import bindings.GLProgram;
import bindings.GLUniformLocation;
import bindings.WebGLRenderContext;
import data.AttribAliases;
import data.AttribSet;
import data.ShadersAttrs;
import datatools.ExtensibleBytes;
import flash.events.Event;
import gltools.VertDataTarget.RenderDataTarget;
import gltools.VertIndDataProvider;
import openfl.display.DisplayObject;

#if nme
         import nme.gl.GL as gl;
#end
class GNLayer<T:AttribSet> extends DisplayObject {
    var program:GLProgram;
    var children:Array<VertIndDataProvider<T>> = [];
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

    public function addView(v:VertIndDataProvider<T>) {
        children.push(v) ;
    }

    public function removeView(v:VertIndDataProvider<T>) {
        children.remove(v) ;
    }

    var data = new RenderDataTarget();
    var inds = new ExtensibleBytes(64);


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
        data.pos = 0;
        for (child in children) {
            data.grantCapacity(data.pos + child.getVertsCount() * set.stride);
            child.render(data);
            data.pos += child.getVertsCount() * set.stride;
        }
        var indCount = gatherIndices(inds, 0, 0);
        bind();
        if (viewport != null)
            gl.viewport(viewport.x, viewport.y, viewport.width, viewport.height);
        gl.bufferData(gl.ARRAY_BUFFER, data.getView(), gl.STREAM_DRAW);
//         set uniforms
        gl.blendFunc(srcAlpha, dstAlpha);
        gl.uniform1f(screenTIdx, 0);
        gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, indicesBuffer);
        gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, inds.getView(), gl.DYNAMIC_DRAW);
        gl.drawElements(gl.TRIANGLES, indCount, gl.UNSIGNED_SHORT, 0);
        gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, null);
        unbind();
    }

    public function gatherIndices(target, startWith:Int, offset:Int) {
        var idxPointer = startWith;
        var vertPoin = offset;
        for (child in children) {
            IndicesFetcher.gatherIndices(target, idxPointer, vertPoin, child.getInds(), child.getIndsCount()) ;
            idxPointer += child.getIndsCount();
            vertPoin += child.getVertsCount();
        }
        return idxPointer;
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




