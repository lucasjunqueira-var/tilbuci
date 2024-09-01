package com.tilbuci.display;

/** OPENFL **/
import openfl.text.TextFormat;
import openfl.text.TextField;
import openfl.text.TextFormatAlign;
import openfl.net.URLLoader;
import openfl.net.URLRequest;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.events.SecurityErrorEvent;

/** TILBUCI **/
import com.tilbuci.data.GlobalPlayer;

class HtmlImage extends BaseImage {

    /**
        the text display
    **/
    private var _text:TextField;

    /**
        text formatting data
    **/
    private var _format:TextFormat;

    /**
        file loader
    **/
    private var _loader:URLLoader;

    /**
        current scroll position
    **/
    private var _scrollPos:Int = 0;

    public function new(ol:Dynamic) {
        super('html', false, ol);
        this._text = new TextField();
        this._text.selectable = false;
        this._format = new TextFormat();
        this._format.align = TextFormatAlign.LEFT;
        this._text.defaultTextFormat = this._format;
        this._text.wordWrap = true;
        this._text.multiline = true;
        this._text.embedFonts = true;
        this._text.cacheAsBitmap = true;
        this._text.condenseWhite = true;
        this._text.styleSheet = GlobalPlayer.style;
        this.addChild(this._text);

        this._loader = new URLLoader();
        this._loader.addEventListener(Event.COMPLETE, onOk);
        this._loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
        this._loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
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
        @param  bg  background color (empty string for no bg)
        @param  align   text alignment
    **/
    public function setFormat(font:String, size:Int, color:String, bold:Bool, italic:Bool, leading:Int, spacing:Float, bg:String, align:String):Void {
        #if !air
            this._format.font = font;
            this._format.size = size;
            this._format.color = Std.parseInt(color);
            this._format.bold = bold;
            this._format.italic = italic;
            this._format.leading = leading;
            this._format.letterSpacing = spacing;
            switch (align) {
                case 'right':
                    this._format.align = TextFormatAlign.RIGHT;
                case 'center':
                    this._format.align = TextFormatAlign.CENTER;
                case 'justify':
                    this._format.align = TextFormatAlign.JUSTIFY;
                default:
                    this._format.align = TextFormatAlign.LEFT;
            }
            this._text.defaultTextFormat = this._format;
        #end
        if (bg == '') {
            this._text.background = false;
        } else {
            this._text.backgroundColor = Std.parseInt(bg);
            this._text.background = true;
        }
    }

    /**
        Sets the text field actual size.
        @param  wd  the field width
        @param  ht' the field height
    **/
    public function setTextSize(wd:Float, ht:Float):Void {
        this._text.width = this.oWidth = wd;
        this._text.height = this.oHeight = ht;
        this._text.scrollV = this._scrollPos;
    }

    /**
        Scrolls a text.
        @param  val    scroll direction
    **/
    public function textScroll(val:Int):Void {
        switch (val) {
            case 1:
                if (this._scrollPos < this._text.maxScrollV) this._scrollPos = this._text.scrollV = this._scrollPos + 1;
            case -1:
                if (this._scrollPos > 0) this._scrollPos = this._text.scrollV = this._scrollPos - 1;
            case 0:
                this._scrollPos = this._text.scrollV = 0;
            case 2:
                this._scrollPos = this._text.scrollV = this._text.maxScrollV;
        }
    }

    /**
        Sets the current text.
        @param  txt the new text (html-formatted)
    **/
    public function setText(txt:String):Void {
        txt = GlobalPlayer.parser.parseString(txt);
        this._text.htmlText = txt;
        this._scrollPos = this._text.scrollV = 0;
    }

    /**
        Gets the current text.
        @return the current text
    **/
    public function getText():String {
        return (this._text.text);
    }

    /**
        Loads an html text file.
        @param  media path to the html file
    **/
    public function load(media:String):Void {
        media = StringTools.replace(media, (GlobalPlayer.path + 'media/html/'), '');
        var path:String = GlobalPlayer.parser.parsePath(GlobalPlayer.path + 'media/html/' + media);
        this._loader.load(new URLRequest(path));
    }

    /**
        Releases resources used by the object.
    **/
    override public function kill():Void {
        super.kill();
        this._loader.removeEventListener(Event.COMPLETE, onOk);
        this._loader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
        this._loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
        this._loader = null;
        this._text = null;
        this._format = null;
    }

    /**
        Text loaded.
    **/
    private function onOk(evt:Event):Void {
        var txt:String = this._loader.data;
        this._text.htmlText =  GlobalPlayer.parser.parseString(txt);
        this.oWidth = this._text.width;
        this.oHeight = this._text.height;
        this._onLoad(true);
    }

    /**
        Text load error.
    **/
    private function onError(evt:Event):Void {
        this._text.htmlText = '';
        this._onLoad(false);
    }
}