//
//  FSMState.swift
//  SwiftFiniteStateMachine
//
//  Created by Douglas Sjoquist on 2/26/15.
//  Copyright (c) 2015 Ivy Gulch LLC. All rights reserved.
//

import Foundation

typealias kFSMWillEnterStateClosure = (FSMState, FSMTransition, AnyObject?) -> AnyObject?
typealias kFSMDidEnterStateClosure = (FSMState, FSMTransition, AnyObject?) -> AnyObject?
typealias kFSMWillExitStateClosure = (FSMState, FSMTransition, AnyObject?) -> AnyObject?
typealias kFSMDidExitStateClosure = (FSMState, FSMTransition, AnyObject?) -> AnyObject?

class FSMState: Equatable {
    /**
    The unique identifier within the state machine instance.
    */
    let name: String

    /**
    The instance of the finite state machine this state is attached to
    */
    let finiteStateMachine: FSMFiniteStateMachine

    /**
    This optional closure is called on the proposed destination state
    after the transition process begins, but before the current state is changed
    */
    var willEnterState: kFSMWillEnterStateClosure?

    /**
    This optional closure is called on the proposed destination state
    before the transition process completes, after the current state is changed
    */
    var didEnterState: kFSMDidEnterStateClosure?

    /**
    This optional closure is called on the source state
    after the transition process begins, but before the current state is changed
    */
    var willExitState: kFSMWillExitStateClosure?

    /**
    This optional closure is called on the source state
    before the transition process completes, after the current state is changed
    */
    var didExitState: kFSMDidExitStateClosure?

    // MARK: interface

    init(_ name : String, finiteStateMachine: FSMFiniteStateMachine) {
        self.name = name
        self.finiteStateMachine = finiteStateMachine
    }

    // MARK: implementation

    func willEnterStateWithTransition(transition:FSMTransition, value:AnyObject?) -> Promise {
        var response:AnyObject? = value
        if let willEnterState = willEnterState? {
            response = willEnterState(self,transition,value)
        }
        return Promise.valueAsPromise(response)
    }

    func didEnterStateWithTransition(transition:FSMTransition, value:AnyObject?) -> Promise {
        var response:AnyObject? = value
        if let didEnterState = didEnterState? {
            response = didEnterState(self,transition,value)
        }
        return Promise.valueAsPromise(response)
    }

    func willExitStateWithTransition(transition:FSMTransition, value:AnyObject?) -> Promise {
        var response:AnyObject? = value
        if let willExitState = willExitState? {
            response = willExitState(self,transition,value)
        }
        return Promise.valueAsPromise(response)
    }

    func didExitStateWithTransition(transition:FSMTransition, value:AnyObject?) -> Promise {
        var response:AnyObject? = value
        if let didExitState = didExitState? {
            response = didExitState(self,transition,value)
        }
        return Promise.valueAsPromise(response)
    }

}

func ==(lhs: FSMState, rhs: FSMState) -> Bool {
    return (lhs.name == rhs.name) && (lhs.finiteStateMachine == rhs.finiteStateMachine)
}
