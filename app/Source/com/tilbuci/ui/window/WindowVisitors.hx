package com.tilbuci.ui.window;

/** OPENFL **/
import com.tilbuci.data.GlobalPlayer;
import openfl.text.TextField;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.text.TextFieldAutoSize;

/** FEATHERS UI **/
import feathers.controls.Label;
import feathers.events.TriggerEvent;
import feathers.core.PopUpManager;

/** TILBUCI **/
import com.tilbuci.ui.window.PopupWindow;
import com.tilbuci.data.BuildInfo;
import com.tilbuci.statictools.StringStatic;
import com.tilbuci.data.Global;
import com.tilbuci.font.EmbedFont;
import com.tilbuci.data.DataLoader;

class WindowVisitors extends PopupWindow {

    /**
        selected visitor
    **/
    private var _selected:VisitorData;

    /**
        selected group
    **/
    private var _group:VsGroupInformation;

    /**
        Constructor.
        @param  ac  the menu action mehtod
        @param  build   Tilbuci build information
    **/
    public function new(ac:Dynamic, build:BuildInfo) {

        // creating window
        super(ac, Global.ln.get('window-visitors-title'), 1000, 560, true, true);

        // visitors list
        this.ui.createHContainer('listfilter');
        this.ui.createTInput('listfilter', '', '', this.ui.hcontainers['listfilter'], false);
        this.ui.createButton('listfilter', Global.ln.get('window-visitors-list-btfilter'), onListVisitor, this.ui.hcontainers['listfilter'], false);
        this.addForm(Global.ln.get('window-visitors-list-title'), this.ui.createColumnHolder('visitors',
            this.ui.forge('visitors-left', [
                { tp: 'Label', id: 'list', tx: Global.ln.get('window-visitors-list'), vr: '' }, 
                { tp: 'List', id: 'list', vl: [ ], sl: '', ht: 353 }, 
                { tp: 'Button', id: 'list', tx: Global.ln.get('window-visitors-list-button'), ac: this.onSelectVisitor },
                { tp: 'Spacer', id: 'list', ht: 20, ln: true }, 
                { tp: 'Custom', cont: this.ui.hcontainers['listfilter'] }
            ]), 
            this.ui.forge('visitors-right', [
                { tp: 'Label', id: 'visitoremail', tx: Global.ln.get('window-visitors-list-email'), vr: '' }, 
                { tp: 'TInput', id: 'visitoremail', tx: '', vr: ''}, 
                { tp: 'Label', id: 'visitorcreated', tx: Global.ln.get('window-visitors-list-created'), vr: '' }, 
                { tp: 'TInput', id: 'visitorcreated', tx: '', vr: ''}, 
                { tp: 'Label', id: 'visitorlast', tx: Global.ln.get('window-visitors-list-last'), vr: '' }, 
                { tp: 'TInput', id: 'visitorlast', tx: '', vr: ''}, 
                { tp: 'Label', id: 'visitormovies', tx: Global.ln.get('window-visitors-list-movies'), vr: '' }, 
                { tp: 'TInput', id: 'visitormovies', tx: '', vr: ''}, 
                { tp: 'Label', id: 'visitorstates', tx: Global.ln.get('window-visitors-list-states'), vr: '' }, 
                { tp: 'TInput', id: 'visitorstates', tx: '', vr: ''}, 
                { tp: 'Label', id: 'visitordata', tx: Global.ln.get('window-visitors-list-data'), vr: '' }, 
                { tp: 'TInput', id: 'visitordata', tx: '', vr: ''}, 
                { tp: 'Label', id: 'visitorgroups', tx: Global.ln.get('window-visitors-list-groups'), vr: '' }, 
                { tp: 'TInput', id: 'visitorgroups', tx: '', vr: ''}, 
                { tp: 'Spacer', id: 'visitor', ht: 26, ln: true }, 
                { tp: 'Button', id: 'rmvisitor', tx: Global.ln.get('window-visitors-list-rmvisitor'), ac: this.onRemoveVisitor },
                { tp: 'Button', id: 'blvisitor', tx: Global.ln.get('window-visitors-list-blvisitor'), ac: this.onBlockVisitor },
            ])
        ));
        this.ui.hcontainers['listfilter'].setWidth(460);
        this.ui.setListToIcon('list');
        //this.ui.inputs['visitoremail'].enabled = false;
        this.ui.inputs['visitorcreated'].enabled = false;
        this.ui.inputs['visitorlast'].enabled = false;
        this.ui.inputs['visitormovies'].enabled = false;
        this.ui.inputs['visitorstates'].enabled = false;
        this.ui.inputs['visitordata'].enabled = false;
        this.ui.inputs['visitordata'].enabled = false;
        this.ui.inputs['visitorgroups'].enabled = false;

        // grups
        this.ui.createHContainer('creategr');
        this.ui.createTInput('creategr', '', '', this.ui.hcontainers['creategr'], false);
        this.ui.createButton('creategr', Global.ln.get('window-visitors-creategrbt'), onCreateGroup, this.ui.hcontainers['creategr'], false);
        this.ui.createHContainer('grvsadd');
        this.ui.createTInput('grvsadd', '', '', this.ui.hcontainers['grvsadd'], false);
        this.ui.createButton('grvsadd', Global.ln.get('window-visitors-grvsadd'), onAddVisitor, this.ui.hcontainers['grvsadd'], false);
        this.addForm(Global.ln.get('window-visitors-groups-title'), this.ui.createColumnHolder('groups',
            this.ui.forge('groups-left', [
                { tp: 'Label', id: 'grlist', tx: Global.ln.get('window-visitors-grlist'), vr: '' }, 
                { tp: 'List', id: 'grlist', vl: [ ], sl: '', ht: 323 }, 
                { tp: 'Button', id: 'showgroup', tx: Global.ln.get('window-visitors-showgroup'), ac: this.onShowGroup },
                { tp: 'Button', id: 'rmgroup', tx: Global.ln.get('window-visitors-removegrbt'), ac: this.onRemoveGroup },
                { tp: 'Spacer', id: 'grlist', ht: 20, ln: true }, 
                { tp: 'Custom', cont: this.ui.hcontainers['creategr'] }
            ]),
            this.ui.forge('groups-right', [
                { tp: 'Label', id: 'grname', tx: Global.ln.get('window-visitors-grname'), vr: '' }, 
                { tp: 'TInput', id: 'grname', tx: '', vr: ''}, 
                { tp: 'Button', id: 'grnamechange', tx: Global.ln.get('window-visitors-grnamechange'), ac: this.onGroupNameChange },
                { tp: 'Spacer', id: 'grvisitors', ht: 10, ln: false }, 
                { tp: 'Label', id: 'grvisitors', tx: Global.ln.get('window-visitors-grvisitors'), vr: '' }, 
                { tp: 'List', id: 'grvisitors', vl: [ ], sl: '', ht: 280 }, 
                { tp: 'Button', id: 'grvisitors', tx: Global.ln.get('window-visitors-grvsremove'), ac: this.onRemoveVisitorGroup },
                { tp: 'Custom', cont: this.ui.hcontainers['grvsadd'] }
            ])
        ));
        this.ui.hcontainers['creategr'].setWidth(460);
        this.ui.hcontainers['grvsadd'].setWidth(460);
        this.ui.setListToIcon('grlist');

        // events
        this.addForm(Global.ln.get('window-visitors-event-title'), this.ui.forge('event', [
            { tp: 'Label', id: 'evabout', tx: Global.ln.get('window-visitors-event-about'), vr: '' }, 
            { tp: 'Label', id: 'evmovie', tx: Global.ln.get('window-visitors-event-movie'), vr: Label.VARIANT_DETAIL }, 
            { tp: 'Select', id: 'evmovie', vl: [ ], sl: null }, 
            { tp: 'Label', id: 'evname', tx: Global.ln.get('window-visitors-event-name'), vr: Label.VARIANT_DETAIL }, 
            { tp: 'TInput', id: 'evname', tx: '', vr: ''},  
            { tp: 'Button', id: 'evexport', tx: Global.ln.get('window-visitors-event-export'), ac: this.onExportEvents },
            { tp: 'Spacer', id: 'evexport', ht: 90, ln: true },
            { tp: 'Label', id: 'evclear', tx: Global.ln.get('window-visitors-event-clear'), vr: '' }, 
            { tp: 'Label', id: 'clearmovie', tx: Global.ln.get('window-visitors-event-movie'), vr: Label.VARIANT_DETAIL }, 
            { tp: 'Select', id: 'clearmovie', vl: [ ], sl: null }, 
            { tp: 'Label', id: 'clearname', tx: Global.ln.get('window-visitors-event-clearname'), vr: Label.VARIANT_DETAIL }, 
            { tp: 'TInput', id: 'clearname', tx: '', vr: ''},  
            { tp: 'Label', id: 'clearwhen', tx: Global.ln.get('window-visitors-event-clearwhen'), vr: Label.VARIANT_DETAIL }, 
            { tp: 'Select', id: 'clearwhen', vl: [
                { text: Global.ln.get('window-visitors-event-clearyear'), value: '-1year' }, 
                { text: Global.ln.get('window-visitors-event-clear6month'), value: '-6months' }, 
                { text: Global.ln.get('window-visitors-event-clear3month'), value: '-3months' }, 
                { text: Global.ln.get('window-visitors-event-clear1month'), value: '-1month' }, 
                { text: Global.ln.get('window-visitors-event-clearall'), value: 'now' }
            ], sl: '-1year' }, 
            { tp: 'Button', id: 'evclear', tx: Global.ln.get('window-visitors-event-clearbutton'), ac: this.onRemoveEvents },
        ]));
        this.ui.labels['evclear'].wordWrap = true;

        // CORS
        this.addForm(Global.ln.get('window-visitors-cors-title'), this.ui.forge('cors', [
            { tp: 'Label', id: 'corsabout', tx: Global.ln.get('window-visitors-cors-about'), vr: '' }, 
            { tp: 'Label', id: 'corsallowed', tx: Global.ln.get('window-visitors-cors-allowed'), vr: Label.VARIANT_DETAIL }, 
            { tp: 'List', id: 'corsallowed', vl: [ ], sl: '', ht: 240 }, 
            { tp: 'Button', id: 'corsrm', tx: Global.ln.get('window-visitors-cors-btremove'), ac: this.onRemoveCors },
            { tp: 'Spacer', id: 'corsrm', ht: 15, ln: false }, 
            { tp: 'Label', id: 'corsadd', tx: Global.ln.get('window-visitors-cors-add'), vr: Label.VARIANT_DETAIL }, 
            { tp: 'TInput', id: 'corsadd', tx: '', vr: ''}, 
            { tp: 'Button', id: 'corsadd', tx: Global.ln.get('window-visitors-cors-btadd'), ac: this.onAddCors },
        ]));
        this.ui.labels['corsabout'].wordWrap = true;

        // adjusting sizes
        this.redraw();
    }

