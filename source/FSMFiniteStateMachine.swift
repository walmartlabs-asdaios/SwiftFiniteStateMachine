//
//  FSMFiniteStateMachine.swift
//  SwiftFiniteStateMachine
//
//  Created by Douglas Sjoquist on 2/26/15.
//  Copyright (c) 2015 Ivy Gulch LLC. All rights reserved.
//

import Foundation

public typealias kFSMDidChangeStateClosure = (oldState:FSMState?, newState:FSMState?) -> Void
public typealias kFSMGetStateAndEventClosure = (state:FSMState?, event:FSMEvent?) -> Void

public let kFSMErrorDomain = "FSMError"
public let kFSMErrorInvalidState = 101
public let kFSMErrorInvalidStartState = 102
public let kFSMErrorInvalidEvent = 103
public let kFSMErrorRejected = 104
public let kFSMErrorEventTimeout = 105
public let kFSMErrorTransitionInProgress = 106

/**
* FSMFiniteStateMachine is the controller for this sub-system.
*
* Key characteristics
* - works asynchronously
* - built on top of Promise to ensure predictable transition behavior
* - can deal with arbitrary number of states and transitions
* - individual events must be defined for each transition
* - states and events have hooks for application code to validate or reject transitions
* - the process guarantees a result: either a successful resolution or a rejection error
* - since the result is an instance of Promise, the results can be monitored or
*   checked via the Promise then:reject: method
*
* Transition flow
* - initialize state machine (intended to be done just once)
* - firing an event attempts to transition from the current state to the specified
*   destination state
* - if the current state is not valid for the event, then it fails
* - otherwise the event steps through user hooks in the following general order
*      'will' hooks:   intended use is for application code to execute any processes such as
*                      network calls (e.g. user authentication) required before a successful
*                      transition can occur
*      'did' hooks:    intended use is for application code to do any post-processing
*                      required such as updates or cleanup
*
*   if any of these hooks returns an instance of NSError, then:
*      - the chain is interrupted (no further hooks will be executed)
*      - the final result will be a rejection with the given error
*
*      event:              willFireEvent
*      destinationState:   willEnterState
*      sourceState:        willExitState
*         [current state is set]
*      sourceState:        didEnterState
*      destinationState:   didExitState
*      event:              didFireEvent
*/
@objc public class FSMFiniteStateMachine: Equatable {

    // The following class functions are purely for the benefit of Objective-C code
    public class func newInstance() -> FSMFiniteStateMachine {
        return FSMFiniteStateMachine()
    }

    public class func FSMErrorDomain() -> String { return kFSMErrorDomain }
    public class func FSMErrorInvalidState() -> Int { return kFSMErrorInvalidState }
    public class func FSMErrorInvalidStartState() -> Int { return kFSMErrorInvalidStartState }
    public class func FSMErrorInvalidEvent() -> Int { return kFSMErrorInvalidEvent }
    public class func FSMErrorRejected() -> Int { return kFSMErrorRejected }
    public class func FSMErrorEventTimeout() -> Int { return kFSMErrorEventTimeout }
    public class func FSMErrorTransitionInProgress() -> Int { return kFSMErrorTransitionInProgress }

    /**
    * This optional closure is called on the proposed destination state
    * before the transition process completes, after the current state is changed
    */
    public var didChangeState: kFSMDidChangeStateClosure?

    private var mutableStates:[String:FSMState] = [:]
    private var mutableEvents:[String:FSMEvent] = [:]
    private let synchronizer = Synchronizer()
    private var lockingEvent:FSMEvent? = nil
    private var pendingEventTransition:FSMTransition? = nil
    private var pendingEventPromises:[Promise] = []

    private(set) public var currentState: FSMState? {
        didSet {
            didChangeState?(oldState:oldValue,newState:currentState)
        }
    }

    public var states:[String:FSMState] {
        get {
            return mutableStates
        }
    }

    public var events:[String:FSMEvent] {
        get {
            return mutableEvents
        }
    }

    public var pendingEvent:FSMEvent? {
        get {
            return lockingEvent
        }
    }

