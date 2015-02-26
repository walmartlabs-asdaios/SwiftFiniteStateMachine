//
//  FSMEvent.swift
//  SwiftFiniteStateMachine
//
//  Created by Douglas Sjoquist on 2/26/15.
//  Copyright (c) 2015 Ivy Gulch LLC. All rights reserved.
//

import Foundation

func ==(lhs: FSMEvent, rhs: FSMEvent) -> Bool {
    return (lhs.name == rhs.name) && (lhs.finiteStateMachine == rhs.finiteStateMachine)
}

let kFSMDefaultEventTimeout:NSTimeInterval = 10.0

class FSMEvent: Equatable {
    let name: String
    let finiteStateMachine: FSMFiniteStateMachine
    let sources: [FSMState]
    let destination: FSMState
    let eventTimeout: NSTimeInterval

    // MARK: interface

    init(_ name : String, sources:[FSMState], destination:FSMState, finiteStateMachine: FSMFiniteStateMachine) {
        self.name = name
        self.sources = sources
        self.destination = destination
        self.finiteStateMachine = finiteStateMachine
        self.eventTimeout = kFSMDefaultEventTimeout
    }
    
}