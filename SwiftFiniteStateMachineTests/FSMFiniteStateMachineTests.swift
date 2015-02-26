//
//  FSMFiniteStateMachineTests.swift
//  SwiftFiniteStateMachine
//
//  Created by Douglas Sjoquist on 2/26/15.
//  Copyright (c) 2015 Ivy Gulch LLC. All rights reserved.
//

import UIKit
import XCTest

class FSMFiniteStateMachineTests: FSMTestCase {

    // MARK: state tests

    func testStateNamesMustBeUnique() {
        let finiteStateMachine = FSMFiniteStateMachine()

        var error:NSError? = nil
        let result1 = finiteStateMachine.addState("state", error:&error)
        XCTAssertEqualOptional("state", result1?.name);

        let result2 = finiteStateMachine.addState("state", error:&error)
        XCTAssertNil(result2);
        XCTAssertNotNil(error);
    }

    func testAddMultipleStates() {
        let finiteStateMachine = FSMFiniteStateMachine()
        let state1 = finiteStateMachine.addState("state1", error:nil)!
        let state2 = finiteStateMachine.addState("state2", error:nil)!

        let states = finiteStateMachine.states
        XCTAssertEqual(2, states.count, "should show two states")
        XCTAssertNotNil(states["state1"])
        XCTAssertNotNil(states["state2"])
    }

    func testNoDefaultCurrentState() {
        let finiteStateMachine = FSMFiniteStateMachine()
        XCTAssertNil(finiteStateMachine.currentState, "Should not have a current state")
        let state1 = finiteStateMachine.addState("state1", error:nil)
        XCTAssertNil(finiteStateMachine.currentState, "Should still not have a current state")
    }

    func testInitializingStateToValidState() {
        let finiteStateMachine = FSMFiniteStateMachine()
        let state = finiteStateMachine.addState("state", error:nil)!
        XCTAssertNil(finiteStateMachine.currentState, "Should not have a current state")

        var error:NSError? = nil
        let result = finiteStateMachine.setInitialState(state, error:&error)
        XCTAssertEqualOptional(state, result)
        XCTAssertEqualOptional(state, finiteStateMachine.currentState, "current state should now match initial state")
    }

    func testInitializingStateToInvalidState() {
        let finiteStateMachine = FSMFiniteStateMachine()
        finiteStateMachine.addState("state", error:nil)

        let invalidState = FSMState("invalidState", finiteStateMachine:FSMFiniteStateMachine())
        XCTAssertNotNil(invalidState)
        let states = finiteStateMachine.states
        XCTAssertNil(states["invalidState"])
        XCTAssertNil(finiteStateMachine.currentState, "Should not have a current state");

        var error:NSError? = nil
        let result = finiteStateMachine.setInitialState(invalidState, error:&error)
        XCTAssertNil(result)
        XCTAssertNotNil(error)
        XCTAssertNil(finiteStateMachine.currentState, "Should still not have a current state");
    }

}
