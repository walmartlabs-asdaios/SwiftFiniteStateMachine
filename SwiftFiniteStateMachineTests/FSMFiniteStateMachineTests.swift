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

    // MARK: - state tests

    func testStateNamesMustBeUnique() {
        let finiteStateMachine = FSMFiniteStateMachine()

        var error:NSError? = nil
        let result1 = finiteStateMachine.addState("state", error:&error)
        XCTAssertEqualOptional("state", result1?.name)

        let result2 = finiteStateMachine.addState("state", error:&error)
        XCTAssertNil(result2)
        XCTAssertNotNil(error)
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
        XCTAssertNil(finiteStateMachine.currentState, "Should not have a current state")

        var error:NSError? = nil
        let result = finiteStateMachine.setInitialState(invalidState, error:&error)
        XCTAssertNil(result)
        XCTAssertNotNil(error)
        XCTAssertNil(finiteStateMachine.currentState, "Should still not have a current state")
    }

    // MARK: - event tests

    func finiteStateMachineWithStateNames(stateNames:[String]) -> FSMFiniteStateMachine {
        let finiteStateMachine = FSMFiniteStateMachine()
        for stateName in stateNames {
            finiteStateMachine.addState(stateName, error:nil)
        }
        return finiteStateMachine
    }

    func testEventInitializationWithValidStringValues() {
        let finiteStateMachine = finiteStateMachineWithStateNames(["source1","source2","destination"])

        var error:NSError? = nil
        if let event = finiteStateMachine.addEvent("event", sources:["source1","source2"], destination:"destination", error:&error) {
            XCTAssertEqual("event", event.name)
            XCTAssertEqual(2, event.sources.count)
            XCTAssertEqual("source1", event.sources[0].name)
            XCTAssertEqual("source2", event.sources[1].name)
            XCTAssertEqual("destination", event.destination.name)
        } else {
            XCTFail("event creation failed")
        }
    }

    func testEventInitializationWithValidInstanceValues() {
        let finiteStateMachine = finiteStateMachineWithStateNames(["source1","source2","destination"])
        let source1 = finiteStateMachine.states["source1"]!
        let source2 = finiteStateMachine.states["source2"]!
        let destination = finiteStateMachine.states["destination"]!

        var error:NSError? = nil
        if let event = finiteStateMachine.addEvent("event", sources:[source1,source2], destination:destination, error:&error) {
            XCTAssertEqual("event", event.name)
            XCTAssertEqual(2, event.sources.count)
            XCTAssertEqual("source1", event.sources[0].name)
            XCTAssertEqual("source2", event.sources[1].name)
            XCTAssertEqual("destination", event.destination.name)
        } else {
            XCTFail("event creation failed")
        }
    }


    func testEventInitializationWithInvalidStringValues() {
        let finiteStateMachine = finiteStateMachineWithStateNames(["source1","source2","destination"])

        var error:NSError? = nil
        if let event = finiteStateMachine.addEvent("event", sources:["source1x","source2x"], destination:"destinationx", error:&error) {
            XCTFail("event creation should have failed")
        } else {
            XCTAssertNotNil(error)
            let userInfo = error!.userInfo as [String:AnyObject]
            let errorMessages = userInfo["messages"] as [String]
            XCTAssertEqual(3, errorMessages.count)
        }
    }

    func testEventNamesMustBeUnique() {
        let finiteStateMachine = finiteStateMachineWithStateNames(["source1","source2","destination"])

        let eventName = "event"
        if let event1 = finiteStateMachine.addEvent(eventName, sources:["source1","source2"], destination:"destination", error:nil) {
            if let event2 = finiteStateMachine.addEvent(eventName, sources:["source1","source2"], destination:"destination", error:nil) {
                XCTFail("should not allow duplicate event names")
                }
        } else {
            XCTFail("could not create event1")
        }
    }

    func testEventMustHaveAtLeastOnceSource() {
        let finiteStateMachine = finiteStateMachineWithStateNames(["source1","source2","destination"])

        var error:NSError? = nil
        if let event = finiteStateMachine.addEvent("event", sources:[], destination:"destination", error:&error) {
            XCTFail("event creation should have failed")
        } else {
            XCTAssertNotNil(error)
            let userInfo = error!.userInfo as [String:AnyObject]
            let errorMessages = userInfo["messages"] as [String]
            XCTAssertEqual(1, errorMessages.count)
        }
    }

    func testDidChangeStateClosure() {
        let finiteStateMachine = FSMFiniteStateMachine()
        let state1 = finiteStateMachine.addState("state1", error:nil)!
        let state2 = finiteStateMachine.addState("state2", error:nil)!
        let event = finiteStateMachine.addEvent("event", sources:[state1], destination:state2, error:nil)!

        finiteStateMachine.didChangeState = {
            (oldState:FSMState?,newState:FSMState?) in
            XCTAssertNil(oldState)
            XCTAssertEqualOptional(state1, newState)
        }
        finiteStateMachine.setInitialState(state1, error:nil)

        finiteStateMachine.didChangeState = {
            (oldState:FSMState?,newState:FSMState?) in
            XCTAssertEqualOptional(state1, oldState)
            XCTAssertEqualOptional(state2, newState)
        }
        finiteStateMachine.fireEvent(event, initialValue:nil)
    }
}
