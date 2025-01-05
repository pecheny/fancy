package fu;

import font.FontStorage;
import htext.style.TextContextBuilder;
import gl.RenderingPipeline;

interface FuCtx {
    public var fonts(default, null):FontStorage;
    public var pipeline:RenderingPipeline;
    public var textStyles:TextContextBuilder;
}
