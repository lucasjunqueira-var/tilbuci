/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.plugin;

/** OPENFL **/
import openfl.events.Event;

/**
    Events of interest for plugins.
**/
class PluginEvent extends Event {

    /**
        a new movie was loaded
    **/
    public static inline var MOVIELOAD:String = 'movieload';

    /**
        a new scene was loaded
    **/
    public static inline var SCENELOAD:String = 'sceneload';

    /**
        a new keyframe was loaded
    **/
    public static inline var KEYFRAMELOAD:String = 'keyframeload';

    /**
        display area was resized
    **/
    public static inline var DISPLAYRESIZE:String = 'displayresize';

    /**
        the event-related action ran as expected?
    **/
    public var ok:Bool = true;

    /**
        additional information about the event
    **/
    public var extra:Map<String, String> = [ ];

    /**
        Constructor.
        @param  type    the event type
        @param  ok  action ran as expected?
        @param  ext    event extra information
        @param  bubbles participates in the bubbling stage of the event flow?
        @param  cancelable  event object can be canceled?
    **/
    public function new(type:String, ok:Bool = true, ext:Map<String, String> = null, bubbles:Bool = false, cancelable:Bool = false) {
        super(type, bubbles, cancelable);
        this.ok = ok;
        if (ext != null) this.extra = ext;
    }

}