    /**
        Window action to run on display.
    **/
    override public function acStart():Void {
        if (Global.userLevel == 0) {
            this.onListVisitor(null);
        } else {
            this.ui.createWarning(Global.ln.get('window-visitors-title'), Global.ln.get('window-visitors-noaccess'), 300, 180, this.stage);
            PopUpManager.removePopUp(this);
        }
    }

    /**
        Releases resources used by the object.
    **/
    override public function kill():Void {
        super.kill();
    }

    /** PRVATE METHODS **/

    /**
        Checks visitor information.
    **/
    private function onListVisitor(evt:TriggerEvent):Void {
        this._selected = null;
        this._group = null;
        this.ui.inputs['listfilter'].text = '';
        this.ui.inputs['visitoremail'].text = '';
        this.ui.inputs['visitorcreated'].text = '';
        this.ui.inputs['visitorlast'].text = '';
        this.ui.inputs['visitormovies'].text = '';
        this.ui.inputs['visitorstates'].text = '';
        this.ui.inputs['visitordata'].text = '';
        this.ui.inputs['visitorgroups'].text = '';
        this.ui.inputs['grname'].text = '';
        this.ui.inputs['creategr'].text = '';
        this.ui.inputs['grvsadd'].text = '';
        this.ui.inputs['evname'].text = '';
        this.ui.inputs['clearname'].text = '';
        this.ui.setListSelectValue('list', null);
        this.ui.setListValues('list', [ ]);
        this.ui.setListSelectValue('grlist', null);
        this.ui.setListValues('grlist', [ ]);
        this.ui.setListSelectValue('grvisitors', null);
        this.ui.setListValues('grvisitors', [ ]);
        this.ui.setSelectValue('evmovie', null);
        this.ui.setSelectOptions('evmovie', [ ]);
        this.ui.setSelectValue('clearmovie', null);
        this.ui.setSelectOptions('clearmovie', [ ]);
        this.ui.setSelectValue('clearwhen', '-1year');
        this.ui.setListSelectValue('corsallowed', null);
        this.ui.setListValues('corsallowed', [ ]);
        Global.ws.send('Visitor/List', [
            'filter' => this.ui.inputs['listfilter'].text
        ], onListVisitorReturn);
    }

