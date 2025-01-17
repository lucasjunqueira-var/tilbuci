/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.event;

/** OPENFL **/
import openfl.events.Event;

/**
    General tilbuci related events.
**/
class TilBuciEvent extends Event {

    /** CONSTANTS **/

    /**
        movie loaded
    **/
    public static inline var MOVIE_LOADED:String = 'movie_loaded';

    /**
        scene loaded
    **/
    public static inline var SCENE_LOADED:String = 'scene_loaded';

    /**
        custom event
    **/
    public static inline var EVENT:String = 'event';

    /** VARIABLES **/

    /**
        event information
    **/
    public var info:Map<String, String>;

    /**
        Constructor.
        @param  type    the event type
        @param  info    event extra information
        @param  bubbles participates in the bubbling stage of the event flow?
        @param  cancelable  event object can be canceled?
    **/
    public function new(type:String, info:Map<String, String> = null, bubbles:Bool = false, cancelable:Bool = false) {
        super(type, bubbles, cancelable);
        this.info = info;
    }

}