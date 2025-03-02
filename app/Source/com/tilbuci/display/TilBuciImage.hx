/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.display;

/** HAXE **/
import openfl.display.Shape;
import haxe.Timer;

/** OPENFL **/
import openfl.display.Sprite;

/** TILBUCI **/
import com.tilbuci.def.AssetData;
import com.tilbuci.data.GlobalPlayer;
import com.tilbuci.def.InstanceData;

class TilBuciImage extends Sprite {

    /**
        picture content holder
    **/
    private var _picture:PictureImage;

    /**
        video content holder
    **/
    private var _video:VideoImage;

    /**
        audio content holder
    **/
    private var _audio:AudioImage;

    /**
        text content holder
    **/
    private var _text:TextImage;

    /**
        paragraph content holder
    **/
    private var _paragraph:ParagraphImage;

    /**
        html content holder
    **/
    private var _html:HtmlImage;

    /**
        spritemap content holder
    **/
    private var _spritemap:SpritemapImage;

    /**
        shape content holder
    **/
    private var _shape:ShapeImage;

    /**
        current content type
    **/
    private var _currentType:String;

    /**
        asset total time (seconds)
    **/
    private var _totalTime:Int = 1;

    /**
        current timer
    **/
    private var _currentTime:Int = 0;

    /**
        current time finish action
    **/
    private var _currentAction:String = '';

    /**
        loaded asset order on collection
    **/
    public var assetOrder:Int = 0;

    /**
        method to call on content load (must receive a single Bool parameter)
    **/
    private var _onLoad:Dynamic;

    /**
        content original width
    **/
    private var _oWidth:Float = 0;

    /**
        content original height
    **/
    private var _oHeight:Float = 0;

    /**
        was the last content loaded successfully?
    **/
    private var _loadOK:Bool = false;

    /**
        instance name
    **/
    private var _name:String = '';

    /**
        image timer
    **/
    private var _timer:Timer;

    /**
        does the current media type use the timer?
    **/
    private var _useTimer:Bool = false;

    /**
        currently playing?
    **/
    public var playing(get, null):Bool;
    private var _playing:Bool = false;
    private function get_playing():Bool { return (this._playing); }

    /**
        current type
    **/
    public var currentType(get, null):String;
    private function get_currentType():String { return (this._currentType); }

    /**
        current media
    **/
    public var currentMedia(get, null):String;
    private function get_currentMedia():String {
        switch (this._currentType) {
            case 'picture':
                return (this._picture.lastMedia);
            case 'video':
                return (this._video.lastMedia);
            case 'spritemap':
                return (this._spritemap.lastMedia);
            case 'audio':
                return (this._audio.lastMedia);
            case 'paragraph':
                return (this._paragraph.lastMedia);
            default:
                return ('');
        }
    }

    public function new(ol:Dynamic, name:String) {
        super();
        this._onLoad = ol;
        this.graphics.beginFill(1, 0);
        this.graphics.drawRect(0, 0, 8, 8);
        this.graphics.endFill();
        this._name = name;

        // add image types
        this._picture = new PictureImage(this.onLoad);
        this.addChild(this._picture);
        this._video = new VideoImage(this.onLoad, this.onEnd);
        this.addChild(this._video);
        this._audio = new AudioImage(this.onLoad, this.onEnd);
        this.addChild(this._audio);
        this._text = new TextImage(this.onLoad);
        this.addChild(this._text);
        this._paragraph = new ParagraphImage(this.onLoad);
        this.addChild(this._paragraph);
        this._html = new HtmlImage(this.onLoad);
        this.addChild(this._html);
        this._spritemap = new SpritemapImage(this.onLoad);
        this.addChild(this._spritemap);
        this._shape = new ShapeImage(this.onLoad);
        this.addChild(this._shape);
    }

