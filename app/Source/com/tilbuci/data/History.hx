package com.tilbuci.data;

class History {

    /**
        scene states
    **/
    public var states:Array<HistoryState> = [ ];

    /**
        current state
    **/
    public var current(get, null):Int;
    private function get_current():Int { return (this._current); }
    private var _current:Int = 0;

    /**
        history display update call
    **/
    public var historyDisplay:Dynamic;

    /**
        property display update methoed
    **/
    public var propDisplay:Array<Dynamic> = [ ];

    /**
        maximum number of states to hold
    **/
    private var _max:Int = 20;

    public function new() {

    }

    /**
        Adds a history state.
        @param  name    history state name
    **/
    public function addState(name:String = ''):Void {
        while (this.states.length > (this._current + 1)) this.states.pop();
        this.states.push({
            title: DateTools.format(Date.now(), "%H:%M:%S"), 
            state: GlobalPlayer.movie.scene.toObject(), 
            orientation: Global.displayType, 
            keyframe: GlobalPlayer.area.currentKf, 
            name: name
        });
        while (this.states.length > this._max) this.states.shift();
        this._current = this.states.length - 1;
        if (this.historyDisplay != null) this.historyDisplay();
    }

    public function updateProperties():Void {
        for (pd in this.propDisplay) {
            pd();
        }
    }

    public function loadState(num:Int):Bool {
        if (this.states.length > num) {
            Global.displayType = this.states[num].orientation;
            GlobalPlayer.movie.scene.fromObject(this.states[num].state);
            this._current = num;
            return (true);
        } else {
            return (false);
        }
    }
    

    /**
        Clears the history.
    **/
    public function clear():Void {
        while (this.states.length > 0) this.states.shift();
        this._current = -1;
        if (this.historyDisplay != null) this.historyDisplay();
    }

}

/**
    History state.
**/
typedef HistoryState = {
    var state:Dynamic;
    var orientation:String;
    var keyframe:Int;
    var title:String;
    var name:String;
}