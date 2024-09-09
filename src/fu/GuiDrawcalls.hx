package fu;

import gl.RenderingPipeline;

class GuiDrawcalls {
	public static inline var TEXT_DRAWCALL:DrawcallType = "text";
	public static inline var BG_DRAWCALL:DrawcallType = "color";

	public static final DRAWCALLS_LAYOUT = '<container>
        <drawcall type="color"/>
        <drawcall type="text" font="" color="0xffffff"/>
    </container>';
}

class PictureDrawcalls {
	public static inline var IMAGE_DRAWCALL = "image";

	public static function DRAWCALLS_LAYOUT(filename)
		return '<drawcall type="image" font="" path="$filename" />';
}
