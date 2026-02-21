package fu.ui;

import data.aliases.AttribAliases;
import htext.TextDepthFiller;
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
    @:once var depth:DepthComponent;

    public function new(w, tc) {
        glyphs = new ColorXmlGlyphs();
        super(w, tc, CMSDFSet.instance);
    }

    public function setColor(c:Int) {
        glyphs.color = c;
        if (cw == null)
            return;
        // to trigger XmlText relayout assigned text should differ from previous one.
        // TODO maybe if text contains no color tags filling color attribute instead on relayouting would be more efficient
        layouter.setText("");
        layouter.setText(text);
        rend.setDirty();
    }

    override function createTextRender(attrs:CMSDFSet, l, tt:TransformerBase) {
        var dpiWriter = attrs.getWriter(CMSDFSet.NAME_DPI);
        var wrs = new AttFillContainer();
        wrs.addChild(new SmothnessWriter(dpiWriter[0], l, textStyleContext, tt, stage.getWindowSize()));
        cw = new TextColorFiller(CMSDFSet.instance, glyphs);
        wrs.addChild(cw);

        var dwr = new TextDepthFiller(attrs.getWriter(AttribAliases.NAME_DEPTH)[0], glyphs);
        function writeDepth() {
            dwr.value = depth.value;
            trace(dwr.value);
            rend.setDirty();
        }
        depth.onChange.listen(writeDepth);
        wrs.addChild(dwr);

        rend = new TextRender(attrs, l, tt, wrs);
        writeDepth();
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