    /**
        Load a new content.
        @param  inf instance information
        @return content can be loaded?
    **/
    public function load(inf:InstanceData):Bool {
        if (inf.ok) {
            var ret:Bool = false;
            switch (GlobalPlayer.movie.collections[inf.collection].assets[inf.asset].type) {
                case 'picture':
                    this._picture.load(GlobalPlayer.movie.collections[inf.collection].assets[inf.asset].file['@'+GlobalPlayer.multiply]);
                    this._currentType = 'picture';
                    this._useTimer = true;
                case 'text':
                    this._text.load(GlobalPlayer.movie.collections[inf.collection].assets[inf.asset].file['@'+GlobalPlayer.multiply]);
                    this._currentType = 'text';
                    this._useTimer = true;
                case 'paragraph':
                    this._paragraph.load(GlobalPlayer.movie.collections[inf.collection].assets[inf.asset].file['@'+GlobalPlayer.multiply]);
                    this._currentType = 'paragraph';
                    this._useTimer = true;
                case 'html':
                    this._html.load(GlobalPlayer.movie.collections[inf.collection].assets[inf.asset].file['@'+GlobalPlayer.multiply]);
                    this._currentType = 'html';
                    this._useTimer = true;
                case 'video':
                    this._video.load(GlobalPlayer.movie.collections[inf.collection].assets[inf.asset].file['@'+GlobalPlayer.multiply]);
                    this._currentType = 'video';
                    this._useTimer = false;
                case 'audio':
                    this._audio.load(GlobalPlayer.movie.collections[inf.collection].assets[inf.asset].file['@'+GlobalPlayer.multiply]);
                    this._currentType = 'audio';
                    this._useTimer = false;
                case 'spritemap':
                    this._spritemap.frames = GlobalPlayer.movie.collections[inf.collection].assets[inf.asset].frames;
                    this._spritemap.frtime = GlobalPlayer.movie.collections[inf.collection].assets[inf.asset].frtime;
                    this._spritemap.load(GlobalPlayer.movie.collections[inf.collection].assets[inf.asset].file['@'+GlobalPlayer.multiply]);
                    this._currentType = 'spritemap';
                    this._useTimer = true;
                case 'shape':
                    this._shape.load(GlobalPlayer.movie.collections[inf.collection].assets[inf.asset].file['@'+GlobalPlayer.multiply]);
                    this._currentType = 'shape';
                    this._useTimer = true;
            }
            this._totalTime = GlobalPlayer.movie.collections[inf.collection].assets[inf.asset].time;
            this._currentAction = GlobalPlayer.movie.collections[inf.collection].assets[inf.asset].action;
            this.assetOrder = GlobalPlayer.movie.collections[inf.collection].assets[inf.asset].order;
            this._loadOK = false;
            return (true);
        } else {
            this._loadOK = false;
            return (false);
        }
    }

    /**
        Loads an asset content into this image.
        @param  asset   the asset information
        @return always true
    **/
    public function loadAsset(asset:AssetData):Bool {
        switch (asset.type) {
            case 'picture':
                this._picture.load(asset.file['@'+GlobalPlayer.multiply]);
                this._currentType = 'picture';
                this._useTimer = true;
            case 'text':
                this._text.load(asset.file['@'+GlobalPlayer.multiply]);
                this._currentType = 'text';
                this._useTimer = true;
            case 'paragraph':
                this._paragraph.load(asset.file['@'+GlobalPlayer.multiply]);
                this._currentType = 'paragraph';
                this._useTimer = true;
            case 'html':
                this._html.load(asset.file['@'+GlobalPlayer.multiply]);
                this._currentType = 'html';
                this._useTimer = true;
            case 'video':
                this._video.load(asset.file['@'+GlobalPlayer.multiply]);
                this._currentType = 'video';
                this._useTimer = false;
            case 'audio':
                this._audio.load(asset.file['@'+GlobalPlayer.multiply]);
                this._currentType = 'audio';
                this._useTimer = false;
            case 'spritemap':
                this._spritemap.frames = asset.frames;
                this._spritemap.frtime = asset.frtime;
                this._spritemap.load(asset.file['@'+GlobalPlayer.multiply]);
                this._currentType = 'spritemap';
                this._useTimer = true;
            case 'shape':
                this._shape.load(asset.file['@'+GlobalPlayer.multiply]);
                this._currentType = 'shape';
                this._useTimer = true;
        }
        this._totalTime = asset.time;
        this._currentAction = asset.action;
        this.assetOrder = asset.order;
        this._loadOK = false;
        return (true);
    }

    public function updateFrames(fr:Int, tm:Int):Void {
        if (this._currentType == 'spritemap') {
            this._spritemap.updateFrames(fr, tm);
        }
    }

