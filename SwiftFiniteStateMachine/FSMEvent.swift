//
//  FSMEvent.swift
//  SwiftFiniteStateMachine
//
//  Created by Douglas Sjoquist on 2/26/15.
//  Copyright (c) 2015 Ivy Gulch LLC. All rights reserved.
//

import Foundation

public typealias FSMWillFireEventClosure = (FSMEvent, FSMTransition, AnyObject?) -> AnyObject?
public typealias FSMDidFireEventClosure = (FSMEvent, FSMTransition, AnyObject?) -> AnyObject?
public typealias FSMFireEventFailedClosure = (FSMEvent, FSMTransition, ErrorType) -> AnyObject?
public typealias FSMEventTimeoutClosure = (FSMEvent, FSMTransition) -> Void

/**
 An event represents a potential transition from one or more source states to a new
 destination state with hooks for various points along the transition.
*/
public class FSMEvent: NSObject {

    /**
     The unique identifier within the state machine instance.
     */
    public let name: String

    /**
     The instance of the finite state machine this state is attached to
     */
    public let finiteStateMachine: FSMFiniteStateMachine!

    /**
     An array of FSMState instances, the state machine instance must be in one of these
     states before this event can be fired.
     */
    public let sources: [FSMState]

    /**
     An FSMState instances that is the resulting state of a successful firing of the event.
     */
    public let destination: FSMState

    /**
     This optional closure is called after the transition process begins,
     but before the current state is changed
     */
    public var willFireEvent:FSMWillFireEventClosure?

    /**
     This optional closure is called before the transition process completes,
     after the current state is changed
     */
    public var didFireEvent:FSMDidFireEventClosure?

    /**
     This optional closure is called if the transition fails for some reason
    */
    public var fireEventFailed:FSMFireEventFailedClosure?

    /**
     This optional closure is called after the event times out, the result of the
     event will be a rejection error -- there is no ability to retry from this point.
     */
    public var eventDidTimeout:FSMEventTimeoutClosure?

    private var timeoutTimer:NSTimer?

    // MARK: - implementation

    init(_ name : String, sources:[FSMState], destination:FSMState, finiteStateMachine: FSMFiniteStateMachine) {
        self.name = name
        self.sources = sources
        self.destination = destination
        self.finiteStateMachine = finiteStateMachine
        super.init()
    }

    public override var description : String {
        return "FSMEvent: \(name)"
    }
    
    func resetTimeoutTimer(eventTimeout:NSTimeInterval, transition:FSMTransition, promises:[Promise<AnyObject>]) {
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

    func handleEventTimeout(timer:NSTimer) {
        let userInfo = timer.userInfo as! [String:AnyObject]
        let promises = userInfo["promises"] as! [Promise<AnyObject>]
        let transition = userInfo["transition"] as! FSMTransition
        stopTimeoutTimer()

        let error = FSMError.EventTimeout
        for promise in promises {
            if !promise.isFulfilled {
                promise.reject(error)
            }
        }

        eventDidTimeout?(self, transition)
    }

    func willFireEventWithTransition(transition:FSMTransition, value:AnyObject?) -> Promise<AnyObject> {
        var response:AnyObject? = value
        if let willFireEvent = willFireEvent {
            response = willFireEvent(self,transition,value)
        }
        return Promise.valueAsPromise(response)
    }

    func didFireEventWithTransition(transition:FSMTransition, value:AnyObject?) -> Promise<AnyObject> {
        var response:AnyObject? = value
        if let didFireEvent = didFireEvent {
            response = didFireEvent(self,transition,value)
        }
        return Promise.valueAsPromise(response)
    }

    func fireEventFailedWithTransition(transition:FSMTransition, error:ErrorType) -> Promise<AnyObject> {
        if let fireEventFailed = fireEventFailed {
            return Promise.valueAsPromise(fireEventFailed(self,transition,error))
        }
        return Promise.valueAsPromise(error)
    }

}

func ==(lhs: FSMEvent, rhs: FSMEvent) -> Bool {
    return (lhs.name == rhs.name) && (lhs.finiteStateMachine == rhs.finiteStateMachine)
}
