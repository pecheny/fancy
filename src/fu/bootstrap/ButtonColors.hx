package fu.bootstrap;

import fu.graphics.ColouredQuad.InteractiveColors;
import fu.ui.ButtonBase.ClickViewProcessor;
import graphics.ShapesColorAssigner;
import ec.Component;

class ButtonColors extends Component {
    @:once var colors:ShapesColorAssigner<Dynamic>;
    @:once var button:ClickViewProcessor;

    override function init() {
        button.addHandler(new InteractiveColors(colors.setColor).viewHandler);
    }
}
