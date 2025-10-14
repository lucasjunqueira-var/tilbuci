/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.player;

/** OPENFL **/
import com.tilbuci.display.InstanceSelect;
import openfl.events.MouseEvent;
import com.tilbuci.ui.PlayerInput;
import feathers.text.TextFormat;
import feathers.layout.VerticalLayout;
import feathers.layout.AnchorLayout;
import feathers.controls.TextInput;
import feathers.core.FeathersControl;
import feathers.events.TriggerEvent;
import openfl.display.Bitmap;
import openfl.events.Event;
import openfl.display.Shape;
import openfl.display.Sprite;
import openfl.Assets;
import openfl.display.LineScaleMode;
import openfl.display.JointStyle;

/** ACTUATE **/
import motion.easing.Cubic;
import motion.easing.Bounce;
import motion.easing.Linear;
import motion.easing.Sine;
import motion.easing.Quint;
import motion.easing.Quart;
import motion.easing.Quad;
import motion.easing.Expo;
import motion.easing.Elastic;
import motion.Actuate;

/** FEATHERS UI **/
import feathers.controls.Header;
import feathers.controls.Panel;
import feathers.controls.Button;
import feathers.layout.HorizontalLayout;
import feathers.controls.LayoutGroup;

/** TILBUCI **/
import com.tilbuci.def.InstanceData;
import com.tilbuci.display.InstanceImage;
import com.tilbuci.data.GlobalPlayer;
import com.tilbuci.ui.PlayerInput;
import com.tilbuci.data.Global;

class MovieArea extends Sprite {

    /**
        vertical area orientation
    **/
    public static inline var VORIENTATION:String = 'vertical';

    /**
        horizontal area orientation
    **/
    public static inline var HORIENTATION:String = 'horizontal';

    /**
        square area orientation
    **/
    public static inline var SORIENTATION:String = 'square';

    /**
        area width
    **/
    public var aWidth(get, null):Float;
    private function get_aWidth():Float { return (this._mask.width); }

    /**
        area height
    **/
    public var aHeight(get, null):Float;
    private function get_aHeight():Float { return (this._mask.height); }

    /**
        area orientation
    **/
    public var aOrientation(get, null):String;
    private function get_aOrientation():String {
        if (this.aWidth == this.aHeight) {
            return (MovieArea.SORIENTATION);
        } else if (this.aHeight > this.aWidth) {
            return (MovieArea.VORIENTATION);
        } else {
            return (MovieArea.HORIENTATION);
        }
    }

    /**
        player orientation
    **/
    public var pOrientation(get, null):String;
    private function get_pOrientation():String {
        if (this._player.rWidth < this._player.rHeight) {
            return (MovieArea.VORIENTATION);
        } else {
            return (MovieArea.HORIENTATION);
        }
    }

    /**
        scene playing?
    **/
    public var playing(get, null):Bool;
    private var _playing:Bool = true;
    private function get_playing():Bool { return (this._playing); }

    /**
        keyframe to load on play event
    **/
    private var _kftoLoad:Int = -1;

    /**
        the player reference
    **/
    private var _player:Player;

    /**
        the player background reference
    **/
    private var _bgarea:Sprite;

    /**
        display area holder
    **/
    private var _holder:Sprite;

    /**
        display area mask
    **/
    private var _mask:Shape;

    /**
        scene display area
    **/
    private var _scene:Sprite;

    /**
        input area
    **/
    private var _inputArea:Sprite;

    /**
        display area above the scene
    **/
    private var _overlay:Sprite;

    /**
        registered overlays
    **/
    private var _overlays:Map<String, Sprite> = [ ];

    /**
        display area below the scene
    **/
    private var _bloverlay:Sprite;

    /**
        registered overlays below content
    **/
    private var _bloverlays:Map<String, Sprite> = [ ];

    /**
        movie background
    **/
    private var _bg:Shape;

    /**
        current movie display scale
    **/
    private var _scale:Float = 1;

    /**
        current instances
    **/
    private var _instances:Map<String, InstanceImage> = [ ];

    /**
        current keyframe
    **/
    public var currentKf(get, null):Int;
    private function get_currentKf():Int { return (this._currentKf); }
    private var _currentKf:Int = -1;

    /**
        current keyframe animagion completion
    **/
    public var kfPercent:Float = 0;

    /**
        user interface area
    **/
    private var _uiArea:Sprite;

    /**
        user interface area background
    **/
    private var _uiBg:Shape;

    /**
        input panel area
    **/
    private var _inputPanel:PlayerInput;

    /**
        image selection display (for editor)
    **/
    private var _select:InstanceSelect;

    /**
        interaction target
    **/
    private var _target:Target = new Target();

    /**
        Creator.
        @param  pl   a reference to the player
        @param  bgarea  a reference to the player background
    **/
    public function new(pl:Player, bgarea:Sprite, uiArea:Sprite) {
        super();
        this._player = pl;
        this._bgarea = bgarea;
        this._bg = new Shape();
        this._scene = new Sprite();
        this._inputArea = new Sprite();
        this._player.inputArea = this._inputArea;
        this._mask = new Shape();
        this._holder = new Sprite();
        this._overlay = new Sprite();
        this._bloverlay = new Sprite();
        this._uiBg = new Shape();
        this._uiBg.graphics.beginFill(0, 0.5);
        this._uiBg.graphics.drawRect(0, 0, 32, 32);
        this._uiBg.graphics.endFill();
        this._uiBg.visible = false;
        this._uiArea = uiArea;
        this._uiArea.addChild(this._uiBg);
        this._inputPanel = new PlayerInput(this._uiBg);
        this._uiArea.addChild(this._inputPanel);
        this._holder.addChild(this._bg);
        this._holder.addChild(this._bloverlay);
        this._holder.addChild(this._scene);
        this._holder.addChild(this._inputArea);
        this._holder.addChild(this._overlay);

        //this._holder.addChild(this._target);

        this.addChild(this._holder);
        this.addChild(this._mask);
        if (GlobalPlayer.mode == Player.MODE_PLAYER) {
            this._holder.mask = this._mask;
        } else {
            this._mask.visible = false;
        }
        // imagem drag setup
        if (this.stage == null) {
            this.addEventListener(Event.ADDED_TO_STAGE, onStage);
        } else {
            this.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        }
        // editor
        this._select = new InstanceSelect();
        this.addChild(this._select);
    }

