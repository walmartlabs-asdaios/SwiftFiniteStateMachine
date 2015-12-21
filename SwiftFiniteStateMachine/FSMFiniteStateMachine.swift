//
//  FSMFiniteStateMachine.swift
//  SwiftFiniteStateMachine
//
//  Created by Douglas Sjoquist on 2/26/15.
//  Copyright (c) 2015 Ivy Gulch LLC. All rights reserved.
//

import Foundation

public typealias FSMDidChangeStateClosure = (oldState:FSMState?, newState:FSMState?) -> Void
public typealias FSMGetStateAndEventClosure = (state:FSMState?, event:FSMEvent?) -> Void

public enum FSMError : ErrorType {
    case InvalidState(String)
    case InvalidStartState(String)
    case InvalidEvent([String])
    case Rejected(String)
    case EventTimeout
    case TransitionInProgress(FSMTransition?)
}

/**
 FSMFiniteStateMachine is the controller for this sub-system.

 Key characteristics

 - works asynchronously
 - built on top of Promise to ensure predictable transition behavior
 - can deal with arbitrary number of states and transitions
 - individual events must be defined for each transition
 - states and events have hooks for application code to validate or reject transitions
 - the process guarantees a result: either a successful resolution or a rejection error
 - because the result is an instance of Promise, the results can be monitored or checked via the Promise then:reject: method

 Transition flow

 - initialize state machine (intended to be done just once)
 - firing an event attempts to transition from the current state to the specified
 destination state
 - if the current state is not valid for the event, then it fails
 - otherwise the event steps through user hooks in the following general order
 -- 'will' hooks:   intended use is for application code to execute any processes such as
 network calls (e.g. user authentication) required before a successful
 transition can occur
 -- 'did' hooks:    intended use is for application code to do any post-processing
 required such as updates or cleanup

 If any of these hooks returns an instance of ErrorType, then:

 - the chain is interrupted (no further hooks will be executed)
 - the final result will be a rejection with the given error

 The order that hooks are checked is:

 - event -> willFireEvent
 - destinationState -> willEnterState
 - sourceState -> willExitState
 - [current state is set]
 - sourceState -> didEnterState
 - destinationState -> didExitState
 - event -> didFireEvent

 */
public class FSMFiniteStateMachine: NSObject {

    /**
     This optional closure is called on the proposed destination state
     before the transition process completes, after the current state is changed
     */
    public var didChangeState: FSMDidChangeStateClosure?

    private var mutableStates:[String:FSMState] = [:]
    private var mutableEvents:[String:FSMEvent] = [:]
    private let synchronizer = Synchronizer()
    private var lockingEvent:FSMEvent?
    private var pendingEventTransition:FSMTransition?
    private var pendingEventPromises:[Promise<AnyObject>] = []

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

    public func getStateAndEvent(getStateAndEventClosure:FSMGetStateAndEventClosure) {
        var state:FSMState?
        var event:FSMEvent?
        synchronizer.synchronize {[weak self] () -> Void in
            state = self?.currentState
            event = self?.pendingEvent
        }
        getStateAndEventClosure(state:state, event:event)
    }

    // MARK: - interface

    /**
    Add a new state to be used by the instance.

    - Parameter stateName: must be a unique identifier within the instance
    - Parameter error: optional error return value
    - Throws:
    - Returns: An instance of FSMState if initialization was successful, nil otherwise
    */
    public func addState(stateName:String) throws -> FSMState {
        var errorMessage = ""
        if stateName.isEmpty {
            errorMessage = "Missing state name"
        } else if mutableStates[stateName] != nil {
            errorMessage = "Duplicate state name: \(stateName)"
        } else {
            let result = FSMState(stateName,finiteStateMachine:self)
            mutableStates[stateName] = result
            return result
        }

        throw FSMError.InvalidState(errorMessage)
    }

    /**
     Initialize state machine to it's starting state.

     - Parameter state: the state to initialize this instance to, it must be an instance of FSMState
     that was created by addStateWithName:error:
     - Throws:
     - Returns: The FSMState instance passed as an argument if initialization was successful, nil otherwise
     */
    public func setInitialState(state:FSMState) throws -> FSMState {
        if let result = mutableStates[state.name] {
            currentState = result
            return result
        }
        throw FSMError.InvalidState(state.name)
    }

