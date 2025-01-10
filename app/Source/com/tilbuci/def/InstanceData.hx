package com.tilbuci.def;

/**
    Instance information.
**/
class InstanceData {

    /**
        instance available?
    **/
    public var ok:Bool = true;

    /**
        instance collection
    **/
    public var collection:String;

    /**
        instance asset
    **/
    public var asset:String;

    /**
        instance trigger action
    **/
    public var action:String;

    /**
        start playing after load?
    **/
    public var playOnLoad:Bool = true;

    /**
        horizontal instance description
    **/
    public var horizontal:InstanceDesc;

    /**
        vertical instance description
    **/
    public var vertical:InstanceDesc;

    /**
        Constructor.
        @param  data    information about the instance
    **/
    public function new(data:Dynamic) {
        if (this.ok && Reflect.hasField(data, 'collection')) {
            this.collection = Reflect.field(data, 'collection');
        } else this.ok = false;
        if (this.ok && Reflect.hasField(data, 'asset')) {
            this.asset = Reflect.field(data, 'asset');
        } else this.ok = false;
        if (this.ok && Reflect.hasField(data, 'action')) {
            this.action = Reflect.field(data, 'action');
        } else this.ok = false;
        if (this.ok && Reflect.hasField(data, 'play')) {
            this.playOnLoad = Reflect.field(data, 'play');
        } else this.ok = false;
        if (this.ok && Reflect.hasField(data, 'horizontal')) {
            this.horizontal = new InstanceDesc(Reflect.field(data, 'horizontal'));
        } else this.ok = false;
        if (this.ok && Reflect.hasField(data, 'vertical')) {
            this.vertical = new InstanceDesc(Reflect.field(data, 'vertical'));
        } else this.ok = false;
        if (this.ok) if (!this.horizontal.ok || !this.vertical.ok) this.ok = false;
        if (this.ok) this.asset = this.asset.substr(0, 32);
    }

    /**
        Release resources used by the object.
    **/
    public function kill():Void {
        this.ok = false;
        this.collection = null;
        this.asset = null;
        this.action = null;
        this.horizontal.kill();
        this.horizontal = null;
        this.vertical.kill();
        this.vertical = null;
    }

    /**
        Gets a clean object description of the instance.
    **/
    public function toObject():Dynamic {
        return({
            collection: this.collection, 
            asset: this.asset, 
            action: this.action, 
            play: this.playOnLoad, 
            horizontal: this.horizontal.toObject(), 
            vertical: this.vertical.toObject()
        });
    }

    /**
        Creates a clone of the current object.
    **/
    public function clone():InstanceData {
        return (new InstanceData(this.toObject()));
    }

}

/**
    Instance description.
**/
class InstanceDesc {

    /**
        valid instance description?
    **/
    public var ok:Bool = true;

    /**
        display order
    **/
    public var order:Int;

    /**
        display x
    **/
    public var x:Float;

    /**
        display y
    **/
    public var y:Float;

    /**
        display alpha
    **/
    public var alpha:Float;

    /**
        display width
    **/
    public var width:Float;

    /**
        display height
    **/
    public var height:Float;

    /**
        object rotation
    **/
    public var rotation:Int = 0;

    /**
        object visiblity
    **/
    public var visible:Bool = true;

    /**
        color transformation
    **/
    public var color:String = '0x000000';

    /**
        color alpha transformation
    **/
    public var colorAlpha:Float = 0;

    /**
        sound volume
    **/
    public var volume:Float = 1;

    /**
        sound pan
    **/
    public var pan:Float = 0;

    /**
        blend mode
    **/
    public var blend:String = 'normal';

    /**
        blur filter
    **/
    public var blur:Array<String> = [ ];

    /**
        dropshadow filter
    **/
    public var dropshadow:Array<String> = [ ];

    /**
        glow filter
    **/
    public var glow:Array<String> = [ ];

    /**
        text format font
    **/
    public var textFont:String = '_sans';

    /**
        text format size
    **/
    public var textSize:Int = 12;

    /**
        text format color
    **/
    public var textColor:String = '0xFFFFFF';

    /**
        text format bold
    **/
    public var textBold:Bool = false;

    /**
        text format italic
    **/
    public var textItalic:Bool = false;

    /**
        text format vertical spacing
    **/
    public var textLeading:Int = 0;

    /**
        text format inter char spacing
    **/
    public var textSpacing:Float = 0;

    /**
        text background color (empty for no background)
    **/
    public var textBackground:String = '';

    /**
        text alignment
    **/
    public var textAlign:String = 'left';

