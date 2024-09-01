package com.tilbuci.ui;

/** FEATHERS UI **/
import feathers.themes.steel.SteelTheme;

/** TILBUCI **/
import com.tilbuci.statictools.StringStatic;

class PlayerTheme extends SteelTheme {

    public var headerFontName:Null<String>;

    public var headerTextColor:Null<Int>;

    public var footerFillColor:Null<Int>;

    public var listBackground:Null<Int>;

    public var listItemBackground:Null<Int>;

    public var listItemFont:Null<Int>;

    public var headerBackground(get, null):Null<Int>;
    private function get_headerBackground():Null<Int> { return (this.headerFillColor); }

    public var headerSize(get, null):Int;
    private function get_headerSize():Int { return(this.headerFontSize); }

    public var headerFont(get, null):String;
    private function get_headerFont():String { if (this.headerFontName == null) return ('_sans'); else return(this.headerFontName); }

    public var headerFontColor(get, null):Int;
    private function get_headerFontColor():Int { if (this.headerTextColor == null) return (0xFFFFFF); else return(this.headerTextColor); }

    public var windowBackground(get, null):Null<Int>;
    private function get_windowBackground():Null<Int> { return (this.rootFillColor); }

    public var windowFontName(get, null):String;
    private function get_windowFontName():String { return(this.fontName); }

    public var windowFontSize(get, null):Int;
    private function get_windowFontSize():Int { return(this.fontSize); }

    public function new(sets:String) {
        super();
        this.darkMode = true;
        var json:Dynamic = StringStatic.jsonParse(sets);
        if (json != false) {
            for (n in Reflect.fields(json)) {
                switch (n) {
                    case 'themeColor': this.setColor(n, json);
                    case 'offsetThemeColor': this.setColor(n, json);
                    case 'rootFillColor': this.setColor(n, json);
                    case 'controlFillColor1': this.setColor(n, json);
                    case 'controlFillColor2': this.setColor(n, json);
                    case 'controlDisabledFillColor': this.setColor(n, json);
                    case 'scrollBarThumbFillColor': this.setColor(n, json);
                    case 'scrollBarThumbDisabledFillColor': this.setColor(n, json);
                    case 'insetFillColor': this.setColor(n, json);
                    case 'disabledInsetFillColor': this.setColor(n, json);
                    case 'disabledInsetBorderColor': this.setColor(n, json);
                    case 'selectedInsetBorderColor': this.setColor(n, json);
                    case 'activeFillBorderColor': this.setColor(n, json);
                    case 'selectedBorderColor': this.setColor(n, json);
                    case 'insetBorderColor': this.setColor(n, json);
                    case 'focusBorderColor': this.setColor(n, json);
                    case 'containerFillColor': this.setColor(n, json);
                    case 'headerFillColor': this.setColor(n, json);
                    case 'overlayFillColor': this.setColor(n, json);
                    case 'subHeadingFillColor': this.setColor(n, json);
                    case 'dangerFillColor': this.setColor(n, json);
                    case 'offsetDangerFillColor': this.setColor(n, json);
                    case 'dangerBorderColor': this.setColor(n, json);
                    case 'borderColor': this.setColor(n, json);
                    case 'dividerColor': this.setColor(n, json);
                    case 'subHeadingDividerColor': this.setColor(n, json);
                    case 'textColor': this.setColor(n, json);
                    case 'disabledTextColor': this.setColor(n, json);
                    case 'secondaryTextColor': this.setColor(n, json);
                    case 'dangerTextColor': this.setColor(n, json);
                    case 'fontSize': this.setColor(n, json);
                    case 'fontName': this.fontName = Reflect.field(json, n);
                    case 'headerFontSize': this.setColor(n, json);
                    case 'headerFontName': this.headerFontName = Std.string(Reflect.field(json, n));
                    case 'headerTextColor': this.setColor(n, json);
                    case 'footerFillColor': this.setColor(n, json);
                    case 'listBackground': this.setColor(n, json);
                    case 'listItemBackground': this.setColor(n, json);
                    case 'listItemFont': this.setColor(n, json);
                }
            }
        }
    }

    private function setColor(name:String, json:Dynamic):Void {
        var color:Int = Std.parseInt(Reflect.field(json, name));
        if (color != null) Reflect.setField(this, name, color);
    }
}