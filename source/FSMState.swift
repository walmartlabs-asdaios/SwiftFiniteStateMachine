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

func ==(lhs: FSMState, rhs: FSMState) -> Bool {
    return (lhs.name == rhs.name) && (lhs.finiteStateMachine == rhs.finiteStateMachine)
}


class FSMState: Equatable {
    let name: String
    let finiteStateMachine: FSMFiniteStateMachine
    var willEnterState: kFSMWillEnterStateClosure?
    var didEnterState: kFSMDidEnterStateClosure?

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

}