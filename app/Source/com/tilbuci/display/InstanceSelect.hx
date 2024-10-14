package com.tilbuci.display;

import com.tilbuci.def.InstanceData;
import com.tilbuci.def.InstanceData.InstanceDesc;
import openfl.display.Stage;
import com.tilbuci.data.GlobalPlayer;
import openfl.geom.Point;
import openfl.events.MouseEvent;
import openfl.display.Shape;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.Sprite;
import com.tilbuci.data.Global;
import motion.Actuate;
import openfl.filters.BlurFilter;
import openfl.filters.DropShadowFilter;

class InstanceSelect extends Sprite {

    /**
        selected instance
    **/
    public var image:InstanceImage;

    /**
        move icon
    **/
    private var _move:Sprite;

    /**
        horizontal resize icon
    **/
    private var _resizeH:Sprite;

    /**
        vertical resize icon
    **/
    private var _resizeV:Sprite;

    /**
        proportional resize icon
    **/
    private var _resize:Sprite;

    /**
        display borders
    **/
    private var _borders:Shape;

    /**
        minimum values for icon interaction
    **/
    private var _limits:Point;

    /**
        stage reference values
    **/
    private var _stagepos:Point;

    /**
        current update property
    **/
    private var _updating:String = '';

    /**
        reference to the display stage
    **/
    private var stg:Stage;

    public function new() {
        super();

        this._borders = new Shape();
        this.addChild(this._borders);

        this._move = new Sprite();
        var mvIcon:Bitmap = new Bitmap();
        #if !tilbuciplayer
            mvIcon = new Bitmap(Assets.getBitmapData('iconMove'));
            mvIcon.smoothing = true;
            this._move.addChild(mvIcon);
        #end
        this.addChild(this._move);

        this._resizeH = new Sprite();
        #if !tilbuciplayer
            var iconResizeH:Bitmap = new Bitmap(Assets.getBitmapData('iconResizeH'));
            iconResizeH.smoothing = true;
            this._resizeH.addChild(iconResizeH);
        #end
        this.addChild(this._resizeH);

        this._resizeV = new Sprite();
        #if !tilbuciplayer
            var iconResizeV:Bitmap = new Bitmap(Assets.getBitmapData('iconResizeV'));
            iconResizeV.smoothing = true;
            this._resizeV.addChild(iconResizeV);
        #end
        this.addChild(this._resizeV);

        this._resize = new Sprite();
        #if !tilbuciplayer
            var iconResize:Bitmap = new Bitmap(Assets.getBitmapData('iconResize'));
            iconResize.smoothing = true;
            this._resize.addChild(iconResize);
        #end
        this.addChild(this._resize);

        #if !tilbuciplayer
            this._limits = new Point((3 * mvIcon.width), (3 * mvIcon.height));
        #end
        this._stagepos = new Point();

        this.visible = false;
    }

    /**
        Sets the current slected instance.
        @param  inst    the instance to select
    **/
    public function setInstance(inst:InstanceImage):Void {
        this.image = inst;
        this.place();
        this.visible = true;
        this._move.addEventListener(MouseEvent.MOUSE_DOWN, onMoveStart);
        this._resizeH.addEventListener(MouseEvent.MOUSE_DOWN, onResizeHStart);
        this._resizeV.addEventListener(MouseEvent.MOUSE_DOWN, onResizeVStart);
        this._resize.addEventListener(MouseEvent.MOUSE_DOWN, onResizeStart);
    }

    /**
        Removes selected instance.
    **/
    public function clearInstance():Void {
        this.image = null;
        this.visible = false;
        this.x = this.y = 0;
        if (this._move.hasEventListener(MouseEvent.MOUSE_DOWN)) try { this._move.removeEventListener(MouseEvent.MOUSE_DOWN, onMoveStart); } catch (e) { }
        if (this._resizeH.hasEventListener(MouseEvent.MOUSE_DOWN)) try { this._resizeH.removeEventListener(MouseEvent.MOUSE_DOWN, onResizeHStart); } catch (e) { }
        if (this._resizeV.hasEventListener(MouseEvent.MOUSE_DOWN)) try { this._resizeV.removeEventListener(MouseEvent.MOUSE_DOWN, onResizeVStart); } catch (e) { }
        if (this._resize.hasEventListener(MouseEvent.MOUSE_DOWN)) try { this._resize.removeEventListener(MouseEvent.MOUSE_DOWN, onResizeStart); } catch (e) { }
        if ((this.stg != null) && this.stg.hasEventListener(MouseEvent.MOUSE_MOVE)) {
            try { this.stg.removeEventListener(MouseEvent.MOUSE_MOVE, onMove); } catch (e) { }
            this.stg = null;
        }
    }

