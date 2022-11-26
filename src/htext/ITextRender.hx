package htext;
import gl.Renderable;
import gl.AttribSet;
interface ITextRender<T:AttribSet> extends Renderable<T> {
    function setText(s:String):Void;
}