    /**
        Starts the internal timer for some asset types.
    **/
    public function startTimer():Void {
        if (this._timer != null) {
            try { this._timer.stop(); } catch (e) { }
            this._timer = null;
        }
        if (this._useTimer) {    
            this._currentTime = 0;
            if (this._loadOK) {
                this._timer = new Timer(1000);
                this._timer.run = this.onTimer;
            }
        } else if (this._currentType == 'video') {    
            this._video.play();
        } else if (this._currentType == 'audio') {    
            this._audio.play();
        }
        this._playing = true;
    }

    /**
        Stops the internal timer.
    **/
    public function stopTimer():Void {
        this._currentTime = 0;
        if (this._timer != null) {
            try { this._timer.stop(); } catch (e) { }
            this._timer = null;
        }
        this._video.pause();
        this._audio.pause();
        this._playing = false;
    }

    /**
        Gets current playback time.
        @return the current playback time in seconds
    **/
    public function getTime():Int {
        if (this._useTimer) {
            return (this._currentTime);
        } else {
            if (this._currentType == 'video') {
                return (this._video.getTime());
            } else if (this._currentType == 'audio') {
                return (this._audio.getTime());
            } else {
                return (0);
            }
        }
    }

    /**
        Gets this instance current float properties.
        @param  name    the property name
        @return the property value or 0 if not supported
    **/
    public function getProp(name:String):Float {
        switch (name) {
            case 'fontSize': return (this._paragraph.getProp('fontSize'));
            case 'fontLeading': return (this._paragraph.getProp('fontLeading'));
            case 'fontSpacing': return (this._paragraph.getProp('fontSpacing'));
            default: return (0);
        }
    }

    /**
        Gets this instance current bool properties.
        @param  name    the property name
        @return the property value or false if not supported
    **/
    public function getBoolProp(name:String):Bool {
        switch (name) {
            case 'fontBold': return (this._paragraph.getBoolProp('fontBold'));
            case 'fontItalic': return (this._paragraph.getBoolProp('fontItalic'));
            default: return (false);
        }
    }

    /**
        Gets this instance current string properties.
        @param  name    the property name
        @return the property value or empty string if not supported
    **/
    public function getStringProp(name:String):String {
        switch (name) {
            case 'text':
                if (this._currentType == 'text') {
                    return (this._text.getText());
                } else if (this._currentType == 'paragraph') {
                    return (this._paragraph.getText());
                } else if (this._currentType == 'html') {
                    return (this._html.getText());
                } else {
                    return ('');
                }
            case 'font': return (this._paragraph.getStringlProp('font'));
            case 'fontColor': return (this._paragraph.getStringlProp('fontColor'));
            default: return ('');
        }
    }

    /**
        Plays/pauses the image.
    **/
    public function playPause():Void {
        if (this._useTimer) {
            if (this._timer != null) {
                // currently playing: stop timer
                try { this._timer.stop(); } catch (e) { }
                this._timer = null;
                this._playing = false;
            } else {
                // currently paused: start timer
                this._timer = new Timer(1000);
                this._timer.run = this.onTimer;
                this._playing = true;
            }
        } else {
            if (this._playing) {
                if (this._currentType == 'video') {
                    this._video.pause();
                } else if (this._currentType == 'audio') {
                    this._audio.pause();
                }
            } else {
                if (this._currentType == 'video') {
                    this._video.play();
                } else if (this._currentType == 'audio') {
                    this._audio.play();
                }
            }
            this._playing = !this._playing;
        }
    }

    /**
        Plays the image.
    **/
    public function play():Void {
        if (this._useTimer) {
            if (this._timer == null) {
                this._timer = new Timer(1000);
                this._timer.run = this.onTimer;
            }
        } else {
            if (this._currentType == 'video') {
                this._video.play();
            } else if (this._currentType == 'audio') {
                this._audio.play();
            }
        }
        this._playing = true;
    }

    /**
        Pauses the image.
    **/
    public function pause():Void {
        if (this._useTimer) {
            if (this._timer != null) {
                try { this._timer.stop(); } catch (e) { }
                this._timer = null;
            }
        } else {
            if (this._currentType == 'video') {
                this._video.pause();
            } else if (this._currentType == 'audio') {
                this._audio.pause();
            }
        }
        this._playing = false;
    }

