package fu.ui;

import gl.sets.CMSDFSet;
import htext.AttributeFiller;
import htext.SmothnessWriter;
import htext.TextColorFiller;
import htext.TextRender;
import a2d.transform.TransformerBase;

class CMSDFLabel extends LabelBase<CMSDFSet> {
    var color:Int = 0xffffff;
    var cw:TextColorFiller<CMSDFSet>;
    var rend:TextRender<CMSDFSet>;

    public function new(w, tc) {
        createTextRender = _createTextRender;
        super(w, tc, CMSDFSet.instance);
    }

    public function setColor(c:Int) {
        color = c;
        if (cw == null)
            return;
        cw.color = c;
        rend.setDirty();
    }

    function _createTextRender(attrs:CMSDFSet, l, tt:TransformerBase) {
        var dpiWriter = attrs.getWriter(CMSDFSet.NAME_DPI);
        var wrs = new AttFillContainer();
        wrs.addChild(new SmothnessWriter(dpiWriter[0], l, textStyleContext, tt, stage.getWindowSize()));
        cw = new TextColorFiller(CMSDFSet.instance, l);
        cw.color = color;
        wrs.addChild(cw);
        rend = new TextRender(attrs, l, tt, wrs);
        return rend;
    }
}
