package fu.ui;

import a2d.transform.TransformerBase;
import gl.sets.CMSDFSet;
import htext.AttributeFiller;
import htext.SmothnessWriter;
import htext.TextColorFiller;
import htext.TextLayouter;
import htext.TextRender;

using htext.TextTransformer;

class CMSDFLabel extends LabelBase<CMSDFSet> {
    var color(get, set):Int;
    var cw:TextColorFiller<CMSDFSet>;
    var rend:TextRender<CMSDFSet>;
    var glyphs:ColorXmlGlyphs;

    public function new(w, tc) {
        glyphs = new ColorXmlGlyphs();
        super(w, tc, CMSDFSet.instance);
    }

    public function setColor(c:Int) {
        glyphs.color = c;
        if (cw == null)
            return;
        rend.setDirty();
    }

    override function createTextRender(attrs:CMSDFSet, l, tt:TransformerBase) {
        var dpiWriter = attrs.getWriter(CMSDFSet.NAME_DPI);
        var wrs = new AttFillContainer();
        wrs.addChild(new SmothnessWriter(dpiWriter[0], l, textStyleContext, tt, stage.getWindowSize()));
        cw = new TextColorFiller(CMSDFSet.instance, glyphs);
        wrs.addChild(cw);
        rend = new TextRender(attrs, l, tt, wrs);
        return rend;
    }

    override function createLayouter():TextLayouter {
        return textStyleContext.createLayouter(glyphs);
    }

    function set_color(value:Int):Int {
        setColor(value);
        return value;
    }

    function get_color():Int {
        return glyphs.color;
    }
}