    /**
        Stops the current image playback.
    **/
    public function stop():Void {
        if (this._timer != null) {
            try { this._timer.stop(); } catch (e) { }
            this._timer = null;
        }
        this._playing = false;
        this._currentTime = 0;
        this._video.stop();
        this._audio.stop();
    }

    /**
        Sets the media playback position.
        @param  time    the time to jump to (seconds)
    **/
    public function seek(time:Int):Void {
        if (time < 0) time = 0;
        if (this._useTimer) {
            this._currentTime = time;
        } else {
            if (this._currentType == 'video') {
                this._video.setTime(time);
            } else if (this._currentType == 'audio') {
                this._audio.setTime(time);
            }
        }
    }

    /**
        Sets the text format.
        @param  font    the font name
        @param  size    font size (pt)
        @param  color   text color (hex string)
        @param  bold    text bold?
        @param  italic  text italic?
        @param  leading space among lines
        @param  spacing space among chars
        @param  bg  text backgound color (empty string for none)
        @param  align   text align
    **/
    public function formatText(font:String, size:Int, color:String, bold:Bool, italic:Bool, leading:Int, spacing:Float, bg:String, align:String):Void {
        this._text.setFormat(font, size, color, bold, italic, leading, spacing, bg);
        this._paragraph.setFormat(font, size, color, bold, italic, leading, spacing, bg, align);
        this._html.setFormat(font, size, color, bold, italic, leading, spacing, bg, align);
    }

    /**
        Sets the text field actual size.
        @param  wd  the field width
        @param  ht' the field height
    **/
    public function setTextSize(wd:Float, ht:Float):Void {
        this._paragraph.setTextSize(wd, ht);
        this._html.setTextSize(wd, ht);
        if ((this._currentType == 'paragraph') || (this._currentType == 'html')) {
            this._oWidth = wd;
            this._oHeight = ht;
            //this.width = this.height = (GlobalPlayer.mdata.screen.big / 2) * GlobalPlayer.multiply;
        }
    }

    /**
        Scrolls a text.
        @param  val    scroll direction
    **/
    public function textScroll(val:Int):Void {
        if (this._currentType == 'paragraph') this._paragraph.textScroll(val);
            else if (this._currentType == 'html') this._html.textScroll(val);
    }

    /**
        Sets a paragraph text.
        @param  txt the new text
    **/
    public function setText(txt:String):Void {
        if (this._currentType == 'paragraph') this._paragraph.setText(txt);
            else if (this._currentType == 'html') this._html.setText(txt);
    }

    /**
        Iterate sound transfomations.
        @param  vol new volume value
        @param  pan new pan value
    **/
    public function iterateSound(vol:Float, pan:Float):Void {
        this._video.iterateSound(vol, pan);
        this._audio.iterateSound(vol, pan);
    }

    /**
        Stops any sound iterations.
    **/
    public function stopSound():Void {
        this._video.stopSound();
        this._audio.stopSound();
    }

    /**
        Total time was reached for some asset types.
    **/
    private function onTimer():Void {
        this._currentTime++;
        if (this._currentTime >= this._totalTime) {
            this._currentTime = 0;
            if (this._useTimer) {
                this.endAction();
            }
        }
    }

    /**
        Total toime was reached on self-counting images.
    **/
    private function onEnd():Void {
        this._playing = true;
        if (this._currentType == 'video') {
            if ((this._currentAction != 'next') && (this._currentAction != 'previous') && (this._currentAction != 'stop')) {
                this._video.setTime(0);
                this._video.play();
            }
        } else if (this._currentType == 'audio') {
            if ((this._currentAction != 'next') && (this._currentAction != 'previous') && (this._currentAction != 'stop')) {
                this._audio.setTime(0);
                this._audio.play();
            }
        }
        this.endAction();
    }

