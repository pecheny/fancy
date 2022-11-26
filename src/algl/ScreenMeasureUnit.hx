package algl;

/**
*  Options of units  to define zize in gl-like environments, when 'native' units depends on window size.
*  @see al.al2d.AspectEatio
**/
@:enum abstract ScreenMeasureUnit(String) {
    /** Size inpixels */
    var px = "px";
    /** Fraction of smallest screen side */
    var sfr = "sfr";
    /** Fraction of the parent. */
    var pfr = "pfr";
}