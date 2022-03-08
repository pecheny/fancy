package bindings;
typedef GLUniformLocation =
#if lime
lime.graphics.opengl.GLUniformLocation;
#elseif js
js.html.webgl.GLUniformLocation;
#else
Dynamic;
#end