    /**
        The visitor list was received.
    **/
    private function onListVisitorReturn(ok:Bool, ld:DataLoader):Void {
        if (ok) {
            if (ld.map['e'] == 0) {
                var vislist:Array<VisitorItem> = cast ld.map['list'];
                if (vislist.length == 0) {
                    Global.showMsg(Global.ln.get('window-visitors-listempty'));
                } else {
                    var list:Array<Dynamic> = [ ];
                    for (vs in vislist) {
                        if (vs.blocked) {
                            list.push({
                                text: vs.email, 
                                value: vs.email, 
                                user: Global.ln.get('window-visitors-lastaccess') + ' ' + vs.last,
                                asset: 'iconLock', 
                            });
                        } else {
                            list.push({
                                text: vs.email, 
                                value: vs.email, 
                                user: Global.ln.get('window-visitors-lastaccess') + ' ' + vs.last,
                            });
                        }
                    }
                    this.ui.setListValues('list', list);
                    var groups:Array<VisitorGroups> = cast ld.map['groups'];
                    list = [ ];
                    if (groups != null) {
                        for (gr in groups) list.push({
                            text: gr.name, 
                            value: gr.id, 
                            user: gr.visitors + ' ' + Global.ln.get('window-visitors-grvisitors'), 
                        });
                    }
                    this.ui.setListValues('grlist', list);
                    list = [ { text: Global.ln.get('window-visitors-event-movieall'), value: '' } ];
                    for (mn in Reflect.fields(ld.map['movies'])) {
                        var mv:Dynamic = Reflect.field(ld.map['movies'], mn);
                        list.push({
                            text: Reflect.field(mv, 'title'), 
                            value: Reflect.field(mv, 'id') 
                        });
                    }
                    this.ui.setSelectOptions('evmovie', list);
                    this.ui.setSelectValue('evmovie', '');
                    this.ui.setSelectOptions('clearmovie', list);
                    this.ui.setSelectValue('clearmovie', '');
                    var cors:Array<String> = cast ld.map['cors'];
                    list = [ ];
                    if (cors != null) {
                        for (cr in cors) {
                            list.push({
                                text: cr, 
                                value: cr
                            });
                        }
                    }
                    this.ui.setListValues('corsallowed', list);
                }
            } else {
                this.ui.createWarning(Global.ln.get('window-visitors-title'), Global.ln.get('window-visitors-listerror'), 300, 180, this.stage);    
            }
        } else {
            this.ui.createWarning(Global.ln.get('window-visitors-title'), Global.ln.get('window-visitors-listerror'), 300, 180, this.stage);
        }
    }