    public function setAsPrecache():Void {
        this.image.x = GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][this.image.getInstName()].horizontal.x = -100;
        this.image.y = GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][this.image.getInstName()].horizontal.y = -100;
        this.image.width = GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][this.image.getInstName()].horizontal.width = 5;
        this.image.height = GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][this.image.getInstName()].horizontal.height = 5;
        this.image.alpha = GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][this.image.getInstName()].horizontal.alpha = 0;
        GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][this.image.getInstName()].horizontal.volume = 0;
        this.image.setSound(0);
        this.image.visible = GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][this.image.getInstName()].horizontal.visible = false;
        GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][this.image.getInstName()].vertical.x = -100;
        GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][this.image.getInstName()].vertical.y = -100;
        GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][this.image.getInstName()].vertical.width = 5;
        GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][this.image.getInstName()].vertical.height = 5;
        GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][this.image.getInstName()].vertical.alpha = 0;
        GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][this.image.getInstName()].vertical.volume = 0;
        GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][this.image.getInstName()].vertical.visible = false;
        GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][this.image.getInstName()].playOnLoad = false;
        this.place();
    }

    public function setCurrentNum(name:String, val:Float):Void {
        var desc:InstanceDesc;
        if (Global.displayType == 'portrait') {
            desc = GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][this.image.getInstName()].vertical;
        } else {
            desc = GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][this.image.getInstName()].horizontal;
        }
        switch (name) {
            case 'x': desc.x = this.image.x = val;
            case 'y': desc.y = this.image.y = val;
            case 'width': 
                desc.width = val;
                var newval:Float = val;
                if ((this.image.transition == 'right') || (this.image.transition == 'left')) newval = val * 2;
                if ((this.image.currentType == 'paragraph') || (this.image.currentType == 'html')) {
                    this.image.setTextSize(newval, this.image.height);
                    this.image.width = newval;
                } else {
                    this.image.width = newval;
                }
            case 'height':
                desc.height = val;
                var newval:Float = val;
                if ((this.image.transition == 'top') || (this.image.transition == 'bottom')) newval = val * 2;
                if ((this.image.currentType == 'paragraph') || (this.image.currentType == 'html')) {
                    this.image.setTextSize(this.image.width, newval);
                    this.image.height = newval;
                } else {
                    this.image.height = newval;
                }
            case 'rotation': 
                desc.rotation = Math.round(val); this.image.rotation = val;
            case 'alpha':
                desc.alpha = this.image.alpha = val;
            case 'coloralpha':
                desc.colorAlpha = val;
                Actuate.transform(this.image, 0.01).color(Std.parseInt(desc.color), desc.colorAlpha);
            case 'volume':
                desc.volume = val;
                this.image.setSound(val);
            case 'textsize':
                desc.textSize = Math.round(val);
            case 'textspacing':
                desc.textSpacing = val;
            case 'textleading':
                desc.textLeading = Math.round(val);
        }
        this.place();
    }

    public function setCurrentStr(name:String, val:String):Void {
        var desc:InstanceDesc;
        if (Global.displayType == 'portrait') {
            desc = GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][this.image.getInstName()].vertical;
        } else {
            desc = GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][this.image.getInstName()].horizontal;
        }
        switch (name) {
            case 'color':
                desc.color = val;
                Actuate.stop(this.image, null, true);
                Actuate.transform(this.image, 0.01).color(Std.parseInt(desc.color), desc.colorAlpha);
            case 'textfont':
                desc.textFont = val;
            case 'textcolor':
                desc.textColor = val;
            case 'textalign':
                desc.textAlign = val;
            case 'textbackground':
                desc.textBackground = val;
            case 'instance':
                var oldid:String = this.image.getInstName();
                if (GlobalPlayer.area.swapInstance(this.image.getInstName(), val)) {
                    var dt:InstanceData = GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][oldid];
                    GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf].remove(oldid);
                    GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][val] = dt;
                }
            case 'asset':
                var asinfo:Array<String> = val.split('|:|');
                GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][this.image.getInstName()].collection = asinfo[0];
                GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][this.image.getInstName()].asset = asinfo[1];
                this.image.load(GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][this.image.getInstName()]);

        }
        this.place();
    }

    public function setCurrentBool(name:String, val:Bool):Void {
        var desc:InstanceDesc;
        if (Global.displayType == 'portrait') {
            desc = GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][this.image.getInstName()].vertical;
        } else {
            desc = GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][this.image.getInstName()].horizontal;
        }
        switch (name) {
            case 'textbold':
                desc.textBold = val;
            case 'textitalic':
                desc.textItalic = val;
            case 'blur':
                if (!val) {
                    desc.blur = [ ];
                }
            case 'dropshadow':
                if (!val) {
                    desc.dropshadow = [ ];
                }
            case 'visible':
                desc.visible = this.image.visible = val;
        }
        // apply filters?
        if ((name == 'blur') || (name == 'dropshadow')) {
            this.image.filters = [ ];
            if (desc.dropshadow.length == 8) {
                if (desc.blur.length == 2) {
                    this.image.filters = [ new DropShadowFilter(
                        Std.parseInt(desc.dropshadow[0]), 
                            Std.parseFloat(desc.dropshadow[1]), 
                            Std.parseInt(desc.dropshadow[2]), 
                            Std.parseFloat(desc.dropshadow[3]), 
                            Std.parseFloat(desc.dropshadow[4]), 
                            Std.parseFloat(desc.dropshadow[5]), 
                            Std.parseFloat(desc.dropshadow[6]), 
                            1, 
                            desc.dropshadow[7] == '1'
                    ), new BlurFilter(
                        Std.parseFloat(desc.blur[0]), 
                        Std.parseFloat(desc.blur[1])
                    ) ];
                } else {
                    this.image.filters = [ new DropShadowFilter(
                        Std.parseInt(desc.dropshadow[0]), 
                            Std.parseFloat(desc.dropshadow[1]), 
                            Std.parseInt(desc.dropshadow[2]), 
                            Std.parseFloat(desc.dropshadow[3]), 
                            Std.parseFloat(desc.dropshadow[4]), 
                            Std.parseFloat(desc.dropshadow[5]), 
                            Std.parseFloat(desc.dropshadow[6]), 
                            1, 
                            desc.dropshadow[7] == '1'
                    ) ];
                }
            } else {
                if (desc.blur.length == 2) {
                    this.image.filters = [ new BlurFilter(
                        Std.parseFloat(desc.blur[0]), 
                        Std.parseFloat(desc.blur[1])
                    ) ];
                }
            }
        }
        this.place();
    }

    public function setCurrentArray(name:String, val:Array<String>):Void {
        var desc:InstanceDesc;
        if (Global.displayType == 'portrait') {
            desc = GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][this.image.getInstName()].vertical;
        } else {
            desc = GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][this.image.getInstName()].horizontal;
        }
        switch (name) {
            case 'blur':
                if (val.length == 2) {
                    desc.blur = val;
                } else {
                    desc.blur = [ ];
                }
            case 'dropshadow':
                if (val.length == 8) {
                    desc.dropshadow = val;
                } else {
                    desc.dropshadow = [ ];
                }
        }
        this.place();
    }

    public function applyText():Void {
        var desc:InstanceDesc;
        if (Global.displayType == 'portrait') {
            desc = GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][this.image.getInstName()].vertical;
        } else {
            desc = GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][this.image.getInstName()].horizontal;
        }
        this.image.formatText(desc.textFont, desc.textSize, desc.textColor, desc.textBold, desc.textItalic, desc.textLeading, desc.textSpacing, desc.textBackground, desc.textAlign);
    }

    /**
        Places the select interface.
    **/
    public function place():Void {
        if (this.image != null) {
            this.x = this.image.x;
            this.y = this.image.y;
            this._borders.graphics.clear();
            this._borders.graphics.lineStyle(2, 0x000000);
            this._borders.graphics.drawRect(0, 0, this.image.displayWidth, this.image.displayHeight);
            this._borders.graphics.lineStyle(2, 0xFFFFFF);
            this._borders.graphics.drawRect(2, 2, (this.image.displayWidth - 4), (this.image.displayHeight - 4));
            this.rotation = this.image.rotation;
            if ((this.image.displayWidth <= this._limits.x) || (this.image.displayHeight <= this._limits.y)) {
                // this._move.visible = false;
                this._move.visible = true;
                this._resizeH.visible = false;
                this._resizeV.visible = false;
                this._resize.visible = false;
            } else {
                this._move.visible = true;
                this._resizeH.visible = true;
                this._resizeV.visible = true;
                this._resize.visible = true;
                this._resizeH.x = this.image.displayWidth - this._resizeH.width;
                this._resizeH.y = (this.image.displayHeight - this._resizeH.height) / 2;
                this._resizeV.y = this.image.displayHeight - this._resizeH.height;
                this._resizeV.x = (this.image.displayWidth - this._resizeH.width) / 2;
                this._resize.x = this.image.displayWidth - this._resize.width;
                this._resize.y = this.image.displayHeight - this._resize.height;
            }
        }
    }

    /**
        Ends properties adjust.
    **/
    public function endPropSet():Void {
        if (this.image != null) {
            switch (this._updating) {
                case 'move':
                    this.image.finishDrag();
            }
            this._updating = '';
            this.place();
            if ((this.stg != null) && this.stg.hasEventListener(MouseEvent.MOUSE_MOVE)) {
                this.stg.removeEventListener(MouseEvent.MOUSE_MOVE, onMove);
                this.stg = null;
            }
            this.image.updateInstance();
        }
    }

    /**
        Starting image dragging.
    **/
    private function onMoveStart(evt:MouseEvent):Void {
        if (this.image != null) {
            if (Global.history.states.length == 0) Global.history.addState(Global.ln.get('rightbar-history-original'));
            this._updating = 'move';
            this.image.dragImageStart();
            this.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMove);
        }
    }

    /**
        Starting image horizontal resize.
    **/
    private function onResizeHStart(evt:MouseEvent):Void {
        if (this.image != null) {
            if (Global.history.states.length == 0) Global.history.addState(Global.ln.get('rightbar-history-original'));
            this._updating = 'resizeh';
            this._stagepos.x = this.getBounds(this.stage).x;
            this._stagepos.y = this.image.width / this.getBounds(this.stage).width;
            this.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMove);
        }
    }

    /**
        Starting image vertical resize.
    **/
    private function onResizeVStart(evt:MouseEvent):Void {
        if (this.image != null) {
            if (Global.history.states.length == 0) Global.history.addState(Global.ln.get('rightbar-history-original'));
            this._updating = 'resizev';
            this._stagepos.x = this.getBounds(this.stage).y;
            this._stagepos.y = this.image.height / this.getBounds(this.stage).height;
            this.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMove);
        }
    }

    /**
        Starting image proportional resize.
    **/
    private function onResizeStart(evt:MouseEvent):Void {
        if (this.image != null) {
            if (Global.history.states.length == 0) Global.history.addState(Global.ln.get('rightbar-history-original'));
            this._updating = 'resize';
            this._stagepos.x = this.getBounds(this.stage).y;
            this._stagepos.y = this.image.height / this.getBounds(this.stage).height;
            this.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMove);
            this.stg = this.stage;
        }
    }

    /**
        Mouse move during property update.
    **/
    private function onMove(evt:MouseEvent):Void {
        if (this.image != null) {
            switch (this._updating) {
                case 'move':
                    this.x = this.image.x;
                    this.y = this.image.y;
                case 'resizeh':
                    var wd:Float = (evt.stageX - this._stagepos.x) * this._stagepos.y;
                    if (wd > this._limits.x) {
                        var newval:Float = wd;
                        if ((this.image.transition == 'right') || (this.image.transition == 'left')) newval = wd * 2;
                        if ((this.image.currentType == 'paragraph') || (this.image.currentType == 'html')) {
                            this.image.setTextSize(newval, this.image.height);
                        }
                        this.image.width = wd;
                        this.image.setDescWidth(newval);
                        this.place();
                    }
                case 'resizev':
                    var ht:Float = (evt.stageY - this._stagepos.x) * this._stagepos.y;
                    if (ht > this._limits.y) {
                        var newval:Float = ht;
                        if ((this.image.transition == 'top') || (this.image.transition == 'bottom')) newval = ht / 2;
                        if ((this.image.currentType == 'paragraph') || (this.image.currentType == 'html')) {
                            this.image.setTextSize(this.image.width, newval);
                        }
                        this.image.height = ht;
                        this.image.setDescHeight(newval);
                        this.place();
                    }
                case 'resize':
                    var wd:Float = (evt.stageX - this._stagepos.x) * this._stagepos.y;
                    var ht:Float = wd * this.image.oHeight() / this.image.oWidth();
                    if ((wd > this._limits.x) && (ht > this._limits.y)) {
                        var newval:Float = wd;
                        if ((this.image.transition == 'right') || (this.image.transition == 'left')) newval = wd * 2;
                        if ((this.image.currentType == 'paragraph') || (this.image.currentType == 'html')) {
                            this.image.setTextSize(newval, this.image.height);
                        }
                        this.image.width = wd;
                        this.image.setDescWidth(newval);
                        newval = ht;
                        if ((this.image.transition == 'top') || (this.image.transition == 'bottom')) newval = ht / 2;
                        if ((this.image.currentType == 'paragraph') || (this.image.currentType == 'html')) {
                            this.image.setTextSize(this.image.width, newval);
                        }
                        this.image.height = ht;
                        this.image.setDescHeight(newval);
                        this.place();
                    }
            }
        }
    }

}