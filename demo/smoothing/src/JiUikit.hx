package;

import macros.AVConstructor;
import ec.Entity;

class JiUikit extends FlatUikitExtended {
    public static var INACTIVE_COLORS(default, null):AVector<shimp.ClicksInputSystem.ClickTargetViewState, Int> = AVConstructor.create( //    Idle =>
        0xBB121212,
        0xBB121212,
        0xBB121212,
        0xBB121212,
    );
    
    public static var INTERACTIVE_COLORS(default, null):AVector<shimp.ClicksInputSystem.ClickTargetViewState, Int> = AVConstructor.create( //    Idle =>
        0xff000000, //    Hovered =>
        0xffd46e00, //    Pressed =>
        0xFFd46e00, //    PressedOutside =>
        0xff000000);

    override function configure(e:Entity) {
        // var fntPath = "Assets/fonts/robo.fnt";
        ctx.fonts.initFont("", "Assets/fonts/RobotoSlab-24-df2.fnt", null);
        ctx.fonts.initFont("24-2", "Assets/fonts/RobotoSlab-24-df2.fnt", null);
        ctx.fonts.initFont("24-8", "Assets/fonts/RobotoSlab-24-df8.fnt", null);

        regDefaultDrawcalls();
        regStyles(e);
        regLayouts(e);
    }
}