    /**
        Checks visitor information.
    **/
    private function onSelectVisitor(evt:TriggerEvent):Void {
        if (this.ui.lists['list'].selectedItem != null) {
            Global.ws.send('Visitor/Select', [
                'email' => this.ui.lists['list'].selectedItem.value
            ], onVisitorSelected);
        }
    }

    /**
        A visitor was selected.
    **/
    private function onVisitorSelected(ok:Bool, ld:DataLoader):Void {
        this._selected = null;
        this.ui.inputs['visitoremail'].text = '';
        this.ui.inputs['visitorcreated'].text = '';
        this.ui.inputs['visitorlast'].text = '';
        this.ui.inputs['visitormovies'].text = '';
        this.ui.inputs['visitorstates'].text = '';
        this.ui.inputs['visitordata'].text = '';
        this.ui.inputs['visitorgroups'].text = '';
        if (ok) {
            if (ld.map['e'] != 0) {
                this.ui.createWarning(Global.ln.get('window-visitors-title'), Global.ln.get('window-visitors-erselect'), 300, 180, this.stage);
            } else {
                this._selected = cast ld.map['data'];
                if (this._selected == null) {
                    this.ui.createWarning(Global.ln.get('window-visitors-title'), Global.ln.get('window-visitors-erselect'), 300, 180, this.stage);
                } else {
                    this.ui.inputs['visitoremail'].text = this._selected.email;
                    this.ui.inputs['visitorcreated'].text = this._selected.created;
                    this.ui.inputs['visitorlast'].text = this._selected.last;
                    this.ui.inputs['visitormovies'].text = Std.string(this._selected.movies);
                    this.ui.inputs['visitorstates'].text = Std.string(this._selected.states);
                    this.ui.inputs['visitordata'].text = Std.string(this._selected.data);
                    this.ui.inputs['visitorgroups'].text = Std.string(this._selected.groups.length);
                    if (this._selected.blocked) {
                        this.ui.buttons['blvisitor'].text = Global.ln.get('window-visitors-list-unblvisitor');
                    } else {
                        this.ui.buttons['blvisitor'].text = Global.ln.get('window-visitors-list-blvisitor');
                    }
                }
            }
        } else {
            this.ui.createWarning(Global.ln.get('window-visitors-title'), Global.ln.get('window-visitors-erselect'), 300, 180, this.stage);
        }
    }

    /**
        Removes a visitor information.
    **/
    private function onRemoveVisitor(evt:TriggerEvent):Void {
        if (this._selected != null) {
            this.ui.createConfirm(Global.ln.get('window-visitors-title'), Global.ln.get('window-visitors-list-rmvisitorconf'), 320, 230, onRemoveConfirm, Global.ln.get('default-ok'), Global.ln.get('default-cancel'), this.stage);
        }
    }

    /**
        Confirm user removal.
    **/
    private function onRemoveConfirm(ok:Bool):Void {
        if ((this._selected != null) && ok) {
            Global.ws.send('Visitor/Remove', [
                'email' => this._selected.email, 
            ], onRemoveReturn);
        }
    }

