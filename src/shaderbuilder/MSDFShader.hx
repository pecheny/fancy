package shaderbuilder;
import bindings.GLProgram;
import bindings.GLUniformLocation;
import bindings.WebGLRenderContext;
import data.AttribAliases;
import data.VaryingAliases;
import gltools.aspects.MSDFTextureBinder;
import gltools.sets.MSDFSet;
import oglrenderer.GLLayer.RenderingElement;
import shaderbuilder.SnaderBuilder.PosPassthrough;
import shaderbuilder.SnaderBuilder.ShaderBase;
import shaderbuilder.SnaderBuilder.Uv0Passthrough;


class MSDFFrag implements ShaderElement {
    public static var instance = new MSDFFrag();
    static var uv_v = VaryingAliases.UV_0;
    static var smothness = MSDFShader.smoothness;


    public function new() {}

    public function getDecls():String {return'
                    uniform vec4 ${MSDFShader.color};
                    varying float $smothness;
					uniform sampler2D ${MSDFShader.glyphAtlas};
					varying vec2 $uv_v;

					float median(float r, float g, float b) {
					    return max(min(r, g), min(max(r, g), b));
					}';
    }

    public function getExprs():String {
        /* смуснес подогнана для вычесления от -s до + s,
						но формула для обводки не подходит в этом случае, фон перестает быть прозрачным. */
                    return
                        ' float vFieldRangeDisplay_px = 120.0;
        			    vec4 sample = texture2D(${MSDFShader.glyphAtlas}, $uv_v);
						float sigDist =  median(sample.r, sample.g, sample.b) - 0.5;
						// spread field range over 1px for antialiasing
						float fillAlpha = 	smoothstep(-$smothness, $smothness, sigDist );

                        float strokeWidth = 0.0;
						float strokeAlpha =	smoothstep(0., $smothness, sigDist + strokeWidth);
						vec4 strokeColor = vec4(0.0, 0.0, 0.0, 1.0);


//						- smoothstep(-$smothness, $smothness, sigDist -0.2);
//						float fillAlpha = clamp(sigDist, 0, 1);
//						float fillAlpha = clamp(sigDist, 0, 1);
//    					float fillAlpha = step(0.3, sigDist);
//						float fillAlpha = clamp((sigDist - 0.5) * vFieldRangeDisplay_px + 0.5, 0.0, 1.0);
//						float strokeWidthPx = 1.0;
//						float strokeDistThreshold = clamp(strokeWidthPx * 2. / vFieldRangeDisplay_px, 0.0, 1.0);
//						float strokeDistScale = 1. / (1.0 - strokeDistThreshold);
//						float _offset = 0.5 / strokeDistScale;
//						float strokeAlpha = clamp((sigDist - _offset) * vFieldRangeDisplay_px + _offset, 0.0, 1.0);

						vec4 col = vec4(.5, .5, .5, .5);
						vec4 otp = (
							${MSDFShader.color}	* fillAlpha * color.a
							+
							strokeColor * strokeColor.a * strokeAlpha
							* (1.0 - fillAlpha)
						);
//						gl_FragColor = col;
						gl_FragColor = otp;

';

    }
}


class LogisticSmoothnessCalculator implements ShaderElement {
    public static var instance(default, null) = new LogisticSmoothnessCalculator();

    function new() {}

    public function getDecls():String {
        return '
                varying float ${MSDFShader.smoothness};
                 attribute float ${MSDFSet.NAME_DPI};

                 float logist(float x) {
                           float p0 = 0.3;
                           float k = 0.5;
                           float r = 3.;
                           float t = (x -80.) / 100. ;
                           float ert = exp(r*t);
                           return 0.05 +  k -(k * p0 * ert) / (k + p0 *(ert - 1.));
    }
'    ;
    }

    public function getExprs():String {
        return '
                   ${MSDFShader.smoothness} = logist(${MSDFSet.NAME_DPI});';
    }
}

class MSDFShader extends ShaderBase {
    public static var instence = new MSDFShader();
    public static inline var smoothness = "smoothness";
    public static inline var resolution = "resolution";
    public static inline var glyphAtlas = "glyphAtlas";
    public static inline var color = "color";
    public static inline var position = AttribAliases.NAME_POSITION;
    public static inline var uv = AttribAliases.NAME_UV_0;
//    public static inline var atlasScale = MSDFSet.NAME_ATLAS_SCALE;

    public function new() {
        super(
            [PosPassthrough.instance, Uv0Passthrough.instance, LogisticSmoothnessCalculator.instance],
            [MSDFFrag.instance]
        );
    }

}

class MSDFRenderingElement implements RenderingElement {
    var gl:WebGLRenderContext;
    var texure:RenderingElement;
    var glyphAtlasTextureUnit = 0;

    var fieldRange:GLUniformLocation;
    var resolution:GLUniformLocation;
    var color:GLUniformLocation;
    var _transform:GLUniformLocation;

    public function new (image) {
        texure = new MSDFTextureBinder(image);
    }

    public function init(gl:WebGLRenderContext, program:GLProgram):Void {
        this.gl = gl;
        texure.init(gl, program);
//        glyphAtlas = gl.getUniformLocation(program, MSDFShader.glyphAtlas);
//        fieldRange = gl.getUniformLocation(program, MSDFShader.fieldRange);
//        resolution = gl.getUniformLocation(program, MSDFShader.resolution);
        color = gl.getUniformLocation(program, MSDFShader.color);
//        _transform = gl.getUniformLocation(program, MSDFShader.transform);
    }

    public function bind():Void {
        texure.bind();
//        gl.uniformMatrix4fv(_transform, false, mat);
//        gl.uniform1i(glyphAtlas, glyphAtlasTextureUnit);
//        gl.uniform1f(fieldRange, fieldRange_px);
//        gl.uniform2f(resolution, stage.stageWidth, stage.stageHeight);
        gl.uniform4f(color, 0.9, 0.9, 0.9, 1.0);
    }

    public function unbind():Void {
        texure.unbind();
    }
}