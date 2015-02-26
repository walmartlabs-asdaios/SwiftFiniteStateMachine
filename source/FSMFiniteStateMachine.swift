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

class FSMFiniteStateMachine: Equatable {

    private var mutableStates:[String:FSMState] = [:]

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
}

func ==(lhs: FSMFiniteStateMachine, rhs: FSMFiniteStateMachine) -> Bool {
    return lhs === rhs
}
