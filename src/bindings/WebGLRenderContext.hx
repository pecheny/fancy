package bindings;
typedef WebGLRenderContext =
#if boo
bindings.mock.WebGLRenderContext;
#elseif lime
lime.graphics.WebGLRenderContext;
#elseif js
js.html.webgl.Program;
#else
Dynamic
#end
