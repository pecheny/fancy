package dkit;

import fu.ui.DepthCMSDFLabel;
import a2d.Placeholder2D;
import dkit.Dkit.BaseDkit;
import fu.PropStorage;
import htext.style.TextContextBuilder.TextContextStorage;

using a2d.ProxyWidgetTransform;

@:uiComp("label")
@:domkitDecl
class LabelDkit extends BaseDkit // implements DataView<String>
{
    public var align(default, set):Null<htext.Align>;
    public var color(default, set):Null<Int>;
    public var alpha(get, set):Int;
    public var label:DepthCMSDFLabel;
    public var text(default, set):String = "";
    public var style(default, default):String = "";
    public var autoSize:Bool = false;

    @:once var styles:TextContextStorage;
    @:once var props:MultiPropStorage;

    public function new(p:Placeholder2D, ?parent) {
        super(p, parent);
    }

    override function init() {
        super.init();
        if (style == "")
            style = props.getString(Dkit.TEXT_STYLE);
        if (color == null)
            color = props.getInt(Dkit.TEXT_COLOR);
        if (color == null)
            color = 0;

        //  commented code - wip on scroll support for label widget
        // var ph = this.ph;
        // if (scroll)
        //     ph = b().b();
        label = new DepthCMSDFLabel(ph, fui.s(style));
        if (autoSize) {
            label.setAutoSizeMode(word_wrap);
            // entity.addComponentByType(ResizableWidget2D, label);
        }
        // initDkit();
        color = color;
        text = text;
        align = align;
    }

    function set_color(value:Int):Int {
        color = value;
        label?.setColor(value);
        return value;
    }

    function set_alpha(v:Int) {
        var color:utils.RGBA = this.color;
        color.a = v;
        this.color = color;
        return v;
    };

    function get_alpha():Int {
        var color:utils.RGBA = this.color;
        return color.a;
    }

    function set_text(value:String):String {
        text = value;
        label?.withText(value);
        return value;
    }

    // public function initData(descr:String):Void {
    //     set_text(descr);
    // }

    function set_align(value) {
        label?.setAlign(value);
        return align = value;
    }
}
