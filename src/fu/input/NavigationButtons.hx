package fu.input;


@:build(macros.BuildMacro.buildAxes())
enum abstract NavigationButtons(Axis<NavigationButtons>) to Axis<NavigationButtons> to Int {
    var forward;
    var backward;
}