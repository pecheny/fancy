package states;

import update.Updatable;

class State {
    public function update(t:Float):Void {}

    public function onEnter():Void {}

    public function onExit():Void {}
}

class StateMachine extends StateSwitcher {
    var verbose = false;
    var states:ClassMap<State> = new ClassMap();

    public function addState<T:State>(s:T) {
        states.set(Type.getClass(s), s);
    }

    public function changeState(s:Class<State>) {
        if (verbose)
            trace("Switching to " + s);
        var st = states.get(s);
        if (st == null)
            throw 'State $s not defined';
        switchState(st);
    }
}

class StateSwitcher implements Updatable {
    var currentState:State;

    public function new() {}

    public function switchState(s:State) {
        if (currentState != null)
            currentState.onExit();

        currentState = s;
        if (currentState != null)
            currentState.onEnter();
    }

    public function update(dt:Float) {
        if (currentState != null)
            currentState.update(dt);
    }
}

typedef ClassMap<V> = haxe.ds.ObjectMap<Dynamic, V>;
