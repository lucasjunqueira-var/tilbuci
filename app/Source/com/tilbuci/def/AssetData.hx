package com.tilbuci.def;

/**
    Asset information.
**/
class AssetData {

    /**
        asset loaded?
    **/
    public var ok:Bool = false;

    /**
        asset name
    **/
    public var name:String;

    /**
        asset type
    **/
    public var type:String;

    /**
        asset time
    **/
    public var time:Int;

    /**
        time finish action
    **/
    public var action:String = '';

    /**
        asset order on collection
    **/
    public var order:Int = 0;

    /**
        number of frames for spritemap
    **/
    public var frames:Int = 1;

    /**
        frame time for spritemap
    **/
    public var frtime:Int = 100;

    /**
        file links
    **/
    public var file:Map<String, String>;

    /**
        Constructor.
        @param  data    information about the asset
    **/
    public function new(data:Dynamic) {
        this.ok = true;
        if (Reflect.hasField(data, 'name')) {
            this.name = Reflect.field(data, 'name');
        } else this.ok = false;
        if (this.ok && Reflect.hasField(data, 'type')) {
            this.type = Reflect.field(data, 'type');
        } else this.ok = false;
        if (this.ok && Reflect.hasField(data, 'order')) {
            this.order = Reflect.field(data, 'order');
        } else this.ok = false;
        if (this.ok && Reflect.hasField(data, 'time')) {
            this.time = Reflect.field(data, 'time');
        } else this.ok = false;
        if (this.ok && Reflect.hasField(data, 'action')) {
            this.action = Reflect.field(data, 'action');
        } else this.ok = false;
        if (this.ok && Reflect.hasField(data, 'frames')) {
            this.frames = Reflect.field(data, 'frames');
        } else this.ok = false;
        if (this.ok && Reflect.hasField(data, 'frtime')) {
            this.frtime = Reflect.field(data, 'frtime');
        } else this.ok = false;
        if (this.ok && Reflect.hasField(data, 'file')) {
            var fl:Dynamic = Reflect.field(data, 'file');
            if (Reflect.hasField(fl, '@1')) {
                this.file = [ ];
                this.file['@1'] = Reflect.field(fl, '@1');
                if (Reflect.hasField(fl, '@2')) {
                    this.file['@2'] = Reflect.field(fl, '@2');
                    if (this.file['@2'] == '') this.file['@2'] = this.file['@1'];
                } else this.file['@2'] = this.file['@1'];
                if (Reflect.hasField(fl, '@3')) {
                    this.file['@3'] = Reflect.field(fl, '@3');
                    if (this.file['@3'] == '') this.file['@3'] = this.file['@2'];
                } else this.file['@3'] = this.file['@2'];
                if (Reflect.hasField(fl, '@4')) {
                    this.file['@4'] = Reflect.field(fl, '@4');
                    if (this.file['@4'] == '') this.file['@4'] = this.file['@3'];
                } else this.file['@4'] = this.file['@3'];
                if (Reflect.hasField(fl, '@5')) {
                    this.file['@5'] = Reflect.field(fl, '@5');
                    if (this.file['@5'] == '') this.file['@5'] = this.file['@4'];
                } else this.file['@5'] = this.file['@4'];
            } else this.ok = false;
            this.time = Reflect.field(data, 'time');
        } else this.ok = false;
    }

    /**
        Release resources used by the object.
    **/
    public function kill():Void {
        this.ok = false;
        this.name = null;
        this.type = null;
        this.action = null;
        this.time = 0;
        for (n in this.file) this.file.remove(n);
        this.file = null;
    }

    /**
        Gets a clen representation of current asset.
    **/
    public function toObject():Dynamic {
        return({
            order: this.order, 
            name: this.name, 
            type: this.type, 
            time: this.time, 
            action: this.action, 
            frames: this.frames, 
            frtime: this.frtime, 
            file: {
                '@1': this.file['@1'], 
                '@2': this.file['@2'], 
                '@3': this.file['@3'], 
                '@4': this.file['@4'], 
                '@5': this.file['@5']
            }
        });
    }

}