    /**
        Image time finish action run.
    **/
    private function endAction():Void {
        if (this._currentAction != '') {
            switch (this._currentAction) {
                case 'next':
                    GlobalPlayer.parser.run('{"ac":"instance.next","param":["' + this._name + '"]}');
                case 'previous':
                    GlobalPlayer.parser.run('{"ac":"instance.previous","param":["' + this._name + '"]}');
                case 'stop':
                    GlobalPlayer.parser.run('{"ac":"instance.stop","param":["' + this._name + '"]}');
                case 'loop':
                    // nothing to do
                case '':
                    // nothing to do
                default:
                    GlobalPlayer.parser.run(this._currentAction);
            }
        }
    }

    /**
        Releases resources used by the object.
    **/
    public function kill():Void {
        this.removeChildren();
        this.graphics.clear();
        this._picture.kill();
        this._picture = null;
        this._video.kill();
        this._video = null;
        this._audio.kill();
        this._audio = null;
        this._text.kill();
        this._text = null;
        this._paragraph.kill();
        this._paragraph = null;
        this._html.kill();
        this._html = null;
        this._spritemap.kill();
        this._spritemap = null;
        this._shape.kill();
        this._shape = null;
        this._onLoad = null;
        this._currentType = null;
        this._currentAction = null;
        if (this._timer != null) {
            try { this._timer.stop(); } catch (e) { }
            this._timer = null;
            this._playing = false;
        }
        this._name = null;
    }

    /**
        Loaded content original width.
    **/
    public function oWidth():Float {
        return (this._oWidth);
    }

    /**
        Loaded content original height.
    **/
    public function oHeight():Float {
        return (this._oHeight);
    }

    /**
       Was the last content loaded successfully?
    **/
    public function loadOK():Bool {
        return (this._loadOK);
    }

    /**
        A new content was just loaded.
        @param  ok  content really loaded?
    **/
    private function onLoad(ok:Bool):Void {
        if (ok) {
            this._picture.visible = false;
            this._video.visible = false;
            this._audio.visible = false;
            this._text.visible = false;
            this._paragraph.visible = false;
            this._html.visible = false;
            this._spritemap.visible = false;
            this._shape.visible = false;
            this.removeChildren();
            switch (this._currentType) {
                case 'picture':
                    this._picture.visible = true;
                    this._picture.width = this._oWidth = this._picture.oWidth;
                    this._picture.height = this._oHeight = this._picture.oHeight;
                    this.addChild(this._picture);
                case 'video':
                    this._video.visible = true;
                    this._oWidth = this._video.width = this._video.oWidth;
                    this._oHeight = this._video.height = this._video.oHeight;
                    this.addChild(this._video);
                case 'audio':
                    this._audio.visible = true;
                    this._oWidth = this._audio.width = 8;
                    this._oHeight = this._audio.height = 8;
                    this.addChild(this._audio);
                case 'text':
                    this._text.visible = true;
                    this._text.width = this._oWidth = this._text.oWidth;
                    this._text.height = this._oHeight = this._text.oHeight;
                    this._text.cacheAsBitmap = true;
                    this.addChild(this._text);
                case 'paragraph':
                    this._paragraph.visible = true;
                    this._paragraph.width = this._oWidth = this._paragraph.oWidth;
                    this._paragraph.height = this._oHeight = this._paragraph.oHeight;
                    this._paragraph.cacheAsBitmap = true;
                    this.addChild(this._paragraph);
                case 'html':
                    this._html.visible = true;
                    this._html.width = this._oWidth = this._html.oWidth;
                    this._html.height = this._oHeight = this._html.oHeight;
                    this._html.cacheAsBitmap = true;
                    this.addChild(this._html);
                case 'spritemap':
                    this._spritemap.visible = true;
                    this._spritemap.width = this._oWidth = this._spritemap.oWidth;
                    this._spritemap.height = this._oHeight = this._spritemap.oHeight;
                    this._spritemap.cacheAsBitmap = true;
                    this.addChild(this._spritemap);
                case 'shape':
                    this._shape.visible = true;
                    this._shape.width = this._oWidth = this._shape.oWidth;
                    this._shape.height = this._oHeight = this._shape.oHeight;
                    this._shape.cacheAsBitmap = true;
                    this.addChild(this._shape);
            }
        }
        this.width = this.height = (GlobalPlayer.mdata.screen.big / 2) * GlobalPlayer.multiply;
        this._loadOK = ok;
        this._onLoad(ok);
    }

}
