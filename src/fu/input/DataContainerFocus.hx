package fu.input;

import al.core.AxisState;
import dkit.Dkit.DataContainerDkit;
import fu.input.FocusManager.LinearFocusManager;
import fu.ui.scroll.ScrollableContent.Scrollable;

// todo: may broke if WidgetFocus appears deep inside hierarchy (deeper than direct child of the data-container)
// step1: add check to bind()/unbind()
// step2: warn and offer to create intermediate focus manager to intercect subchildren
class DataContainerFocus extends LinearFocusManager {
    @:once var scroll:Scrollable;

    var dcontainer:DataContainerDkit<Any>;

    public function new(dcontainer) {
        this.dcontainer = dcontainer;
        super(dcontainer.entity);
    }

    override function init() {
        super.init();
    }
    
    override function gotoButton(activeButton:Int) {
        var chn = dcontainer.getItems();
        for (a in Axis2D) {
            var bas = chn[activeButton].ph.axisStates;
            var bph:AxisState = bas[a]; // workaround for hl target
            var cas = dcontainer.ph.axisStates;
            var cph:AxisState = cas[a];
            var localPos:Float = bph.getPos() - cph.getPos() - scroll.getOffset(a);
            scroll.setOffset(a, -localPos);
        }
        super.gotoButton(activeButton);
    }
}
