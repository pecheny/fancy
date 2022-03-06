package gl;
interface Renderable<T:AttribSet> {
    function render(targets:RenderTargets<T>):Void;
}
