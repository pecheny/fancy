package shaderbuilder;
class TextureFragment implements ShaderElement {
    static var storage:Map<String,TextureFragment> = new Map();

    inline static function getKey(uvChannel:String, imageChannel:String) {
        return "" + uvChannel  + " " + imageChannel;
    }

    public static macro function get(uvChannel:Int, imgChannel:Int) {
        return macro {
            var uv = $p{["Aliases", "VA", "UV_" + $v{uvChannel}]};
            var smpl = $p{["Aliases", "UA", "IMG_" + $v{imgChannel}]};
            TextureFragment._get(uv, smpl);
        }
    }

    public static function _get(attr, vary) {
        var key = getKey(attr, vary);
        if (storage.exists(key))
            return storage[key];
        var sh = new TextureFragment(attr, vary);
        storage[key] = sh;
        return sh;
    }

    var uv:String;
    var sampler:String;
    function new(attr, vary) {
        this.uv = attr;
        this.sampler = vary;
        trace("CON " + attr  + " " + vary);
    }

    public function getDecls():String {
        return '
        varying vec2 ${uv};
        uniform sampler2D ${sampler};';
    }

    public function getExprs():String {
        return '
				    gl_FragColor = texture2D (${sampler}, ${uv});';
    }
}