    /**
     Add a new event to be used by the instance to transition between states.

     - Parameter eventName: must be a unique identifier within the instance
     - Parameter sources: an array of either state names or instances that already exist in the instance
     the state machine instance must be in one of these states in order for the event
     to fire successfully
     - Parameter destination: a state name or instance that already exists in the instance
     - Throws
     - Returns: An instance of FSMEvent if successful, nil otherwise
     */
    public func addEvent(name:String, sources:[AnyObject], destination:AnyObject) throws -> FSMEvent {
        var errorMessages:[String] = []
        if name.isEmpty {
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

        var destinationState:FSMState?
        if let state = validateState(destination) {
            destinationState = state
        } else {
            errorMessages.append("Invalid destination: \(destination)")
        }

        if errorMessages.count == 0 {
            let result = FSMEvent(name, sources:sourceStates, destination:destinationState!, finiteStateMachine:self)
            mutableEvents[name] = result
            return result
        }

        throw FSMError.InvalidEvent(errorMessages)
    }

    /**
     Fires an event that will work through check where the state machine is in the correct
     state and then work through the list of hooks to attempt to transition to the destination state.

     - Parameter event: the event to be fired
     - Parameter eventTimeout: the transition must be completed within this timeout or the transition will fail
     - Parameter initialValue: an optional value to seed the event chain with
     - Returns: An instance of FSMEvent if successful, nil otherwise
     */
    public func fireEvent(event:FSMEvent, eventTimeout:NSTimeInterval, initialValue:AnyObject?) -> Promise<AnyObject> {

        if !lockForEvent(event) {
            return Promise(FSMError.TransitionInProgress(self.pendingEventTransition))
        }

        if let errorMessage = checkEventSourceState(event, sourceState:currentState) {
            unlockEvent()
            return Promise(FSMError.InvalidStartState(errorMessage))
        }

        let sourceState = currentState!
        let destinationState = event.destination
        let transition = FSMTransition(event, source:sourceState, finiteStateMachine:self)
        var lastPromise = Promise(initialValue)

        pendingEventPromises = []

        lastPromise = lastPromise.then({
            value in
            return .Pending(event.willFireEventWithTransition(transition, value:value))
        })
        pendingEventPromises.append(lastPromise)

        lastPromise = lastPromise.then({
            value in
            return .Pending(destinationState.willEnterStateWithTransition(transition, value:value))
        })
        pendingEventPromises.append(lastPromise)

        lastPromise = lastPromise.then({
            value in
            return .Pending(sourceState.willExitStateWithTransition(transition, value:value))
        })
        pendingEventPromises.append(lastPromise)

        lastPromise = lastPromise.then({
            value in
            return .Value(value)
        })
        pendingEventPromises.append(lastPromise)

        lastPromise = lastPromise.then({
            value in
            return .Pending(sourceState.didExitStateWithTransition(transition, value:value))
        })
        pendingEventPromises.append(lastPromise)

        lastPromise = lastPromise.then({
            value in
            self.currentState = destinationState
            return .Pending(destinationState.didEnterStateWithTransition(transition, value:value))
        })
        pendingEventPromises.append(lastPromise)

        lastPromise = lastPromise.then(
            {
                value in
                return .Pending(event.didFireEventWithTransition(transition, value:value))
            },
            reject: {
                error in
                return .Pending(event.fireEventFailedWithTransition(transition, error: error as NSError))
            }
        )
        pendingEventPromises.append(lastPromise)
        pendingEventTransition = transition

        resetTimeoutTimer(eventTimeout)

        lastPromise = lastPromise.then(
            {
                value in
                event.stopTimeoutTimer()
                self.unlockEvent()
                return .Value(value)
            }, reject: {
                error in
                event.stopTimeoutTimer()
                self.unlockEvent()
                return .Error(error)
            }
        )

        return lastPromise
    }

    func resetTimeoutTimer(eventTimeout:NSTimeInterval) {
        if let event = pendingEvent {
            event.stopTimeoutTimer()
            if let transition = pendingEventTransition {
                event.resetTimeoutTimer(eventTimeout, transition:transition, promises:pendingEventPromises)
            }
        }
    }


    // MARK: - implementation

    public override var description : String {
        return "FSMFiniteStateMachine:\nstates: \(mutableStates.keys)"
    }

    func validateState(stateOrName:AnyObject?) -> FSMState? {
        if let state = stateOrName as? FSMState {
            if mutableStates.values.contains(state) {
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
        var result:String?
        if let actualSourceState = sourceState {
            if !event.sources.contains(actualSourceState) {
                result = "current state '\(actualSourceState.name)' is not in event sources: "
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

func ==(lhs: FSMFiniteStateMachine, rhs: FSMFiniteStateMachine) -> Bool {
    return lhs === rhs
}