    /**
        Remove action return.
    **/
    private function onRemoveReturn(ok:Bool, ld:DataLoader):Void {
        if (ok) {
            if (ld.map['e'] != 0) {
                this.ui.createWarning(Global.ln.get('window-visitors-title'), Global.ln.get('window-visitors-erset'), 300, 180, this.stage);
            } else {
                Global.showMsg(Global.ln.get('window-visitors-inforemoved'));
                this._selected = null;
                this.ui.inputs['visitoremail'].text = '';
                this.ui.inputs['visitorcreated'].text = '';
                this.ui.inputs['visitorlast'].text = '';
                this.ui.inputs['visitormovies'].text = '';
                this.ui.inputs['visitorstates'].text = '';
                this.ui.inputs['visitordata'].text = '';
                this.ui.inputs['visitorgroups'].text = '';
                this.ui.inputs['creategr'].text = '';
                this.onListVisitor(null);
            }
        } else {
            this.ui.createWarning(Global.ln.get('window-visitors-title'), Global.ln.get('window-visitors-erset'), 300, 180, this.stage);
        }
    }

    /**
        Blocks a visitor.
    **/
    private function onBlockVisitor(evt:TriggerEvent):Void {
        if (this._selected != null) {
            if (this._selected.blocked) {
                this.ui.createConfirm(Global.ln.get('window-visitors-title'), Global.ln.get('window-visitors-list-unblvisitorconf'), 300, 230, onBlockConfirm, Global.ln.get('default-ok'), Global.ln.get('default-cancel'), this.stage);
            } else {
                this.ui.createConfirm(Global.ln.get('window-visitors-title'), Global.ln.get('window-visitors-list-blvisitorconf'), 300, 230, onBlockConfirm, Global.ln.get('default-ok'), Global.ln.get('default-cancel'), this.stage);
            }
        }
    }

    /**
        Confirm user block.
    **/
    private function onBlockConfirm(ok:Bool):Void {
        if ((this._selected != null) && ok) {
            Global.ws.send('Visitor/Block', [
                'email' => this._selected.email, 
            ], onBlockReturn);
        }
    }

    /**
        Block/release action return.
    **/
    private function onBlockReturn(ok:Bool, ld:DataLoader):Void {
        if (ok) {
            if (ld.map['e'] != 0) {
                this.ui.createWarning(Global.ln.get('window-visitors-title'), Global.ln.get('window-visitors-erset'), 300, 180, this.stage);
            } else {
                Global.showMsg(Global.ln.get('window-visitors-infoset'));
                this._selected = null;
                this.ui.inputs['visitoremail'].text = '';
                this.ui.inputs['visitorcreated'].text = '';
                this.ui.inputs['visitorlast'].text = '';
                this.ui.inputs['visitormovies'].text = '';
                this.ui.inputs['visitorstates'].text = '';
                this.ui.inputs['visitordata'].text = '';
                this.ui.inputs['visitorgroups'].text = '';
                this.onListVisitor(null);
            }
        } else {
            this.ui.createWarning(Global.ln.get('window-visitors-title'), Global.ln.get('window-visitors-erset'), 300, 180, this.stage);
        }
    }

    /**
        Creates a group.
    **/
    private function onCreateGroup(evt:TriggerEvent):Void {
        if (this.ui.inputs['creategr'].text.length >= 5) {
            Global.ws.send('Visitor/CreateGroup', [
                'name' => this.ui.inputs['creategr'].text, 
            ], onCreateGroupReturn);
        }
    }

    /**
        Removes a group.
    **/
    private function onRemoveGroup(evt:TriggerEvent):Void {
        if (this.ui.lists['grlist'].selectedItem != null) {
            this.ui.createConfirm(Global.ln.get('window-visitors-title'), Global.ln.get('window-visitors-grouprmconfirm'), 300, 230, onRemoveGroupConfirm, Global.ln.get('default-ok'), Global.ln.get('default-cancel'), this.stage);
        }
    }

    /**
        Remove group confirmation.
    **/
    private function onRemoveGroupConfirm(ok:Bool):Void {
        if (ok && (this.ui.lists['grlist'].selectedItem != null)) {
            Global.ws.send('Visitor/RemoveGroup', [
                'name' => this.ui.lists['grlist'].selectedItem.text, 
                'id' => this.ui.lists['grlist'].selectedItem.value, 
            ], onRemoveGroupReturn);
        }
    }

