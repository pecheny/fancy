package bindings;
typedef GLProgram =
#if nme
nme.gl.GLProgram
#elseif lime
lime.graphics.opengl.GLProgram
#elseif js
js.html.webgl.Program
#else
Dynamic
#end;

