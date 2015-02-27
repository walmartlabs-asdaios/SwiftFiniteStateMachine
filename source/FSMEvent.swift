//
//  FSMEvent.swift
//  SwiftFiniteStateMachine
//
//  Created by Douglas Sjoquist on 2/26/15.
//  Copyright (c) 2015 Ivy Gulch LLC. All rights reserved.
//

import Foundation

typealias kFSMWillFireEventClosure = (FSMEvent, FSMTransition, AnyObject?) -> AnyObject?
typealias kFSMDidFireEventClosure = (FSMEvent, FSMTransition, AnyObject?) -> AnyObject?
typealias kFSMEventTimeoutClosure = (FSMEvent, FSMTransition) -> Void

class FSMEvent: Equatable {
    /**
    * The unique identifier within the state machine instance.
    */
    let name: String

    /**
    * The instance of the finite state machine this state is attached to
    */
    let finiteStateMachine: FSMFiniteStateMachine

    /**
    * An array of FSMState instances, the state machine instance must be in one of these
    * states before this event can be fired.
    */
    let sources: [FSMState]

    /**
    * An FSMState instances that is the resulting state of a successful firing of the event.
    */
    let destination: FSMState

    /**
    * The timeout for this event, defaults to kFSMDefaultEventTimeout (currently 10.0 seconds)
    */
    let eventTimeout: NSTimeInterval

    /**
    * This optional closure is called after the transition process begins,
    * but before the current state is changed
    */
    var willFireEvent:kFSMWillFireEventClosure?

    /**
    * This optional closure is called before the transition process completes,
    * after the current state is changed
    */
    var didFireEvent:kFSMDidFireEventClosure?

    /**
    * This optional closure is called after the event times out, the result of the
    * event will be a rejection error -- there is no ability to retry from this point.
    */
    var eventDidTimeout:kFSMEventTimeoutClosure?


    // MARK: - interface

    init(_ name : String, sources:[FSMState], destination:FSMState, finiteStateMachine: FSMFiniteStateMachine) {
        self.name = name
        self.sources = sources
        self.destination = destination
        self.finiteStateMachine = finiteStateMachine
        self.eventTimeout = kFSMDefaultEventTimeout
    }

    func startTimeoutTimerWithTransition(transition:FSMTransition, promises:[Promise]) {

    }

    func stopTimeoutTimer() {
        
    }


    // MARK: - implementation

    var description : String {
        return "FSMEvent: \(name)"
    }

    func willFireEventWithTransition(transition:FSMTransition, value:AnyObject?) -> Promise {
        var response:AnyObject? = value
        if let willFireEvent = willFireEvent? {
            response = willFireEvent(self,transition,value)
        }
        return Promise.valueAsPromise(response)
    }

    func didFireEventWithTransition(transition:FSMTransition, value:AnyObject?) -> Promise {
        var response:AnyObject? = value
        if let didFireEvent = didFireEvent? {
            response = didFireEvent(self,transition,value)
        }
        return Promise.valueAsPromise(response)
    }

}

func ==(lhs: FSMEvent, rhs: FSMEvent) -> Bool {
    return (lhs.name == rhs.name) && (lhs.finiteStateMachine == rhs.finiteStateMachine)
}

let kFSMDefaultEventTimeout:NSTimeInterval = 10.0