    /**
        Create group action return.
    **/
    private function onCreateGroupReturn(ok:Bool, ld:DataLoader):Void {
        if (ok) {
            if (ld.map['e'] != 0) {
                this.ui.createWarning(Global.ln.get('window-visitors-title'), Global.ln.get('window-visitors-creatgrer'), 360, 180, this.stage);    
            } else {
                Global.showMsg(Global.ln.get('window-visitors-groupcreated'));
                this._selected = null;
                this.ui.inputs['visitoremail'].text = '';
                this.ui.inputs['visitorcreated'].text = '';
                this.ui.inputs['visitorlast'].text = '';
                this.ui.inputs['visitormovies'].text = '';
                this.ui.inputs['visitorstates'].text = '';
                this.ui.inputs['visitordata'].text = '';
                this.ui.inputs['visitorgroups'].text = '';
                this.ui.inputs['creategr'].text = '';
                this.onListVisitor(null);
            }
        } else {
            this.ui.createWarning(Global.ln.get('window-visitors-title'), Global.ln.get('window-visitors-creatgrer'), 360, 180, this.stage);
        }
    }

    /**
        Remove group action return.
    **/
    private function onRemoveGroupReturn(ok:Bool, ld:DataLoader):Void {
        if (ok) {
            if (ld.map['e'] != 0) {
                this.ui.createWarning(Global.ln.get('window-visitors-title'), Global.ln.get('window-visitors-removegrer'), 360, 180, this.stage);    
            } else {
                Global.showMsg(Global.ln.get('window-visitors-groupremoved'));
                this._selected = null;
                this.ui.inputs['visitoremail'].text = '';
                this.ui.inputs['visitorcreated'].text = '';
                this.ui.inputs['visitorlast'].text = '';
                this.ui.inputs['visitormovies'].text = '';
                this.ui.inputs['visitorstates'].text = '';
                this.ui.inputs['visitordata'].text = '';
                this.ui.inputs['visitorgroups'].text = '';
                this.ui.inputs['creategr'].text = '';
                this.onListVisitor(null);
            }
        } else {
            this.ui.createWarning(Global.ln.get('window-visitors-title'), Global.ln.get('window-visitors-removegrer'), 360, 180, this.stage);
        }
    }

    /**
        Shows a group information.
    **/
    private function onShowGroup(evt:TriggerEvent):Void {
        if (this.ui.lists['grlist'].selectedItem != null) {
            Global.ws.send('Visitor/ShowGroup', [
                'name' => this.ui.lists['grlist'].selectedItem.text, 
                'id' => this.ui.lists['grlist'].selectedItem.value, 
            ], onShowGroupReturn);
        }
    }

    /**
        Show group action return.
    **/
    private function onShowGroupReturn(ok:Bool, ld:DataLoader):Void {
        this._group = null;
        this.ui.inputs['grname'].text = '';
        this.ui.inputs['creategr'].text = '';
        this.ui.inputs['grvsadd'].text = '';
        if (ok) {
            if (ld.map['e'] != 0) {
                this.ui.createWarning(Global.ln.get('window-visitors-title'), Global.ln.get('window-visitors-showgrouper'), 360, 180, this.stage);    
            } else {
                this._group = cast ld.map['group'];
                if (this._group == null) {
                    this.ui.createWarning(Global.ln.get('window-visitors-title'), Global.ln.get('window-visitors-showgrouper'), 360, 180, this.stage);        
                } else {
                    this.ui.inputs['grname'].text = this._group.name;
                    var list:Array<Dynamic> = [ ];
                    for (vs in this._group.visitors) list.push({
                        text: vs,
                        value: vs
                    });
                    this.ui.setListValues('grvisitors', list);
                }
            }
        } else {
            this.ui.createWarning(Global.ln.get('window-visitors-title'), Global.ln.get('window-visitors-showgrouper'), 360, 180, this.stage);
        }
    }

    /**
        Changes a group name.
    **/
    private function onGroupNameChange(evt:TriggerEvent):Void {
        if ((this.ui.lists['grlist'].selectedItem != null) && (this.ui.inputs['grname'].text.length >= 5)) {
            Global.ws.send('Visitor/ChangeGroupName', [
                'name' => this.ui.lists['grlist'].selectedItem.text, 
                'id' => this.ui.lists['grlist'].selectedItem.value, 
                'new' => this.ui.inputs['grname'].text, 
            ], onGroupNameChangeReturn);
        }
    }

    /**
        Group name change action return.
    **/
    private function onGroupNameChangeReturn(ok:Bool, ld:DataLoader):Void {
        this._group = null;
        this.ui.inputs['grname'].text = '';
        this.ui.inputs['creategr'].text = '';
        this.ui.inputs['grvsadd'].text = '';
        if (ok) {
            if (ld.map['e'] != 0) {
                this.ui.createWarning(Global.ln.get('window-visitors-title'), Global.ln.get('window-visitors-namegrouper'), 360, 180, this.stage);    
            } else {
                this.onListVisitor(null);
            }
        } else {
            this.ui.createWarning(Global.ln.get('window-visitors-title'), Global.ln.get('window-visitors-namegrouper'), 360, 180, this.stage);
        }
    }

