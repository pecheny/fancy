package fu.input;

import a2d.Widget;
import al.core.DataView;
import al.core.TWidget.IWidget;
import fu.input.FocusManager.FocusRequestSource;
import Axis2D.AVector2D;
import al.core.AxisState;
import dkit.Dkit.DataContainerDkit;
import fu.input.FocusManager.LinearFocusManager;
import fu.ui.scroll.ScrollableContent.Scrollable;

// todo: may broke if WidgetFocus appears deep inside hierarchy (deeper than direct child of the data-container)
// step1: add check to bind()/unbind()
// step2: warn and offer to create intermediate focus manager to intercect subchildren
class DataContainerFocus extends LinearFocusManager {
    @:once var scroll:Scrollable;

    var dcontainer:DataContainerDkit<Any, Dynamic>;
    // var dcontainer:DataContainerDkit<Dynamic, Dynamic<IWidget<Axis2D> & DataView<Dynamic>>>;

    public function new(dcontainer) {
        this.dcontainer = dcontainer;
        super(dcontainer.entity);
    }

    override function init() {
        super.init();
    }

    override function focusOn(on:Int, source:FocusRequestSource) {
        if (on < 0 || on > buttons.length - 1 || !_inited || source == view_state) {
            super.focusOn(on, source);
            return;
        }
        var chn = dcontainer.getItems();
        var viewport = dcontainer.ph;
        var vas:AVector2D<AxisState> = viewport.axisStates;
        for (a in Axis2D) {
            var w:IWidget<Axis2D> = cast chn[on];
            var bas = w.ph.axisStates;
            var bph:AxisState = bas[a]; // workaround for hl target, maybe not required already
            var vph:AxisState = vas[a];
            if (bph.getPos() < vph.getPos()) {
                var localPos:Float = bph.getPos() - vph.getPos() - scroll.getOffset(a);
                scroll.setOffset(a, -localPos);
            } else if (bph.getPos() + bph.getSize() > vph.getPos() + vph.getSize()) {
                var localPos:Float = bph.getPos() - vph.getPos() - scroll.getOffset(a);
                var offset = bph.getSize() - (vph.getSize() - localPos);
                scroll.setOffset(a, -offset);
            }
        }
        super.focusOn(on, source);
    }
}
