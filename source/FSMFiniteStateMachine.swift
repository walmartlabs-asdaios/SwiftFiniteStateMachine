//
//  FSMFiniteStateMachine.swift
//  SwiftFiniteStateMachine
//
//  Created by Douglas Sjoquist on 2/26/15.
//  Copyright (c) 2015 Ivy Gulch LLC. All rights reserved.
//

import Foundation

let kFSMErrorDomain = "FSMError"
let kFSMErrorInvalidState = 101
let kFSMErrorInvalidEvent = 102
let kFSMErrorRejected = 103
let kFSMErrorEventTimeout = 104

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
class FSMFiniteStateMachine: Equatable {

    private var mutableStates:[String:FSMState] = [:]

    private(set) internal var currentState: FSMState?

    var states:[String:FSMState] {
        get {
            return mutableStates
        }
    }

    // MARK: interface

    init() {
    }

    /**
    * Add a new state to be used by the instance.
    *
    * :param: stateName must be a unique identifier within the instance
    * :param: error optional error return value
    * :returns: An instance of FSMState if initialization was successful, nil otherwise
    */
    func addState(stateName:String, error:NSErrorPointer) -> FSMState? {
        var result:FSMState? = nil

        var errorMessage = ""
        if (stateName.utf16Count == 0) {
            errorMessage = "Missing state name";
        } else if (mutableStates[stateName] != nil) {
            errorMessage = "Duplicate state name: \(stateName)"
        } else {
            result = FSMState(stateName,finiteStateMachine:self)
            mutableStates[stateName] = result
        }
        if (result == nil) {
            if (error != nil) {
                error.memory = NSError(domain:kFSMErrorDomain, code:kFSMErrorInvalidState, userInfo:["messages":[errorMessage]])
            }
        }
        return result;
    }

    /**
    * Initialize state machine to it's starting state.
    *
    * :param: state the state to initialize this instance to, it must be an instance of FSMState
    *              that was created by addStateWithName:error:
    * :param: error optional error return value
    * :returns: The FSMState instance passed as an argument if initialization was successful, nil otherwise
    */
    func setInitialState(state:FSMState, error:NSErrorPointer) -> FSMState? {
        var result:FSMState? = nil

        if (mutableStates[state.name] != nil) {
            result = state;
            currentState = state;
        } else {
            if (error != nil) {
                error.memory = NSError(domain:kFSMErrorDomain, code:kFSMErrorInvalidState, userInfo:["state":state.name])
            }
        }
        return result;
    }

    // MARK: implementation

    var description : String {
        return "FSMFiniteStateMachine:\nstates: \(mutableStates.keys)"
    }

}

func ==(lhs: FSMFiniteStateMachine, rhs: FSMFiniteStateMachine) -> Bool {
    return lhs === rhs
}
