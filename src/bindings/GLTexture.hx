package bindings;
typedef GLTexture =
#if nme
nme.gl.GLTexture
#elseif lime
lime.graphics.opengl.GLTexture;
#end