    /**
        Adds a visitor to a group.
    **/
    private function onAddVisitor(evt:TriggerEvent):Void {
        if ((this.ui.lists['grlist'].selectedItem != null) && (StringStatic.validateEmail(this.ui.inputs['grvsadd'].text))) {
            Global.ws.send('Visitor/AddGroupVisitor', [
                'name' => this.ui.lists['grlist'].selectedItem.text, 
                'id' => this.ui.lists['grlist'].selectedItem.value, 
                'visitor' => this.ui.inputs['grvsadd'].text, 
            ], onAddVisitorReturn);
        }
    }

    /**
        Add visitor action return.
    **/
    private function onAddVisitorReturn(ok:Bool, ld:DataLoader):Void {
        this._group = null;
        this.ui.inputs['grvsadd'].text = '';
        if (ok) {
            if (ld.map['e'] != 0) {
                this.ui.inputs['grname'].text = '';
                this.ui.inputs['creategr'].text = '';
                this.onListVisitor(null);
                this.ui.createWarning(Global.ln.get('window-visitors-title'), Global.ln.get('window-visitors-addvsgrer'), 360, 180, this.stage);    
            } else {
                this._group = cast ld.map['group'];
                if (this._group == null) {
                    this.ui.inputs['grname'].text = '';
                    this.ui.inputs['creategr'].text = '';
                    this.onListVisitor(null);
                    this.ui.createWarning(Global.ln.get('window-visitors-title'), Global.ln.get('window-visitors-addvsgrer'), 360, 180, this.stage);        
                } else {
                    this.ui.inputs['grname'].text = this._group.name;
                    var list:Array<Dynamic> = [ ];
                    for (vs in this._group.visitors) list.push({
                        text: vs,
                        value: vs
                    });
                    this.ui.setListValues('grvisitors', list);
                }
            }
        } else {
            this.ui.inputs['grname'].text = '';
            this.ui.inputs['creategr'].text = '';
            this.onListVisitor(null);
            this.ui.createWarning(Global.ln.get('window-visitors-title'), Global.ln.get('window-visitors-addvsgrer'), 360, 180, this.stage);
        }
    }

    /**
        Removes a visitor from a group.
    **/
    private function onRemoveVisitorGroup(evt:TriggerEvent):Void {
        if ((this.ui.lists['grlist'].selectedItem != null) && (this.ui.lists['grvisitors'].selectedItem != null)) {
            Global.ws.send('Visitor/RemoveGroupVisitor', [
                'name' => this.ui.lists['grlist'].selectedItem.text, 
                'id' => this.ui.lists['grlist'].selectedItem.value, 
                'visitor' => this.ui.lists['grvisitors'].selectedItem.value, 
            ], onRemoveVisitorGroupReturn);
        }
    }

    /**
        Remove visitor action return.
    **/
    private function onRemoveVisitorGroupReturn(ok:Bool, ld:DataLoader):Void {
        this._group = null;
        if (ok) {
            if (ld.map['e'] != 0) {
                this.ui.inputs['grname'].text = '';
                this.ui.inputs['creategr'].text = '';
                this.ui.inputs['grvsadd'].text = '';
                this.onListVisitor(null);
                this.ui.createWarning(Global.ln.get('window-visitors-title'), Global.ln.get('window-visitors-rmvsgrer'), 360, 180, this.stage);    
            } else {
                this._group = cast ld.map['group'];
                if (this._group == null) {
                    this.ui.inputs['grname'].text = '';
                    this.ui.inputs['creategr'].text = '';
                    this.ui.inputs['grvsadd'].text = '';
                    this.onListVisitor(null);
                    this.ui.createWarning(Global.ln.get('window-visitors-title'), Global.ln.get('window-visitors-rmvsgrer'), 360, 180, this.stage);        
                } else {
                    this.ui.inputs['grname'].text = this._group.name;
                    var list:Array<Dynamic> = [ ];
                    for (vs in this._group.visitors) list.push({
                        text: vs,
                        value: vs
                    });
                    this.ui.setListValues('grvisitors', list);
                }
            }
        } else {
            this.ui.inputs['grname'].text = '';
            this.ui.inputs['creategr'].text = '';
            this.ui.inputs['grvsadd'].text = '';
            this.onListVisitor(null);
            this.ui.createWarning(Global.ln.get('window-visitors-title'), Global.ln.get('window-visitors-rmvsgrer'), 360, 180, this.stage);
        }
    }

    /**
        Exporting events.
    **/
    private function onExportEvents(evt:TriggerEvent):Void {
        Global.ws.send('Visitor/ExportEvents', [
            'movie' => this.ui.selects['evmovie'].selectedItem.value, 
            'name' => this.ui.inputs['evname'].text
        ], onExportEventsReturn);
    }

