package com.tilbuci.def;

class DefBase {

    /**
        requered feilds on loaded maps
    **/
    public var reqFields:Array<String> = [ ];

    /**
        Constructor.
        @param  rq  required fields to look for on map loading
    **/
    public function new(rq:Array<String> = null) {
        if (rq != null) this.reqFields = rq;
    }

    /**
        Checks if the required fields exist on a map.
        @param  data    the map to check
        @return were all feidls found at the map?
    **/
    public function checkFields(data:Map<String, Dynamic>):Bool {
        var ok = true;
        for (n in 0...this.reqFields.length) if (!data.exists(this.reqFields[n])) ok = false;
        return (ok);
    }

    /**
        Releases resources used by the object.
    **/
    public function kill():Void {
        while (this.reqFields.length > 0) this.reqFields.shift();
        this.reqFields = null;
    }

}