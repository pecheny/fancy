package fu.bootstrap;

import al.prop.ScaleComponent;
import shimp.ClicksInputSystem.ClickTargetViewState;
import shimp.ClicksInputSystem.ClickViewProcessor;
import ec.Component;
import macros.AVConstructor;

class ButtonScale extends Component {
    @:once var scale:ScaleComponent;
    @:once var viewProc:ClickViewProcessor;
    var scaleVals = AVConstructor.create(ClickTargetViewState, 1., 1.05, 1.02, 0.95);

    override function init() {
        super.init();
        viewProc.addHandler(viewStateChange);
        viewStateChange(Idle);
    }

    function viewStateChange(st:ClickTargetViewState) {
        this.scale.value = scaleVals[st];
    }
}
