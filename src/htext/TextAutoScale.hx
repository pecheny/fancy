package htext;

import fancy.ScaleComponent;
import ec.Component;

class TextAutoScale extends Component {
    @:once var scale:ScaleComponent;
    var tr:TextTransformer;
    var consumer:htext.ITextRender.ITextConsumer;
    var autoWidth:Null<TextAutoWidth>;

    public function new(e, tr, cons, aw) {
        this.tr = tr;
        this.autoWidth = aw;
        this.consumer = cons;
        super(e);
    }

    override function init() {
        super.init();
        scale.onChange.listen(onChange);
        onChange();
    }

    function onChange() {
        tr.scale = scale.value;
        consumer.setDirty();
        autoWidth?.apply(0, 0);
    }
}