    /**
        Constructor.
        @param  data    information about the description
    **/
    public function new(data:Dynamic) {
        if (this.ok && Reflect.hasField(data, 'order')) {
            this.order = Reflect.field(data, 'order');
        } else this.ok = false;
        if (this.ok && Reflect.hasField(data, 'x')) {
            this.x = Reflect.field(data, 'x');
        } else this.ok = false;
        if (this.ok && Reflect.hasField(data, 'y')) {
            this.y = Reflect.field(data, 'y');
        } else this.ok = false;
        if (this.ok && Reflect.hasField(data, 'alpha')) {
            this.alpha = Reflect.field(data, 'alpha');
        } else this.ok = false;
        if (this.ok && Reflect.hasField(data, 'width')) {
            this.width = Reflect.field(data, 'width');
        } else this.ok = false;
        if (this.ok && Reflect.hasField(data, 'height')) {
            this.height = Reflect.field(data, 'height');
        } else this.ok = false;
        if (this.ok && Reflect.hasField(data, 'rotation')) {
            this.rotation = Reflect.field(data, 'rotation');
        } else this.ok = false;
        if (this.ok && Reflect.hasField(data, 'visible')) {
            this.visible = Reflect.field(data, 'visible');
        } else this.ok = false;
        if (this.ok && Reflect.hasField(data, 'color')) {
            this.color = Reflect.field(data, 'color');
        } else this.ok = false;
        if (this.ok && Reflect.hasField(data, 'colorAlpha')) {
            this.colorAlpha = Reflect.field(data, 'colorAlpha');
        } else this.ok = false;
        if (this.ok && Reflect.hasField(data, 'volume')) {
            this.volume = Reflect.field(data, 'volume');
        } else this.ok = false;
        if (this.ok && Reflect.hasField(data, 'pan')) {
            this.pan = Reflect.field(data, 'pan');
        } else this.ok = false;
        if (this.ok && Reflect.hasField(data, 'blur')) {
            this.blur = Reflect.field(data, 'blur').split(';');
            if (this.blur.length != 2) this.blur = [ ];
        } else this.ok = false;
        if (this.ok && Reflect.hasField(data, 'dropshadow')) {
            this.dropshadow = Reflect.field(data, 'dropshadow').split(';');
            if (this.dropshadow.length != 8) this.dropshadow = [ ];
        } else this.ok = false;
        if (this.ok && Reflect.hasField(data, 'textFont')) {
            this.textFont = Reflect.field(data, 'textFont');
        } else this.ok = false;
        if (this.ok && Reflect.hasField(data, 'textSize')) {
            this.textSize = Reflect.field(data, 'textSize');
        } else this.ok = false;
        if (this.ok && Reflect.hasField(data, 'textColor')) {
            this.textColor = Reflect.field(data, 'textColor');
        } else this.ok = false;
        if (this.ok && Reflect.hasField(data, 'textBold')) {
            this.textBold = Reflect.field(data, 'textBold');
        } else this.ok = false;
        if (this.ok && Reflect.hasField(data, 'textItalic')) {
            this.textItalic = Reflect.field(data, 'textItalic');
        } else this.ok = false;
        if (this.ok && Reflect.hasField(data, 'textLeading')) {
            this.textLeading = Reflect.field(data, 'textLeading');
        } else this.ok = false;
        if (this.ok && Reflect.hasField(data, 'textSpacing')) {
            this.textSpacing = Reflect.field(data, 'textSpacing');
        } else this.ok = false;
        if (this.ok && Reflect.hasField(data, 'textBackground')) {
            this.textBackground = Reflect.field(data, 'textBackground');
        } else this.ok = false;
        if (this.ok && Reflect.hasField(data, 'textAlign')) {
            this.textAlign = Reflect.field(data, 'textAlign');
        } else this.ok = false;

        // optional/new properties
        if (this.ok && Reflect.hasField(data, 'glow')) {
            this.glow = Reflect.field(data, 'glow').split(';');
            if (this.glow.length != 5) this.glow = [ ];
        } else {
            this.glow = [ ];
        }
        if (this.ok && Reflect.hasField(data, 'blend')) {
            this.blend = Reflect.field(data, 'blend');
        } else {
            this.blend = 'normal';
        }
    }

    /**
        Releases resources used by the object.
    **/
    public function kill():Void {
        this.ok = false;
        while (this.blur.length > 0) this.blur.shift();
        this.blur = null;
        while (this.dropshadow.length > 0) this.dropshadow.shift();
        this.dropshadow = null;
        while (this.glow.length > 0) this.glow.shift();
        this.glow = null;
        this.color = null;
        this.textFont = null;
        this.textColor = null;
        this.textBackground = null;
        this.textAlign = null;
        this.blend = null;
    }

    /**
        Gets a clean object description of the intance.
    **/
    public function toObject():Dynamic {
        return({
            order: this.order, 
            x: this.x, 
            y: this.y, 
            alpha: this.alpha, 
            width: this.width, 
            height: this.height, 
            rotation: this.rotation, 
            visible: this.visible, 
            color: this.color, 
            colorAlpha: this.colorAlpha, 
            volume: this.volume, 
            pan: this.pan, 
            blur: this.blur.join(';'), 
            dropshadow: this.dropshadow.join(';'), 
            glow: this.glow.join(';'), 
            blend: this.blend, 
            textFont: this.textFont, 
            textSize: this.textSize, 
            textColor: this.textColor, 
            textBold: this.textBold, 
            textItalic: this.textItalic, 
            textLeading: this.textLeading, 
            textSpacing: this.textSpacing, 
            textBackground: this.textBackground, 
            textAlign: this.textAlign, 
        });
    }

}