    public func getStateAndEvent(getStateAndEventClosure:kFSMGetStateAndEventClosure) {
        var state:FSMState?
        var event:FSMEvent?
        synchronizer.synchronize {[weak self] () -> Void in
            state = self?.currentState
            event = self?.pendingEvent
        }
        getStateAndEventClosure(state:state, event:event)
    }

    // MARK: - interface

    init() {
    }

    /**
    * Add a new state to be used by the instance.
    *
    * :param: stateName must be a unique identifier within the instance
    * :param: error optional error return value
    * :returns: An instance of FSMState if initialization was successful, nil otherwise
    */
    public func addState(stateName:String, error:NSErrorPointer) -> FSMState? {
        var result:FSMState? = nil

        var errorMessage = ""
        if stateName.utf16Count == 0 {
            errorMessage = "Missing state name"
        } else if mutableStates[stateName] != nil {
            errorMessage = "Duplicate state name: \(stateName)"
        } else {
            result = FSMState(stateName,finiteStateMachine:self)
            mutableStates[stateName] = result
        }
        if result == nil {
            if error != nil {
                error.memory = NSError(domain:kFSMErrorDomain, code:kFSMErrorInvalidState, userInfo:["messages":[errorMessage]])
            }
        }
        return result
    }

    /**
    * Initialize state machine to it's starting state.
    *
    * :param: state the state to initialize this instance to, it must be an instance of FSMState
    *              that was created by addStateWithName:error:
    * :param: error optional error return value
    * :returns: The FSMState instance passed as an argument if initialization was successful, nil otherwise
    */
    public func setInitialState(state:FSMState, error:NSErrorPointer) -> FSMState? {
        var result:FSMState? = nil

        if mutableStates[state.name] != nil {
            result = state
            currentState = state
        } else {
            if error != nil {
                error.memory = NSError(domain:kFSMErrorDomain, code:kFSMErrorInvalidState, userInfo:["state":state.name])
            }
        }
        return result
    }

    /**
    * Add a new event to be used by the instance to transition between states.
    *
    * :param: eventName must be a unique identifier within the instance
    * :param: sources an array of either state names or instances that already exist in the instance
    *                the state machine instance must be in one of these states in order for the event
    *                to fire successfully
    @ :param: destination a state name or instance that already exists in the instance
    * :param: error optional error return value
    * :returns: An instance of FSMEvent if successful, nil otherwise
    */
    public func addEvent(name:String, sources:[AnyObject], destination:AnyObject, error:NSErrorPointer) -> FSMEvent? {
        var result:FSMEvent? = nil

        var errorMessages:[String] = []
        if name.utf16Count == 0 {
            errorMessages.append("Missing event name")
        } else if mutableEvents[name] != nil {
            errorMessages.append("Duplicate event name: \(name)")
        }

        var sourceStates:[FSMState] = []
        for source in sources {
            if let state = validateState(source) {
                sourceStates.append(state)
            } else {
                errorMessages.append("Invalid source: \(source)")
            }
        }
        if sources.count == 0 {
            errorMessages.append("at least one source is required")
        }

        var destinationState:FSMState? = nil
        if let state = validateState(destination) {
            destinationState = state
        } else {
            errorMessages.append("Invalid destination: \(destination)")
        }

        if errorMessages.count == 0 {
            result = FSMEvent(name, sources:sourceStates, destination:destinationState!, finiteStateMachine:self)
            mutableEvents[name] = result
        }
        if result == nil {
            if error != nil {
                error.memory = NSError(domain:kFSMErrorDomain, code:kFSMErrorInvalidEvent, userInfo:["messages":errorMessages])
            }
        }
        return result
    }

