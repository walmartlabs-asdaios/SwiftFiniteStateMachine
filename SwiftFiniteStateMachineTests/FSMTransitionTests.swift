//
//  FSMTransitionTests.swift
//  SwiftFiniteStateMachine
//
//  Created by Douglas Sjoquist on 2/26/15.
//  Copyright (c) 2015 Ivy Gulch LLC. All rights reserved.
//

import UIKit
import XCTest

class FSMTransitionTests: FSMTestCase {

    let dummyFiniteStateMachine = FSMFiniteStateMachine()

    func testCreation() {
        let sourceState = FSMState("source", finiteStateMachine:dummyFiniteStateMachine)
        let destinationState = FSMState("destination", finiteStateMachine:dummyFiniteStateMachine)
        let event = FSMEvent("event", sources:[sourceState], destination:destinationState, finiteStateMachine:dummyFiniteStateMachine)

        let transition = FSMTransition(event, source:sourceState, finiteStateMachine:dummyFiniteStateMachine)

        XCTAssertEqualOptional(self.dummyFiniteStateMachine, transition.finiteStateMachine)
        XCTAssertEqualOptional(event, transition.event)
        XCTAssertEqualOptional(sourceState, transition.source)
        XCTAssertEqualOptional(destinationState, transition.destination)
    }

}
