//
//  FSMEvent.swift
//  SwiftFiniteStateMachine
//
//  Created by Douglas Sjoquist on 2/26/15.
//  Copyright (c) 2015 Ivy Gulch LLC. All rights reserved.
//

import Foundation

public typealias kFSMWillFireEventClosure = (FSMEvent, FSMTransition, AnyObject?) -> AnyObject?
public typealias kFSMDidFireEventClosure = (FSMEvent, FSMTransition, AnyObject?) -> AnyObject?
public typealias kFSMEventTimeoutClosure = (FSMEvent, FSMTransition) -> Void

@objc public class FSMEvent: Equatable {

    public class func newInstance(name : String, sources:[FSMState], destination:FSMState, finiteStateMachine: FSMFiniteStateMachine) -> FSMEvent {
        return FSMEvent(name, sources:sources, destination:destination, finiteStateMachine:finiteStateMachine)
    }

    /**
    * The unique identifier within the state machine instance.
    */
    public let name: String

    /**
    * The instance of the finite state machine this state is attached to
    */
    public weak var finiteStateMachine: FSMFiniteStateMachine?

    /**
    * An array of FSMState instances, the state machine instance must be in one of these
    * states before this event can be fired.
    */
    public let sources: [FSMState]

    /**
    * An FSMState instances that is the resulting state of a successful firing of the event.
    */
    public let destination: FSMState

    /**
    * This optional closure is called after the transition process begins,
    * but before the current state is changed
    */
    public var willFireEvent:kFSMWillFireEventClosure?

    /**
    * This optional closure is called before the transition process completes,
    * after the current state is changed
    */
    public var didFireEvent:kFSMDidFireEventClosure?

    /**
    * This optional closure is called after the event times out, the result of the
    * event will be a rejection error -- there is no ability to retry from this point.
    */
    public var eventDidTimeout:kFSMEventTimeoutClosure?

    private var timeoutTimer:NSTimer?

    // MARK: - interface

    init(_ name : String, sources:[FSMState], destination:FSMState, finiteStateMachine: FSMFiniteStateMachine) {
        self.name = name
        self.sources = sources
        self.destination = destination
        self.finiteStateMachine = finiteStateMachine
    }

    func resetTimeoutTimer(eventTimeout:NSTimeInterval, transition:FSMTransition, promises:[Promise]) {
        if eventTimeout > 0 {
            let userInfo = ["promises":promises,"transition":transition]
            timeoutTimer = NSTimer.scheduledTimerWithTimeInterval(eventTimeout, target:self, selector:"handleEventTimeout:", userInfo:userInfo, repeats:false)
        } else {
            stopTimeoutTimer();
        }
    }

    func stopTimeoutTimer() {
        timeoutTimer?.invalidate()
        timeoutTimer = nil
    }

    @objc func handleEventTimeout(timer:NSTimer) {
        let userInfo = timer.userInfo as [String:AnyObject]
        let promises = userInfo["promises"] as [Promise]
        let transition = userInfo["transition"] as FSMTransition
        stopTimeoutTimer()

        let error = NSError(domain:kFSMErrorDomain, code:kFSMErrorEventTimeout, userInfo:nil)
        for promise in promises {
            if !promise.isFulfilled {
                promise.reject(error)
            }
        }

        eventDidTimeout?(self, transition)
    }

    // MARK: - implementation

    public var description : String {
        return "FSMEvent: \(name)"
    }

    func willFireEventWithTransition(transition:FSMTransition, value:AnyObject?) -> Promise {
        var response:AnyObject? = value
        if let willFireEvent = self.willFireEvent {
            response = willFireEvent(self,transition,value)
        }
        return Promise.valueAsPromise(response)
    }

    func didFireEventWithTransition(transition:FSMTransition, value:AnyObject?) -> Promise {
        var response:AnyObject? = value
        if let didFireEvent = self.didFireEvent {
            response = didFireEvent(self,transition,value)
        }
        return Promise.valueAsPromise(response)
    }

}

public func ==(lhs: FSMEvent, rhs: FSMEvent) -> Bool {
    return (lhs.name == rhs.name) && (lhs.finiteStateMachine == rhs.finiteStateMachine)
}
