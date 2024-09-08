package fu;

import font.FontStorage;
import font.bmf.BMFont.BMFontFactory;
import gl.RenderingPipeline;
import gl.aspects.RenderingAspect;
import gl.aspects.TextureBinder;
import utils.TextureStorage;

class GuiDrawcalls {
	public static inline var TEXT_DRAWCALL:DrawcallType = "text";
	public static inline var BG_DRAWCALL:DrawcallType = "color";

	public static final DRAWCALLS_LAYOUT = '<container>
        <drawcall type="color"/>
        <drawcall type="text" font="" color="0xffffff"/>
    </container>';
}


