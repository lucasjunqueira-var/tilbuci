package com.tilbuci.script;

import com.tilbuci.data.GlobalPlayer;
import haxe.Timer;

class ActionTimer {

    /**
        timer name
    **/
    public var name:String;

    /**
        the timer itself
    **/
    private var _timer:Timer;

    /**
        the action to run
    **/
    private var _action:Dynamic;

    /**
        the action to run on timer end
    **/
    private var _acend:Dynamic;

    /**
        number of iteractions
    **/
    private var _current:Int;

    /**
        number of steps to run
    **/
    private var _steps:Int;

    public function new(nm:String, interv:Int, stp:Int, ac:Dynamic, end:Dynamic = null) {
        this.name = nm;
        this._steps = stp;
        this._current = 0;
        this._action = ac;
        this._acend = end;
        this._timer = new Timer(interv);
        this._timer.run = this.runAction;
    }

    /**
        Clears current actyiopn timer.
    **/
    public function clear():Void {
        try {
            this._timer.stop();
        } catch (e) { }
        this._timer = null;
        this.name = null;
        this._acend = null;
        this._action = null;
    }

    /**
        Timer action run.
    **/
    private function runAction():Void {
        if (this._action != null) GlobalPlayer.parser.run(this._action, true);
        this._current++;
        if (this._current >= this._steps) {
            if (this._acend != null) GlobalPlayer.parser.run(this._acend, true);
            this.clear();
        }
    }

}