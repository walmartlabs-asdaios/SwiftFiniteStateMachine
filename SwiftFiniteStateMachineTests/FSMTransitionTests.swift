//
//  FSMTransitionTests.swift
//  SwiftFiniteStateMachine
//
//  Created by Douglas Sjoquist on 2/26/15.
//  Copyright (c) 2015 Ivy Gulch LLC. All rights reserved.
//

import UIKit
import XCTest
@testable import SwiftFiniteStateMachine

class FSMTransitionTests: XCTestCase {

    let dummyFiniteStateMachine = FSMFiniteStateMachine()

    func testCreation() {
        let sourceState = FSMState("source", finiteStateMachine:dummyFiniteStateMachine)
        let destinationState = FSMState("destination", finiteStateMachine:dummyFiniteStateMachine)
        let event = FSMEvent("event", sources:[sourceState], destination:destinationState, finiteStateMachine:dummyFiniteStateMachine)

        let transition = FSMTransition(event, source:sourceState, finiteStateMachine:dummyFiniteStateMachine)

        XCTAssertEqual(self.dummyFiniteStateMachine, transition.finiteStateMachine)
        XCTAssertEqual(event, transition.event)
        XCTAssertEqual(sourceState, transition.source)
        XCTAssertEqual(destinationState, transition.destination)
    }

}