    public function showTarget():Void {
        this._holder.addChild(this._target);
        this._target.show();
    }

    public function hideTarget():Void {
        if (this._target.parent != null) this._holder.removeChild(this._target);
        this._target.hide();
    }

    public function toggleTarget():Void {
        if (this._target.visible) {
            this.hideTarget();
        } else {
            this.showTarget();
        }
    }

    public function clearTarget():Void {
        this._target.clear();
    }

    public function moveTarget(to:String):Void {
        switch (to) {
            case 'up':
                if (this._target.y > 0) this._target.y -= GlobalPlayer.usingTarget;
            case 'down':
                if (this._target.y < GlobalPlayer.area.aHeight) this._target.y += GlobalPlayer.usingTarget;
            case 'left':
                if (this._target.x > 0) this._target.x -= GlobalPlayer.usingTarget;
            case 'right':
                if (this._target.x < GlobalPlayer.area.aWidth) this._target.x += GlobalPlayer.usingTarget;
        }
    }

    public function setTargetPos(x:Float, y:Float):Void {
        if (!this._target.visible) this.showTarget();
        this._target.x = x;
        this._target.y = y;
    }

    public function triggerTarget():Void {
        if (GlobalPlayer.contraptions.usingMenu) {
            // check menu buttons
            GlobalPlayer.contraptions.checkMenuCollision(this._target);
        } else {
            // check interfaces
            if (!GlobalPlayer.contraptions.checkInterfaceCollision(this._target)) {
                // check instances
                var inst:InstanceImage;
                var found:InstanceImage = null;
                for (i in 0...this._scene.numChildren) {
                    inst = cast this._scene.getChildAt(i);
                    if (inst != null) {
                        if (inst.visible) {
                            if (this._target.hitTestObject(inst)) {
                                found = inst;
                            }
                        }
                    }
                }
                if (found != null) found.onClick();
            }
        }
    }

    /**
        Loads a kieyframe and start the interpolation animaton.
        @param  kf  keyframe information
        @param  num keyframe index
    **/
    public function loadKeyframe(kf:Map<String, InstanceData>, num:Int):Void {
        // scene paused? play it!
        if (!this._playing && GlobalPlayer.mode != Player.MODE_EDITOR) {
            this.playPause();
        }
        Actuate.stop(this, { kfPercent: 100 }, false, false);
        this._select.clearInstance();
        this._currentKf = num;
        for (i in this._instances.keys()) {
            if (!this._instances[i].keep) {
                this._scene.removeChild(this._instances[i]);
                this._instances[i].stop();
                this._instances[i].kill();
                this._instances.remove(i);
            } else {
                this._instances[i].keep = false;
            }
        }
        for (i in kf.keys()) {
            if (!this._instances.exists(i)) {
                this._instances[i] = new InstanceImage(i, this.imgSelect);
                this._instances[i].load(kf[i]);
                this._instances[i].visible = false;
                this._scene.addChild(this._instances[i]);
            } else {
                this._instances[i].keep = true;
                this._instances[i].load(kf[i]);
            }
        }
        for (i in this._instances.keys()) {
            this._instances[i].place();
        }
        // editor? 
        if (GlobalPlayer.mode == Player.MODE_EDITOR) {
            for (i in this._instances.keys()) {
                if (!this._instances[i].keep) {
                    this._scene.removeChild(this._instances[i]);
                    this._instances[i].kill();
                    this._instances.remove(i);
                } else {
                    this._instances[i].stop();
                }
            }
        }
        if (GlobalPlayer.mode != Player.MODE_EDITOR) {
            this.kfPercent = 0;
            Actuate.tween(this, GlobalPlayer.mdata.time, { kfPercent: 100 }).onComplete(nextKeyframe);
        } else {
            this.kfPercent = 100;
        }
        // warn plugins
        for (p in GlobalPlayer.plugins) {
            if (p.ready) p.info.onNewKeyframe(num);
        }
        // callback
        if (GlobalPlayer.callback != null) {
            GlobalPlayer.callback('loadkeyframe', ['kf' => this.currentKf]);
        }
    }

    /**
        Selects an imagem.
        @param  nm  image instance name
    **/
    public function imgSelect(nm:String = null):Void {
        this._select.clearInstance();
        for (i in this._instances.keys()) {
            if (nm == null) {
                this._instances[i].selected = false;
            } else {
                if (i == nm) {
                    this._instances[i].selected = true;
                    this._select.setInstance(this._instances[i]);
                } else {
                    this._instances[i].selected = false;
                }
            }
        }
    }

    public function setCurrentPrecache():Void {
        this._select.setAsPrecache();
    }

    public function setCurrentNum(name:String, val:Float):Void {
        this._select.setCurrentNum(name, val);
    }

    public function setCurrentStr(name:String, val:String):Void {
        this._select.setCurrentStr(name, val);
    }

    public function setCurrentBool(name:String, val:Bool):Void {
        this._select.setCurrentBool(name, val);
    }

    public function setCurrentArray(name:String, val:Array<String>):Void {
        this._select.setCurrentArray(name, val);
    }

    public function applyText():Void {
        this._select.applyText();
    }

    /**
        Increases current image order.
    **/
    public function orderUp():Void {
        if (this._select.image != null) {
            var tot:Int = 0;
            for (n in this._instances) tot++;
            if (this._select.image.getOrder() < (tot-1)) {
                this._select.image.setOrder(this._select.image.getOrder() + 1);
                this.updateOrder();
            }
        }
    }

    /**
        Decreases current image order.
    **/
    public function orderDown():Void {
        if (this._select.image != null) {
            if (this._select.image.getOrder() > 0) {
                this._select.image.setOrder(this._select.image.getOrder() - 1);
                this.updateOrder();
            }
        }
    }

