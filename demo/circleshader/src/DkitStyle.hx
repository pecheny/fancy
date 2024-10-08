package;

import a2d.ContainerStyler;
import al.layouts.PortionLayout;
import al.layouts.WholefillLayout;
import al.layouts.data.LayoutData;
import fancy.domkit.Dkit;
import fu.PropStorage;

using a2d.transform.LiquidTransformer;
using al.Builder;

class DkitStyle {
    public static function createStyles(fui:FuiBuilder, e) {
        var default_text_style = "small-text";

        var pcStyle = fui.textStyles.newStyle(default_text_style)
            .withSize(sfr, .07)
            .withPadding(horizontal, sfr, 0.1)
            .withAlign(vertical, Center)
            .build();

        var props = new DummyProps<String>();
        props.set(Dkit.TEXT_STYLE, default_text_style);
        e.addComponentByType(PropStorage, props);

        var distributer = new al.layouts.Padding(new FractionSize(.25), new PortionLayout(Center, new FixedSize(0.1)));
        var contLayouts = new ContainerStyler();
        contLayouts.reg(GuiStyles.L_HOR_CARDS, distributer, WholefillLayout.instance);
        e.addComponent(contLayouts);
    }
}
