package bindings;
typedef GLBuffer =
#if lime
lime.graphics.opengl.GLBuffer;
#elseif js
js.html.webgl.Buffer;
#else
Dynamic
#end