    /**
        Updates the order index of all imagens.
    **/
    public function updateOrder():Void {
        for (imk in this._instances.keys()) {
            this._instances[imk].setOrder(this._scene.getChildIndex(this._instances[imk]), false);
        }
        var hord:Array<String> = [ ];
        var vord:Array<String> = [ ];
        for (i in GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf].keys()) {
            var inst:InstanceData = GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][i];
            while (hord.length < (inst.horizontal.order + 1)) hord.push('');
            if (hord[inst.horizontal.order] == '') {
                hord[inst.horizontal.order] = i;
            } else {
                hord.insert(inst.horizontal.order, i);
            }
            while (vord.length < (inst.vertical.order + 1)) vord.push('');
            if (vord[inst.vertical.order] == '') {
                vord[inst.vertical.order] = i;
            } else {
                vord.insert(inst.vertical.order, i);
            }
        }
        var hind = 0;
        for (ih in 0...hord.length) {
            if (hord[ih] != '') {
                GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][hord[ih]].horizontal.order = hind;
                hind++;
            }
        }
        var vind = 0;
        for (iv in 0...vord.length) {
            if (vord[iv] != '') {
                GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][vord[iv]].vertical.order = vind;
                vind++;
            }
        }
    }

    /**
        Removes an instance form the current keyframe.
        @param  name    the instance name
        @param  clearhist   clear the history before removing?
        @return was the instance found and removed?
    **/
    public function removeInstance(name:String, clearhist:Bool = false):Bool {
        if (this._instances.exists(name) && GlobalPlayer.movie.scene.keyframes[this._currentKf].exists(name)) {
            if (clearhist) Global.history.clear();
            Global.history.addState(Global.ln.get('rightbar-history-removeinst'));
            this._scene.removeChild(this._instances[name]);
            this._instances.remove(name);
            GlobalPlayer.movie.scene.keyframes[this._currentKf].remove(name);
            this.updateOrder();
            return (true);
        } else {
            return (false);
        }
    }

    /**
        Movie area stage is available.
    **/
    private function onStage(evt:Event):Void {
        this.removeEventListener(Event.ADDED_TO_STAGE, onStage);
        this.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
    }

    /**
        Mouse released.
    **/
    private function onMouseUp(evt:MouseEvent):Void {
        if (GlobalPlayer.mode == Player.MODE_EDITOR) {
            // looks for slected image
            if (this._select.image != null) {
                this._select.endPropSet();
            }
        }
    }

    /**
        Starts loading the next keyframe.
    **/
    private function nextKeyframe():Void {
        // end of keyframe actions
        if (GlobalPlayer.movie.scene.ackeyframes.length > this._currentKf) {
            if (GlobalPlayer.movie.scene.ackeyframes[this._currentKf] != '') {
                GlobalPlayer.parser.run(GlobalPlayer.movie.scene.ackeyframes[this._currentKf]);
            }
        }
        // load next keyframe?
        if (!GlobalPlayer.movie.scene.staticsc) {
            this._currentKf++;
            if (this._currentKf >= GlobalPlayer.movie.scene.keyframes.length) this._currentKf = GlobalPlayer.movie.scene.loop;
            this._kftoLoad = this._currentKf;
            // playing?
            if (this._playing) {
                this._kftoLoad = -1;
                this.loadKeyframe(GlobalPlayer.movie.scene.keyframes[this._currentKf], this._currentKf);
            }
        } else {
            this._playing = false;
        }
    }

    /**
        Plays/pauses the current scene.
    **/
    public function playPause():Void {
        if (this._playing) {
            // pausing all interpolations
            Actuate.pauseAll();
            this._playing = false;
        } else {
            // resume interpolations
            Actuate.resumeAll();
            // paused between two keyframes? load the next one
            if (this._kftoLoad >= 0) {
                // load next keyframe
                this._kftoLoad = -1;
                this.loadKeyframe(GlobalPlayer.movie.scene.keyframes[this._currentKf], this._currentKf);
            }
            this._playing = true;
        }
    }

    /**
        Plays the current scene.
    **/
    public function play():Void {
        if (!this._playing) {
            // resume interpolations?
            if (GlobalPlayer.mode != Player.MODE_EDPLAYERWAIT) {
                Actuate.resumeAll();
            } else {
                this._currentKf++;
                if (this._currentKf >= GlobalPlayer.movie.scene.keyframes.length) this._currentKf = GlobalPlayer.movie.scene.loop;
                this._kftoLoad = this._currentKf;
                GlobalPlayer.mode = Player.MODE_EDPLAYER;
            }
            // paused between two keyframes? load the next one
            if (this._kftoLoad >= 0) {
                // load next keyframe
                this._kftoLoad = -1;
                this.loadKeyframe(GlobalPlayer.movie.scene.keyframes[this._currentKf], this._currentKf);
            }
            // play on load?
            for (k in this._instances.keys()) {
                if (this._instances[k].playOnLoad()) this._instances[k].play();
            }
            this._playing = true;
        }
    }

    /**
        Pauses the current scene.
    **/
    public function pause():Void {
        if (this._playing) {
            // pausing all interpolations
            Actuate.pauseAll();
            this._playing = false;
            for (k in this._instances.keys()) this._instances[k].pause();
        }
    }

    /**
        Plays/pauses an instance.
        @param  name    the instance name
        @return was the instance found?
    **/
    public function playPauseInstance(name:String):Bool {
        if (this._instances.exists(name)) {
            this._instances[name].playPause();
            return (true);
        } else {
            return (false);
        }
    }

    /**
        Plays an instance.
        @param  name    the instance name
        @return was the instance found?
    **/
    public function playInstance(name:String):Bool {
        if (this._instances.exists(name)) {
            this._instances[name].play();
            return (true);
        } else {
            return (false);
        }
    }

    /**
        Pauses an instance.
        @param  name    the instance name
        @return was the instance found?
    **/
    public function pauseInstance(name:String):Bool {
        if (this._instances.exists(name)) {
            this._instances[name].pause();
            return (true);
        } else {
            return (false);
        }
    }

    /**
        Stops an instance.
        @param  name    the instance name
        @return was the instance found?
    **/
    public function stopInstance(name:String):Bool {
        if (this._instances.exists(name)) {
            this._instances[name].stop();
            return (true);
        } else {
            return (false);
        }
    }

    /**
        Checks for an intance play state.
        @param  name    the instance name
        @return was the instance found and it it playing?
    **/
    public function instancePlaying(name:String):Bool {
        if (this._instances.exists(name)) {
            return (this._instances[name].playing);
        } else {
            return (false);
        }
    }

    /**
        Sets the media playback position.
        @param  time    the time to jump to (seconds)
        @return was the instance found?
    **/
    public function instanceSeek(name:String, time:Int):Bool {
        if (this._instances.exists(name)) {
            this._instances[name].seek(time);
            return (true);
        } else {
            return (false);
        }
    }

    /**
        Gets an instance reference.
        @param  name    the instance name
        @return the instance object or null if not found
    **/
    public function instanceRef(name:String):InstanceImage {
        if (this._instances.exists(name)) {
            return (this._instances[name]);
        } else {
            return (null);
        }
    }

    /**
        Gets an instance float property.
        @param  name    the instance name
        @param  prop    the property name
        @return the value if the instance and property were found, 0 otherwise
    **/
    public function instanceProp(name:String, prop:String):Float {
        if (this._instances.exists(name)) {
            return (this._instances[name].getProp(prop));
        } else {
            return (0);
        }
    }

    /**
        Gets an instance bool property.
        @param  name    the instance name
        @param  prop    the property name
        @return the value if the instance and property were found, false otherwise
    **/
    public function instanceBoolProp(name:String, prop:String):Bool {
        if (this._instances.exists(name)) {
            return (this._instances[name].getBoolProp(prop));
        } else {
            return (false);
        }
    }

    /**
        Gets an instance string property.
        @param  name    the instance name
        @param  prop    the property name
        @return the value if the instance and property were found, empty string otherwise
    **/
    public function instanceStringProp(name:String, prop:String):String {
        if (this._instances.exists(name)) {
            return (this._instances[name].getStringProp(prop));
        } else {
            return ('');
        }
    }

    /**
        Sets the current animation transition.
        @param  to  the new transition method
    **/
    public function setAnimation(to:String):Void {
        switch (to) {
            case 'bounce.in':
                Actuate.defaultEase = Bounce.easeIn;
            case 'bounce.out':
                Actuate.defaultEase = Bounce.easeOut;
            case 'bounce.inout':
                Actuate.defaultEase = Bounce.easeInOut;
            case 'cubic.in':
                Actuate.defaultEase = Cubic.easeIn;
            case 'cubic.out':
                Actuate.defaultEase = Cubic.easeOut;
            case 'cubic.inout':
                Actuate.defaultEase = Cubic.easeInOut;
            case 'elastic.in':
                Actuate.defaultEase = Elastic.easeIn;
            case 'elastic.out':
                Actuate.defaultEase = Elastic.easeOut;
            case 'elastic.inout':
                Actuate.defaultEase = Elastic.easeInOut;
            case 'expo.in':
                Actuate.defaultEase = Expo.easeIn;
            case 'expo.out':
                Actuate.defaultEase = Expo.easeOut;
            case 'expo.inout':
                Actuate.defaultEase = Expo.easeInOut;
            case 'quad.in':
                Actuate.defaultEase = Quad.easeIn;
            case 'quad.out':
                Actuate.defaultEase = Quad.easeOut;
            case 'quad.inout':
                Actuate.defaultEase = Quad.easeInOut;
            case 'quart.in':
                Actuate.defaultEase = Quart.easeIn;
            case 'quart.out':
                Actuate.defaultEase = Quart.easeOut;
            case 'quart.inout':
                Actuate.defaultEase = Quart.easeInOut;
            case 'quint.in':
                Actuate.defaultEase = Quint.easeIn;
            case 'quint.out':
                Actuate.defaultEase = Quint.easeOut;
            case 'quint.inout':
                Actuate.defaultEase = Quint.easeInOut;
            case 'sine.in':
                Actuate.defaultEase = Sine.easeIn;
            case 'sine.out':
                Actuate.defaultEase = Sine.easeOut;
            case 'sine.inout':
                Actuate.defaultEase = Sine.easeInOut;
            case 'linear':
                Actuate.defaultEase = Linear.easeNone;
        }
    }

    /**
        Scrolls an instance text.
        @param  inst    the instance name
        @param  val    scroll direction
        @return was the instace found?
    **/
    public function textScroll(inst:String, val:Int):Bool {
        if (this._instances.exists(inst)) {
            this._instances[inst].textScroll(val);
            return (true);
        } else {
            return (false);
        }
    }

    /**
        Sets a paragraph text.
        @param  inst    the instance name
        @param  txt the new text
        @return was the instace found?
    **/
    public function setText(inst:String, txt:String):Bool {
        if (this._instances.exists(inst)) {
            this._instances[inst].setText(txt);
            return (true);
        } else {
            return (false);
        }
    }

    /**
        Sets an instance visibility.
        @param  inst    the instance name
        @param  vis should the instance be visible?
        @return was the instace found?
    **/
    public function setVisible(inst:String, vis:Bool):Bool {
        if (this._instances.exists(inst)) {
            this._instances[inst].visible = vis;
            this.setProperty(inst, 'visible', vis, vis);
            return (true);
        } else {
            return (false);
        }
    }

    /**
        Fixes a property value of an instance.
        @param  inst    the instance name
        @param  prop    the property name
        @param  vH  value for horizontal display
        @param  vV  value for vertical display
        @return was the instace found?
    **/
    public function setProperty(inst:String, prop:String, vH:Dynamic, vV:Dynamic):Bool {
        if (this._instances.exists(inst)) {
            this._instances[inst].fixProp(prop, vH, vV);
            return (true);
        } else {
            return (false);
        }
    }

    /**
        Releases a fixed property value of an instance.
        @param  inst    the instance name
        @param  prop    the property name
        @return was the instace found?
    **/
    public function releaseProperty(inst:String, prop:String):Bool {
        if (this._instances.exists(inst)) {
            this._instances[inst].releaseProp(prop);
            return (true);
        } else {
            return (false);
        }
    }

    /**
        Releases all fixed property values of an instance.
        @param  inst    the instance name (empty string for all)
        @return was the instace found?
    **/
    public function releaseAllProperties(inst:String = ''):Bool {
        if (inst == '') {
            for (ins in this._instances) ins.releaseAll();
            return (true);
        } else if (this._instances.exists(inst)) {
            this._instances[inst].releaseAll();
            return (true);
        } else {
            return (false);
        }
    }

    /**
        Loads the instance collection next asset.
        @param  inst    the instance name
        @return was the instance found?
    **/
    public function next(inst:String):Bool {
        if (this._instances.exists(inst)) {
            this._instances[inst].next();
            return (true);
        } else {
            return (false);
        }
    }

    /**
        Loads the instance collection previous asset.
        @param  inst    the instance name
        @return was the instance found?
    **/
    public function previous(inst:String):Bool {
        if (this._instances.exists(inst)) {
            this._instances[inst].previous();
            return (true);
        } else {
            return (false);
        }
    }

    /**
        Loads an instance collection asset.
        @param  inst    the instance name
        @param  name    the asset name
        @return were the instance and asset found?
    **/
    public function loadAsset(inst:String, name:String):Bool {
        if (this._instances.exists(inst)) {
            return (this._instances[inst].loadAsset(name));
        } else {
            return (false);
        }
    }

    /**
        Loads an asset from a collection into an instance.
        @param  inst    the instance name
        @param  col     the collection name
        @param  ast     the asset name
        @return were the instance and asset found?
    **/
    public function loadCollectionAsset(inst:String, col:String, ast:String):Bool {
        if (this._instances.exists(inst)) {
            return (this._instances[inst].loadCollectionAsset(col, ast));
        } else {
            return (false);
        }
    }

    /**
        Gets a reference to an overlay layer.
        @param  name    the overlay name (creates one if doesn't exist)
        @param  below   get overley below movie content?
        @return a reference to the overlay
    **/
    public function getOverlay(name:String, below:Bool = false):Sprite {
        if (below) {
            if (!this._bloverlays.exists(name)) {
                this._bloverlays[name] = new Sprite();
                this._bloverlay.addChild(this._bloverlays[name]);
            }
            return (this._bloverlays[name]);
        } else {
            if (!this._overlays.exists(name)) {
                this._overlays[name] = new Sprite();
                this._overlay.addChild(this._overlays[name]);
            }
            return (this._overlays[name]);
        }
    }

    /**
        Removes an overlay layer.
        @param  name    the layer name to remove
        @param  below   overlay below content?
        @return was the layer found and removed?
    **/
    public function removeOverlay(name:String, below:Bool = false):Bool {
        if (below) {
            if (this._bloverlays.exists(name)) {
                this._bloverlay.removeChild(this._bloverlays[name]);
                this._bloverlays[name].removeChildren();
                this._bloverlays[name].graphics.clear();
                this._bloverlays.remove(name);
                return (true);
            } else {
                return (false);
            }
        } else {
            if (this._overlays.exists(name)) {
                this._overlay.removeChild(this._overlays[name]);
                this._overlays[name].removeChildren();
                this._overlays[name].graphics.clear();
                this._overlays.remove(name);
                return (true);
            } else {
                return (false);
            }
        }
    }

    /**
        Brings an overlay layer to top.
        @param  name    the layer name to remove
        @return was the layer found and moved?
    **/
    public function overlayTop(name:String):Bool {
        if (this._overlays.exists(name)) {
            this._overlay.swapChildrenAt((this._overlay.numChildren - 1), this._overlay.getChildIndex(this._overlays[name]));
            return (true);
        } else {
            return (false);
        }
    }

    /**
        Sends an overlay layer to bottom.
        @param  name    the layer name to remove
        @return was the layer found and moved?
    **/
    public function overlayBottom(name:String):Bool {
        if (this._overlays.exists(name)) {
            this._overlay.swapChildrenAt(0, this._overlay.getChildIndex(this._overlays[name]));
            return (true);
        } else {
            return (false);
        }
    }

    /**
        Releases resources used by the object.
    **/
    public function kill():Void {
        this.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        this._bgarea.removeChildren();
        this._bgarea.graphics.clear();
        this._bgarea = null;
        this._player = null;
        this.removeChildren();
        this._holder.removeChildren();
        this._holder.mask = null;
        this._holder = null;
        this._bg.graphics.clear();
        this._bg = null;
        this._mask.graphics.clear();
        this._mask = null;
        this._scene.removeChildren();
        this._scene = null;
        for (o in this._overlays.keys()) this.removeOverlay(o);
        this._overlays = null;
        this._overlay.removeChildren();
        this._overlay = null;
        for (o in this._bloverlays.keys()) this.removeOverlay(o, true);
        this._bloverlays = null;
        this._bloverlay.removeChildren();
        this._bloverlay = null;
        for (i in this._instances.keys()) {
            this._instances[i].kill();
            this._instances.remove(i);
        }
        this._instances = null;
        this._uiArea.removeChildren();
        this._uiArea = null;
        this._uiBg.graphics.clear();
        this._uiBg = null;
        this._inputPanel.kill();
        this._inputPanel = null;
    }

    /**
        Clears the display area.
    **/
    public function clear():Void {
        Actuate.stop(this, { kfPercent: 100 }, false, false);
        this._currentKf = 0;
        this._scene.removeChildren();
        for (i in this._instances.keys()) {
            this._instances[i].kill();
            this._instances.remove(i);
        }
        this._uiBg.visible = false;
        this._inputPanel.visible = false;
    }

    /**
        Sets the movie area to current state.
    **/
    public function setArea():Void {
        this._bg.graphics.clear();
        this._mask.graphics.clear();
        this._bg.graphics.beginFill(GlobalPlayer.movie.data.screen.bgcolor);
        this._mask.graphics.beginFill(0);
        if (GlobalPlayer.movie.data.screen.type == MovieArea.SORIENTATION) {
            this._bg.graphics.drawRect(0, 0, GlobalPlayer.movie.data.screen.big, GlobalPlayer.movie.data.screen.big);
            this._mask.graphics.drawRect(0, 0, GlobalPlayer.movie.data.screen.big, GlobalPlayer.movie.data.screen.big);
        } else if ((GlobalPlayer.movie.data.screen.type == MovieArea.HORIENTATION) || (GlobalPlayer.movie.data.screen.type == 'landscape')) {
            this._bg.graphics.drawRect(0, 0, GlobalPlayer.movie.data.screen.big, GlobalPlayer.movie.data.screen.small);
            this._mask.graphics.drawRect(0, 0, GlobalPlayer.movie.data.screen.big, GlobalPlayer.movie.data.screen.small);
        } else if ((GlobalPlayer.movie.data.screen.type == MovieArea.VORIENTATION) || (GlobalPlayer.movie.data.screen.type == 'portrait')) {
            this._bg.graphics.drawRect(0, 0, GlobalPlayer.movie.data.screen.small, GlobalPlayer.movie.data.screen.big);
            this._mask.graphics.drawRect(0, 0, GlobalPlayer.movie.data.screen.small, GlobalPlayer.movie.data.screen.big);
        } else {
            if (this.pOrientation == MovieArea.VORIENTATION) {
                this._bg.graphics.drawRect(0, 0, GlobalPlayer.movie.data.screen.small, GlobalPlayer.movie.data.screen.big);
                this._mask.graphics.drawRect(0, 0, GlobalPlayer.movie.data.screen.small, GlobalPlayer.movie.data.screen.big);
            } else {
                this._bg.graphics.drawRect(0, 0, GlobalPlayer.movie.data.screen.big, GlobalPlayer.movie.data.screen.small);
                this._mask.graphics.drawRect(0, 0, GlobalPlayer.movie.data.screen.big, GlobalPlayer.movie.data.screen.small);
            }
        }
        this._bg.graphics.endFill();
        this._mask.graphics.endFill();
        this._uiBg.width = this._mask.width * this._scale;
        this._uiBg.height = this._mask.height * this._scale;

        // set player background
        this._bgarea.graphics.clear();
        this._bgarea.graphics.beginFill(0);
        this._bgarea.graphics.drawRect(0, 0, this._player.rWidth, this._player.rHeight);
        this._bgarea.graphics.endFill();

        // warn contraptions
        GlobalPlayer.contraptions.changeDisplay();

        // placing the movie area
        this.place();
    }

    /**
        Opens a login input box.
        @param  acOk    actions to call on ok button click
        @param  acCancel    actions to call on cancel button click
    **/
    public function showLoginInput(acOk:Dynamic, acCancel:Dynamic):Void {
        var logintitle:String = GlobalPlayer.parser.parseString("$_TEXTS:logintitle");
        if (logintitle == '') logintitle = 'Login';
        var logintext:String = GlobalPlayer.parser.parseString("$_TEXTS:logintext");
        if (logintext == '') logintext = "Please type your e-mail address. You'll receive a 6 digit code to confirm your identity.";
        var termsagree:String = GlobalPlayer.parser.parseString("$_TEXTS:termsagree");
        if (termsagree == '') termsagree = "I agree with the above terms.";
        var invalidemail:String = GlobalPlayer.parser.parseString("$_TEXTS:invalidemail");
        if (invalidemail == '') invalidemail = "Please provide a valid e-mail address.";
        var emailwait:String = GlobalPlayer.parser.parseString("$_TEXTS:emailwait");
        if (emailwait == '') emailwait = "Please wait while a confirmation code is sent to your e-mail.";
        var noemailsent:String = GlobalPlayer.parser.parseString("$_TEXTS:noemailsent");
        if (noemailsent == '') noemailsent = "Error while sending the code by e-mail. Please try again.";
        var checkforcode:String = GlobalPlayer.parser.parseString("$_TEXTS:checkforcode");
        if (checkforcode == '') checkforcode = "Please check out your e-mail inbox. Type below the 6 digit code you received. If you do not find the message, take a look at you spam folder.";
        var codewait:String = GlobalPlayer.parser.parseString("$_TEXTS:codewait");
        if (codewait == '') codewait = "Please wait while the provided code is checked.";
        var invalidcode:String = GlobalPlayer.parser.parseString("$_TEXTS:invalidcode");
        if (invalidcode == '') invalidcode = "The provided code is invalid. Please try again.";
        var emailsubject:String = GlobalPlayer.parser.parseString("$_TEXTS:emailsubject");
        if (emailsubject == '') emailsubject = "TilBuci login";
        var emailbody:String = GlobalPlayer.parser.parseString("$_TEXTS:emailbody");
        if (emailbody == '') emailbody = "Hi, you are receiving this message to confirm your login at TilBuci. Please provide the code below to proceed:\r\n\r\n[CODE]\r\n\r\nIf you did'nt request this code, don't worry: just ignore this message.";
        var emailsender:String = GlobalPlayer.parser.parseString("$_TEXTS:emailsender");
        if (emailsender == '') emailsender = 'TilBuci';
        this._inputPanel.askLogin(logintitle, logintext, termsagree, invalidemail, emailwait, noemailsent, checkforcode, codewait, invalidcode, emailsubject, emailbody, emailsender, acOk, acCancel);
    }

    public function showStatesInput(acOk:Dynamic, acCancel:Dynamic):Void {
        var titlestates:String = GlobalPlayer.parser.parseString("$_TEXTS:titlestates");
        if (titlestates == '') titlestates = 'Select a state to load';
        var waistates:String = GlobalPlayer.parser.parseString("$_TEXTS:waistates");
        if (waistates == '') waistates = 'Please wait while a list of available saves states is loaded.';
        var selectstate:String = GlobalPlayer.parser.parseString("$_TEXTS:selectstate");
        if (selectstate == '') selectstate = 'Select a state to load.';
        var nostates:String = GlobalPlayer.parser.parseString("$_TEXTS:nostates");
        if (nostates == '') nostates = 'Sorry, no saved states found to load.';
        var dateformat:String = GlobalPlayer.parser.parseString("$_TEXTS:dateformat");
        if (dateformat == '') dateformat = 'Y-m-d h:i a';
        this._inputPanel.askStates(titlestates, waistates, selectstate, nostates, dateformat, acOk, acCancel);
    }

    /**
        Opens a text input box.
        @param  varname the variable name to receive the input
        @param  title   the input box title
        @param  acOk    actions to call on ok button click
        @param  acCancel    actions to call on cancel button click
    **/
    public function showTextInput(varname:String, title:String, acOk:Dynamic, acCancel:Dynamic):Void {
        this._inputPanel.askText(varname, title, acOk, acCancel);
    }

    /**
        Opens a secret key input box.
        @param  title   the input box title
    **/
    public function showSecretKeyInput(title:String):Void {
        this._inputPanel.askSecret(title);
    }

    /**
        Opens a message box,
        @param  title   the warn box title
        @param  text   the warn box message
        @param  acOk    actions to call on ok button click
        @param  acCancel    actions to call on cancel button click (null to avoid showing cancel button)
    **/
    public function showMessageInput(title:String, text:String, acOk:Dynamic, acCancel:Dynamic):Void {
        this._inputPanel.setWarn(title, text, acOk, acCancel);
    }

    /**
        Opens a e-mail input box.
        @param  varname the variable name to receive the input
        @param  title   the input box title
        @param  domains automatic fill domains
        @param  acOk    actions to call on ok button click
        @param  acCancel    actions to call on cancel button click (null to avoid showing cancel button)
    **/
    public function showEmailInput(varname:String, title:String, domains:Array<String>, acOk:Dynamic, acCancel:Dynamic):Void {
        this._inputPanel.askEmail(varname, title, domains, acOk, acCancel);
    }

    /**
        Opens a list input box.
        @param  varname the variable name to receive the input
        @param  title   the input box title
        @param  options list options
        @param  acOk    actions to call on ok button click
        @param  acCancel    actions to call on cancel button click
    **/
    public function showListInput(varname:String, title:String, options:Array<String>, acOk:Dynamic, acCancel:Dynamic):Void {
        this._inputPanel.askList(varname, title, options, acOk, acCancel);
    }

    /**
        Opens a numeric input box.
        @param  type    numerci type (int or float)
        @param  varname the variable name to receive the input
        @param  title   the input box title
        @param  acOk    actions to call on ok button click
        @param  acCancel    actions to call on cancel button click
        @param  stem    increase/decrease step
        @param  min minimum value
        @param  max maximum value
    **/
    public function showNumericInput(type:String, varname:String, title:String, acOk:Dynamic, acCancel:Dynamic, step:Float = 0, min:Float = 0, max:Float = 100):Void {
        this._inputPanel.askNumeric(type, varname, title, acOk, acCancel, step, min, max);
    }

    /**
        Changes an instance ID.
        @param  oldid   old instance ID
        @param  newid   new instance ID
        @return was the instance found and changed?
    **/
    public function swapInstance(oldid:String, newid:String):Bool {
        if (this._instances.exists(oldid)) {
            var img:InstanceImage = this._instances[oldid];
            if (img.changeId(oldid, newid)) {
                this._instances.remove(oldid);
                this._instances[newid] = img;
                return (true);
            } else {
                return (false);
            }
        } else {
            return (false);
        }
    }

    /**
        Get current instances ids.
        @return instance id list
    **/
    public function getInstances():Array<String> {
        var list:Array<String> = [ ];
        for (k in this._instances.keys()) list.push(k);
        return (list);
    }

    /**
        Picks an instance.
        @param  name    the instance name
        @return the selected instance or null if not found
    **/
    public function pickInstance(name:String):InstanceImage {
        if (this._instances.exists(name)) {
            return (this._instances[name]);
        } else {
            return (null);
        }
    }

    /**
        Applies display area mask.
        @param  to  mask area?
    **/
    public function maskArea(to:Bool):Void {
        if (to) {
            this._mask.visible = true;
            this._holder.mask = this._mask;
        } else {
            this._holder.mask = null;
            this._mask.visible = false;
        }
    }

    public function setOverlay(to:Bool):Void {
        if (to && (this._overlay.parent == null)) {
            this._holder.addChild(this._overlay);
        } else if (!to && (this._overlay.parent != null)) {
            this._holder.removeChild(this._overlay);
        }
    }

    /**
        Resizes and places the movie display insde the player area.
    **/
    private function place():Void {
        // removing the overlay display
        this._holder.removeChild(this._target);
        this._holder.removeChild(this._overlay);
        this._holder.removeChild(this._bloverlay);

        // setting correct scale
        if (this.pOrientation == MovieArea.VORIENTATION) {
            this._scale = this._player.rWidth / this.aWidth;
            if ((this.aHeight * this._scale) > this._player.rHeight) {
                this._scale = this._player.rHeight / this.aHeight;
            }
        } else {
            this._scale = this._player.rHeight / this.aHeight;
            if ((this.aWidth * this._scale) > this._player.rWidth) {
                this._scale = this._player.rWidth / this.aWidth;
            }
        }
        this.scaleX = this.scaleY = this._scale;
        this._uiBg.width = this._mask.width * this._scale;
        this._uiBg.height = this._mask.height * this._scale;

        if ((this._player.rWidth - (this.aWidth * this._scale)) < (this._player.rHeight - (this.aHeight * this._scale))) {
            this._uiArea.x = this.x = 0;
            this._uiArea.y = this.y = (this._player.rHeight - (this.aHeight * this._scale)) / 2;
        } else {
            this._uiArea.x = this.x = (this._player.rWidth - (this.aWidth * this._scale)) / 2;
            this._uiArea.y = this.y = 0;
        }

        // getting actual content position
        GlobalPlayer.contentPosition.x = this._uiArea.x;
        GlobalPlayer.contentPosition.y = this._uiArea.y;
        GlobalPlayer.contentWidth = this._uiBg.width;
        GlobalPlayer.contentHeight = this._uiBg.height;

        // holding values
        if (this._player.rWidth >= this._player.rHeight) {
            GlobalPlayer.orientation = 'horizontal';
            GlobalPlayer.multiply = Math.round(this._player.rWidth/this.aWidth);
        } else {
            GlobalPlayer.orientation = 'vertical';
            GlobalPlayer.multiply = Math.round(this._player.rHeight/this.aHeight);
        }
        if (GlobalPlayer.multiply < 1) GlobalPlayer.multiply = 1;
            else if (GlobalPlayer.multiply > 5) GlobalPlayer.multiply = 5;
        
        // returning the overlay display
        this._holder.removeChildren();
        this._holder.addChild(this._bg);
        this._holder.addChild(this._bloverlay);
        this._holder.addChild(this._scene);
        this._holder.addChild(this._inputArea);
        this._holder.addChild(this._overlay);

        //this._holder.addChild(this._target);

        // warn plugins
        for (p in GlobalPlayer.plugins) {
            if (p.ready) p.info.onDisplayResize(GlobalPlayer.orientation, GlobalPlayer.multiply);
        }
    }

    /**
        Removes all input interfaces form display.
    **/
    public function removeInputInterfaces():Void {
        this.removeAllInputs();
        this.removeAllTareas();
        this.removeAllNumerics();
        this.removeAllToggles();
    }

    /**
        Adds a text input.
        @param  name    the input name
        @param  px  x position
        @param  py  y position
        @param  width   input width
        @param  placeholder placeholder text
    **/
    public function addInput(name:String, px:Float, py:Float, width:Float, placeholder:String = ''):Void {
        this._player.addInput(name, px, py, width, placeholder);
    }

    /**
        Places an existing text input.
        @param  name    the input name
        @param  px  x position
        @param  py  y position
        @param  width   input width
    **/
    public function placeInput(name:String, px:Float, py:Float, width:Float):Void {
        this._player.placeInput(name, px, py, width);
    }

    /**
        Removes a text input.
        @param  name    the input name
    **/
    public function removeInput(name:String):Void {
        this._player.removeInput(name);
    }

    /**
        Removes all text inputs.
    **/
    public function removeAllInputs():Void {
        this._player.removeAllInputs();
    }

    /**
        Gets a text input current value.
        @param  name    the input name
    **/
    public function getInputText(name):String {
        return (this._player.getInputText(name));
    }

    /**
        Sets a text input value.
        @param  name    the input name
        @param  value   the new text
    **/
    public function setInputText(name:String, value:String):Void {
        this._player.setInputText(name, value);
    }

    /**
        Sets an input password mask display.
        @param  name    the input name
        @param  pass    show as password?
    **/
    public function setInputPassword(name:String, pass:Bool):Void {
        this._player.setInputPassword(name, pass);
    }

    /**
        Adds a text area.
        @param  name    the input name
        @param  px  x position
        @param  py  y position
        @param  width   input width
        @param  height   input height
    **/
    public function addTarea(name:String, px:Float, py:Float, width:Float, height:Float):Void {
        this._player.addTarea(name, px, py, width, height);
    }

    /**
        Places an existing text area.
        @param  name    the input name
        @param  px  x position
        @param  py  y position
        @param  width   input width
        @param  height   input height
    **/
    public function placeTarea(name:String, px:Float, py:Float, width:Float, height:Float):Void {
        this._player.placeTarea(name, px, py, width, height);
    }

    /**
        Removes a text area.
        @param  name    the input name
    **/
    public function removeTarea(name:String):Void {
        this._player.removeTarea(name);
    }

    /**
        Removes all text areas.
    **/
    public function removeAllTareas():Void {
        this._player.removeAllTareas();
    }

    /**
        Gets a text area current value.
        @param  name    the input name
    **/
    public function getTareaText(name):String {
        return (this._player.getTareaText(name));
    }

    /**
        Sets a text area value.
        @param  name    the input name
        @param  value   the new text
    **/
    public function setTareaText(name:String, value:String):Void {
        this._player.setTareaText(name, value);
    }

    /**
        Adds a numeric input.
        @param  name    the input name
        @param  value   inicial value
        @param  minimum stepper minimum
        @param  maximum stepper maximum
        @param  step    stepper increase
        @param  px  x position
        @param  py  y position
        @param  width   input width
    **/
    public function addNumeric(name:String, value:Int, minimum:Int, maximum:Int, step:Int):Void {
        this._player.addNumeric(name, value, minimum, maximum, step);
    }

    /**
        Places an existing numeric input.
        @param  name    the input name
        @param  px  x position
        @param  py  y position
        @param  width   input width
    **/
    public function placeNumeric(name:String, px:Float, py:Float, width:Float):Void {
        this._player.placeNumeric(name, px, py, width);
    }

    /**
        Removes a numeric input.
        @param  name    the input name
    **/
    public function removeNumeric(name:String):Void {
        this._player.removeNumeric(name);
    }

    /**
        Removes all numeric inputs.
    **/
    public function removeAllNumerics():Void {
        this._player.removeAllNumerics();
    }

    /**
        Gets a numeric input current value.
        @param  name    the input name
    **/
    public function getNumericValue(name:String):Int {
        return(this._player.getNumericValue(name));
    }

    /**
        Sets a numeric input value.
        @param  name    the input name
        @param  value   the new value
    **/
    public function setNumericValue(name:String, value:Int):Void {
        this._player.setNumericValue(name, value);
    }

    /**
        Sets a numeric input bounds.
        @param  name    the input name
        @param  minimum stepper minimum
        @param  maximum stepper maximum
        @param  step    stepper increase
    **/
    public function setNumericBounds(name:String, minimum:Int, maximum:Int, step:Int):Void {
        this._player.setNumericBounds(name, minimum, maximum, step);
    }

    /**
        Adds a toggle input.
        @param  name    the input name
        @param  value   the toggle value
        @param  px  x position
        @param  py  y position
    **/
    public function addToggle(name:String, value:Bool, px:Float, py:Float):Void {
        this._player.addToggle(name, value, px, py);   
    }

    /**
        Places an existing toggle input.
        @param  name    the input name
        @param  px  x position
        @param  py  y position
    **/
    public function placeToggle(name:String, px:Float, py:Float):Void {
        this._player.placeToggle(name, px, py);
    }

    /**
        Removes a toggle input.
        @param  name    the input name
    **/
    public function removeToggle(name:String):Void {
        this._player.removeToggle(name);
    }

    /**
        Removes all toggle inputs.
    **/
    public function removeAllToggles():Void {
        this._player.removeAllToggles();
    }

    /**
        Gets a toggle input current value.
        @param  name    the input name
    **/
    public function getToggleValue(name:String):Bool {
        return(this._player.getToggleValue(name));
    }

    /**
        Sets a toggle input value.
        @param  name    the input name
        @param  value   the new text
    **/
    public function setToggleValue(name:String, value:Bool):Void {
        this._player.setToggleValue(name, value);
    }

    /**
        Inverts a toggle input value.
        @param  name    the input name
    **/
    public function invertToggle(name:String):Void {
        this._player.invertToggle(name);
    }

    /**
        Removes mouse over effect on images.
    **/
    public function noMouseOver():Void {
        for (inst in this._instances) inst.onMouseOut();
    }
}