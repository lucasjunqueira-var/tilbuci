package com.tilbuci.ui.component;

/** OPENFL **/
import openfl.text.TextFormat;

/** FEATHERS UI **/
import feathers.layout.VerticalLayoutData;
import feathers.skins.RectangleSkin;
import feathers.controls.TextInput;

#if tilbuciplayer

class CodeArea extends TextInput {
    public function new(format:String) {
        super();
    }
}

#else

/** MOONSHINE **/
import moonshine.editor.text.TextEditor;
import moonshine.editor.text.syntax.format.SyntaxFontSettings;
import moonshine.editor.text.syntax.format.SyntaxColorSettings;
import moonshine.editor.text.syntax.parser.ILineParser;
import moonshine.editor.text.syntax.format.JSSyntaxFormatBuilder;
import moonshine.editor.text.syntax.parser.JSLineParser;
import moonshine.editor.text.syntax.format.CSSSyntaxFormatBuilder;
import moonshine.editor.text.syntax.parser.CSSLineParser;
import moonshine.editor.text.utils.AutoClosingPair;
import moonshine.editor.text.lines.TextLineRenderer;

class CodeArea extends TextEditor {

    private var _tparser:ILineParser;

    private var _fontSettings:SyntaxFontSettings;

    private var _colorSettings:SyntaxColorSettings;

    public function new(format:String) {
        super();
        this.layoutData = new VerticalLayoutData();

        this._fontSettings = new SyntaxFontSettings();
        this._colorSettings = SyntaxColorSettings.monokai();
        var formats:Map<Int, TextFormat> = [];
        var brackets:Array<Array<String>> = null;
        var autoClosingPairs:Array<AutoClosingPair> = null;
        var lineComment:String = null;
        var blockComment:Array<String> = null;

        switch (format) {
            case 'js':
                this._tparser = new JSLineParser();
                var jsfbuilder:JSSyntaxFormatBuilder = new JSSyntaxFormatBuilder();
                jsfbuilder.setFontSettings(this._fontSettings);
                jsfbuilder.setColorSettings(this._colorSettings);
                formats = jsfbuilder.build();
                brackets = [["{", "}"], ["[", "]"], ["(", ")"]];
                autoClosingPairs = [
					new AutoClosingPair("{", "}"),
					new AutoClosingPair("[", "]"),
					new AutoClosingPair("(", ")"),
					new AutoClosingPair("'", "'"),
					new AutoClosingPair("\"", "\""),
					new AutoClosingPair("`", "`")
				];
                this.brackets = brackets;
                this.autoClosingPairs = autoClosingPairs;
                this.lineComment = lineComment;
                this.blockComment = blockComment;
                this.setParserAndTextStyles(this._tparser, formats);

            case 'css':
                this._tparser = new CSSLineParser();
                var cssfbuilder:CSSSyntaxFormatBuilder = new CSSSyntaxFormatBuilder();
                cssfbuilder.setFontSettings(this._fontSettings);
                cssfbuilder.setColorSettings(this._colorSettings);
                formats = cssfbuilder.build();
                brackets = [["{", "}"], ["[", "]"], ["(", ")"]];
                autoClosingPairs = [
					new AutoClosingPair("{", "}"),
					new AutoClosingPair("[", "]"),
					new AutoClosingPair("(", ")"),
					new AutoClosingPair("'", "'"),
					new AutoClosingPair("\"", "\"")
				];
                blockComment = ["/*", "*/"];
                this.brackets = brackets;
                this.autoClosingPairs = autoClosingPairs;
                this.lineComment = lineComment;
                this.blockComment = blockComment;
                this.setParserAndTextStyles(this._tparser, formats);
        }

        this.backgroundSkin = new RectangleSkin(SolidColor(this._colorSettings.backgroundColor));
        this.textLineRendererFactory = () -> {
			var textLineRenderer = new TextLineRenderer();
			textLineRenderer.backgroundSkin = new RectangleSkin(SolidColor(this._colorSettings.backgroundColor));
			textLineRenderer.gutterBackgroundSkin = new RectangleSkin(SolidColor(this._colorSettings.backgroundColor));
			//textLineRenderer.selectedTextBackgroundSkin = new RectangleSkin(SolidColor(this._colorSettings.selectionBackgroundColor, this._colorSettings.selectionBackgroundAlpha));
			//textLineRenderer.selectedTextBackgroundSkin = new RectangleSkin(SolidColor(this._colorSettings.selectionUnfocusedBackgroundColor, this._colorSettings.selectionUnfocusedBackgroundAlpha));
			textLineRenderer.focusedBackgroundSkin = new RectangleSkin(SolidColor(this._colorSettings.focusedLineBackgroundColor));
			textLineRenderer.debuggerStoppedBackgroundSkin = new RectangleSkin(SolidColor(this._colorSettings.backgroundColor));
			textLineRenderer.searchResultBackgroundSkinFactory = () -> {
				return new RectangleSkin(SolidColor(this._colorSettings.searchResultBackgroundColor));
			}
			return textLineRenderer;
		}
    }

}

#end