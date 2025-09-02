package fu.bootstrap;

import fu.graphics.ColouredQuad.InteractiveColors;
import shimp.ClicksInputSystem.ClickViewProcessor;
import graphics.ShapesColorAssigner;
import ec.Component;

class ButtonColors extends Component {
    @:once var colors:ShapesColorAssigner<Dynamic>;
    @:once var button:ClickViewProcessor;

    override function init() {
        button.addHandler(new InteractiveColors(colors.setColor).viewHandler);
    }
}
