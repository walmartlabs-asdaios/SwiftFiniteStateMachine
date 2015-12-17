//
//  FSMTransition.swift
//  SwiftFiniteStateMachine
//
//  Created by Douglas Sjoquist on 2/26/15.
//  Copyright (c) 2015 Ivy Gulch LLC. All rights reserved.
//

import Foundation

/**
 A transition represents a transition in process for an event being fired.
 */
public class FSMTransition: NSObject {

    /**
     The event that triggered this transition
     */
    public let event:FSMEvent!

    /**
     The source state when the transition was triggered
     */
    public let source:FSMState!

    /**
     The destination state of the transition
     */
    public var destination:FSMState {
        get {
            return self.event.destination
        }
    }

    // MARK: - implementation

    /**
     The instance of the finite state machine this state is attached to
     */
    let finiteStateMachine: FSMFiniteStateMachine!

    init(_ event:FSMEvent, source:FSMState, finiteStateMachine:FSMFiniteStateMachine) {
        self.event = event
        self.source = source
        self.finiteStateMachine = finiteStateMachine
        super.init()
    }

    public override var description : String {
        return "FSMTransition: event=\(event?.name) source=\(source?.name)"
    }

}

func ==(lhs: FSMTransition, rhs: FSMTransition) -> Bool {
    return (lhs.event == rhs.event) && (lhs.source == rhs.source)
}