    public func fireEvent(event:FSMEvent, eventTimeout:NSTimeInterval, initialValue:AnyObject?) -> Promise {

        if !lockForEvent(event) {
            return Promise(NSError(domain:kFSMErrorDomain, code:kFSMErrorTransitionInProgress, userInfo:nil))
        }

        if let errorMessage = checkEventSourceState(event, sourceState:currentState) {
            unlockEvent()
            return Promise(NSError(domain:kFSMErrorDomain, code:kFSMErrorInvalidStartState, userInfo:["messages":[errorMessage]]))
        }

        let sourceState = currentState!
        let destinationState = event.destination
        let transition = FSMTransition(event, source:sourceState, finiteStateMachine:self)
        var lastPromise = Promise(initialValue)

        pendingEventPromises = []

        lastPromise = lastPromise.then({(value) -> AnyObject? in
            return event.willFireEventWithTransition(transition, value:value)
        })
        pendingEventPromises.append(lastPromise)

        lastPromise = lastPromise.then({(value) -> AnyObject? in
            return destinationState.willEnterStateWithTransition(transition, value:value)
        })
        pendingEventPromises.append(lastPromise)

        lastPromise = lastPromise.then({(value) -> AnyObject? in
            return sourceState.willExitStateWithTransition(transition, value:value)
        })
        pendingEventPromises.append(lastPromise)

        lastPromise = lastPromise.then({(value) -> AnyObject? in
            self.currentState = destinationState
            return value
        })
        pendingEventPromises.append(lastPromise)

        lastPromise = lastPromise.then({(value) -> AnyObject? in
            return sourceState.didExitStateWithTransition(transition, value:value)
        })
        pendingEventPromises.append(lastPromise)

        lastPromise = lastPromise.then({(value) -> AnyObject? in
            return destinationState.didEnterStateWithTransition(transition, value:value)
        })
        pendingEventPromises.append(lastPromise)

        lastPromise = lastPromise.then({(value) -> AnyObject? in
            return event.didFireEventWithTransition(transition, value:value)
        })
        pendingEventPromises.append(lastPromise)
        pendingEventTransition = transition

        resetTimeoutTimer(eventTimeout)

        lastPromise = lastPromise.then(
            { (value) -> AnyObject? in
                event.stopTimeoutTimer()
                self.unlockEvent()
                return value
            }, reject: { (error) -> NSError in
                event.stopTimeoutTimer()
                self.unlockEvent()
                return error
            }
        )

        return lastPromise
    }

    public func resetTimeoutTimer(eventTimeout:NSTimeInterval) {
        if let event = pendingEvent {
            event.stopTimeoutTimer()
            if let transition = pendingEventTransition {
                event.resetTimeoutTimer(eventTimeout, transition:transition, promises:pendingEventPromises)
            }
        }
    }


    // MARK: - implementation

    public var description : String {
        return "FSMFiniteStateMachine:\nstates: \(mutableStates.keys)"
    }

    func validateState(stateOrName:AnyObject?) -> FSMState? {
        if let state = stateOrName as? FSMState {
            if find(mutableStates.values,state) != nil {
                return state
            }
        } else if let stateName = stateOrName as? String {
            return mutableStates[stateName]
        }
        return nil
    }

    func lockForEvent(event:FSMEvent) -> Bool {
        var result = false

        synchronizer.synchronize {
            if self.lockingEvent == nil {
                self.lockingEvent = event
                self.pendingEventTransition = nil
                self.pendingEventPromises = []
                result = true
            }
        }
        return result
    }

    func unlockEvent() {
        synchronizer.synchronize {
            self.lockingEvent = nil
            self.pendingEventTransition = nil
            self.pendingEventPromises = []
        }
    }

    func checkEventSourceState(event:FSMEvent, sourceState:FSMState?) -> String? {
        var result:String? = nil
        if let sourceState = sourceState {
            if find(event.sources,sourceState) == nil {
                result = "current state '\(sourceState.name)' is not in event sources: "
                var sep = ""
                for eventSource in event.sources {
                    result! += "\(sep)\(eventSource.name)"
                    sep = ", "
                }
            }
        } else {
            result = "there is no current state"
        }
        return result
    }
    
}

public func ==(lhs: FSMFiniteStateMachine, rhs: FSMFiniteStateMachine) -> Bool {
    return lhs === rhs
}
