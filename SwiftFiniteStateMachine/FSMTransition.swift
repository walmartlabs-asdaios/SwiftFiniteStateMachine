//
//  FSMTransition.swift
//  SwiftFiniteStateMachine
//
//  Created by Douglas Sjoquist on 2/26/15.
//  Copyright (c) 2015 Ivy Gulch LLC. All rights reserved.
//

import Foundation

public class FSMTransition: NSObject {

    /**
    * The event that triggered this transition
    */
    public weak var event:FSMEvent?

    /**
    * The source state when the transition was triggered
    */
    public weak var source:FSMState?

    /**
    * The destination state of the transition
    */
    public var destination:FSMState? {
        get {
            return self.event?.destination
        }
    }

    /**
    * The instance of the finite state machine this state is attached to
    */
    public weak var finiteStateMachine: FSMFiniteStateMachine?

    public init(_ event:FSMEvent, source:FSMState, finiteStateMachine:FSMFiniteStateMachine) {
        self.event = event
        self.source = source
        self.finiteStateMachine = finiteStateMachine
        super.init()
    }

    // MARK: - implementation

    public override var description : String {
        return "FSMTransition: event=\(event?.name) source=\(source?.name)"
    }

}

public func ==(lhs: FSMTransition, rhs: FSMTransition) -> Bool {
    return (lhs.event == rhs.event) && (lhs.source == rhs.source)
}