    /**
        Events export action return.
    **/
    private function onExportEventsReturn(ok:Bool, ld:DataLoader):Void {
        if (ok) {
            if (ld.map['e'] == 0) {
                Global.ws.download([
                    'file' => 'events', 
                    'name' => ld.map['file']
                ]);
            } else {
                this.ui.createWarning(Global.ln.get('window-visitors-event-title'), Global.ln.get('window-visitors-event-erexport'), 360, 180, this.stage);
            }
        } else {
            this.ui.createWarning(Global.ln.get('window-visitors-event-title'), Global.ln.get('window-visitors-event-erexport'), 360, 180, this.stage);
        }
    }

    /**
        Removes events.
    **/
    private function onRemoveEvents(evt:TriggerEvent):Void {
        this.ui.createConfirm(Global.ln.get('window-visitors-event-title'), Global.ln.get('window-visitors-event-clearconfirm'), 300, 230, onRemoveEventsConfirm, Global.ln.get('default-ok'), Global.ln.get('default-cancel'), this.stage);
    }

    /**
        Remove events confirmation.
    **/
    private function onRemoveEventsConfirm(ok:Bool):Void {
        if (ok) {
            Global.ws.send('Visitor/RemoveEvents', [
                'movie' => this.ui.selects['clearmovie'].selectedItem.value, 
                'name' => this.ui.inputs['clearname'].text, 
                'date' => this.ui.selects['clearwhen'].selectedItem.value, 
            ], onRemoveEventsReturn);
        }
    }

    /**
        Events removal action return.
    **/
    private function onRemoveEventsReturn(ok:Bool, ld:DataLoader):Void {
        if (ok) {
            if (ld.map['e'] == 0) {
                this.ui.createWarning(Global.ln.get('window-visitors-event-title'), Global.ln.get('window-visitors-event-okremove'), 360, 180, this.stage);
            } else {
                this.ui.createWarning(Global.ln.get('window-visitors-event-title'), Global.ln.get('window-visitors-event-erremove'), 360, 180, this.stage);
            }
        } else {
            this.ui.createWarning(Global.ln.get('window-visitors-event-title'), Global.ln.get('window-visitors-event-erremove'), 360, 180, this.stage);
        }
    }

    /**
        Removes allowed domains.
    **/
    private function onRemoveCors(evt:TriggerEvent):Void {
        if (this.ui.lists['corsallowed'].selectedItem != null) {
            Global.ws.send('Visitor/RemoveCORS', [
                'domain' => this.ui.lists['corsallowed'].selectedItem.value
            ], onRemoveCorsReturn);
        }
    }

    /**
        Cors removal action return.
    **/
    private function onRemoveCorsReturn(ok:Bool, ld:DataLoader):Void {
        if (ok) {
            if (ld.map['e'] == 0) {
                this.onListVisitor(null);
            } else {
                this.ui.createWarning(Global.ln.get('window-visitors-cors-title'), Global.ln.get('window-visitors-cors-errorrm'), 360, 180, this.stage);
            }
        } else {
            this.ui.createWarning(Global.ln.get('window-visitors-cors-title'), Global.ln.get('window-visitors-cors-errorrm'), 360, 180, this.stage);
        }
    }

    /**
        Adds an allowed domain.
    **/
    private function onAddCors(evt:TriggerEvent):Void {
        if (this.ui.inputs['corsadd'].text.toLowerCase().substr(0, 4) == 'http') {
            Global.ws.send('Visitor/AddCORS', [
                'domain' => this.ui.inputs['corsadd'].text.toLowerCase()
            ], onAddCorsReturn);
        }
    }

    /**
        Cors add action return.
    **/
    private function onAddCorsReturn(ok:Bool, ld:DataLoader):Void {
        if (ok) {
            if (ld.map['e'] == 0) {
                this.ui.inputs['corsadd'].text = '';
                this.onListVisitor(null);
            } else {
                this.ui.createWarning(Global.ln.get('window-visitors-cors-title'), Global.ln.get('window-visitors-cors-erroradd'), 360, 180, this.stage);
            }
        } else {
            this.ui.createWarning(Global.ln.get('window-visitors-cors-title'), Global.ln.get('window-visitors-cors-erroradd'), 360, 180, this.stage);
        }
    }
    
}

typedef VisitorItem = {
    var email:String;
    var created:String;
    var last:String;
    var level:Int;
    var blocked:Bool;
};

typedef VisitorData = {
    var email:String;
    var created:String;
    var last:String;
    var movies:Int;
    var states:Int;
    var data:Int;
    var groups:Array<VisitorGroups>;
    var blocked:Bool;
};

typedef VisitorGroups = {
    var id:Int;
    var name:String;
    var visitors:Int;
};

typedef VsGroupInformation = {
    var id:Int;
    var name:String;
    var visitors:Array<String>;
};