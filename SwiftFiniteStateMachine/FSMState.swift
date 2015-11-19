//
//  FSMState.swift
//  SwiftFiniteStateMachine
//
//  Created by Douglas Sjoquist on 2/26/15.
//  Copyright (c) 2015 Ivy Gulch LLC. All rights reserved.
//

import Foundation

public typealias FSMWillEnterStateClosure = (FSMState, FSMTransition, AnyObject?) -> AnyObject?
public typealias FSMDidEnterStateClosure = (FSMState, FSMTransition, AnyObject?) -> AnyObject?
public typealias FSMWillExitStateClosure = (FSMState, FSMTransition, AnyObject?) -> AnyObject?
public typealias FSMDidExitStateClosure = (FSMState, FSMTransition, AnyObject?) -> AnyObject?

/**
* FSMState represents a single state in the state machine instance.
*
* Each instance has it's own set of optional closures that application code can use to
* prepare for or reject individual steps in the transition process.
*
* All of the closures are optional, if a particular one is nil, the state machine will simply
* move along to the next step in the process.
*
* Each event closure returns a value, 
* - if an instance of NSError is returned, then the chain of events is interrupted 
*   and the final result of the transition will be a rejection with that same error. 
* - if an instance of Promise is returned, then it will be inserted into the chain
*   of promises used in the transition, and subsequent steps will be dependent on
*   the fulfillment or rejection of that promise
* - if any other value is returned (including nil), then that value is passed to 
*   the next step in the process
*/
public class FSMState: NSObject {

    /**
    * The unique identifier within the state machine instance.
    */
    public let name: String

    /**
    * The instance of the finite state machine this state is attached to
    */
    public let finiteStateMachine: FSMFiniteStateMachine!

    /**
    * This optional closure is called on the proposed destination state
    * after the transition process begins, but before the current state is changed
    */
    public var willEnterState: FSMWillEnterStateClosure?

    /**
    * This optional closure is called on the proposed destination state
    * before the transition process completes, after the current state is changed
    */
    public var didEnterState: FSMDidEnterStateClosure?

    /**
    * This optional closure is called on the source state
    * after the transition process begins, but before the current state is changed
    */
    public var willExitState: FSMWillExitStateClosure?

    /**
    * This optional closure is called on the source state
    * before the transition process completes, after the current state is changed
    */
    public var didExitState: FSMDidExitStateClosure?

    // MARK: - interface

    public init(_ name : String, finiteStateMachine: FSMFiniteStateMachine) {
        self.name = name
        self.finiteStateMachine = finiteStateMachine
        super.init()
    }

    // MARK: - implementation

    public override var description : String {
        return "FSMState: \(name)"
    }

    func willEnterStateWithTransition(transition:FSMTransition, value:AnyObject?) -> Promise<AnyObject> {
        var response:AnyObject? = value
        if let willEnterState = self.willEnterState {
            response = willEnterState(self,transition,value)
        }
        return Promise.valueAsPromise(response)
    }

    func didEnterStateWithTransition(transition:FSMTransition, value:AnyObject?) -> Promise<AnyObject> {
        var response:AnyObject? = value
        if let didEnterState = self.didEnterState {
            response = didEnterState(self,transition,value)
        }
        return Promise.valueAsPromise(response)
    }

    func willExitStateWithTransition(transition:FSMTransition, value:AnyObject?) -> Promise<AnyObject> {
        var response:AnyObject? = value
        if let willExitState = self.willExitState {
            response = willExitState(self,transition,value)
        }
        return Promise.valueAsPromise(response)
    }

    func didExitStateWithTransition(transition:FSMTransition, value:AnyObject?) -> Promise<AnyObject> {
        var response:AnyObject? = value
        if let didExitState = self.didExitState {
            response = didExitState(self,transition,value)
        }
        return Promise.valueAsPromise(response)
    }

}

func ==(lhs: FSMState, rhs: FSMState) -> Bool {
    return (lhs.name == rhs.name) && (lhs.finiteStateMachine == rhs.finiteStateMachine)
}
