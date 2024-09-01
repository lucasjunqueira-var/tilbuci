package com.tilbuci.plugin;

/** OPENFL **/
import openfl.display.Sprite;

/** TILBUCI **/
import com.tilbuci.script.ScriptParser;

/**
    Plugin access object.
**/
class PluginAccess {

    /**
        string variables
    **/
    public var varString:Map<String, String>;

    /**
        float variables
    **/
    public var varFloat:Map<String, Float>;

    /**
        int variables
    **/
    public var varInt:Map<String, Int>;

    /**
        boolean variables
    **/
    public var varBool:Map<String, Bool>;

    /**
        script parser
    **/
    public var parser:ScriptParser;

    public function new(vS:Map<String, String>, 
                        vF:Map<String, Float>, 
                        vI:Map<String, Int>, 
                        vB:Map<String, Bool>,
                        pr:ScriptParser
                        ) {
        this.varString = vS;
        this.varFloat = vF;
        this.varInt = vI;
        this.varBool = vB;
        this.parser = pr;
    }

    /**
        Releases resources used by the object.
    **/
    public function kill():Void {
        this.varString = null;
        this.varFloat = null;
        this.varInt = null;
        this.varBool = null;
        this.parser = null;
    }

}