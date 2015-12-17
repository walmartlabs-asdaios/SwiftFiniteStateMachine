//
//  FSMFiniteStateMachineTests.swift
//  SwiftFiniteStateMachine
//
//  Created by Douglas Sjoquist on 2/26/15.
//  Copyright (c) 2015 Ivy Gulch LLC. All rights reserved.
//

import UIKit
import XCTest
@testable import SwiftFiniteStateMachine

class FSMFiniteStateMachineTests: XCTestCase {

    // MARK: - state tests

    func testStateNamesMustBeUnique() {
        let finiteStateMachine = FSMFiniteStateMachine()

        do {
            let result1 = try finiteStateMachine.addState("state")
            XCTAssertEqual("state", result1.name)

            try finiteStateMachine.addState("state")
            XCTFail("Should have failed")
        }
        catch {
        }
    }

    func testAddMultipleStates() {
        let finiteStateMachine = FSMFiniteStateMachine()
        do {
            let state1 = try finiteStateMachine.addState("state1")
            let state2 = try finiteStateMachine.addState("state2")

            let states = finiteStateMachine.states
            XCTAssertEqual(2, states.count, "should show two states")
            XCTAssertNotNil(states["state1"])
            XCTAssertNotNil(states["state2"])
            XCTAssertEqual(state1, states["state1"])
            XCTAssertEqual(state2, states["state2"])
        }
        catch let error {
            XCTFail("Error: \(error)")
        }
    }

    func testNoDefaultCurrentState() {
        let finiteStateMachine = FSMFiniteStateMachine()
        do {
            XCTAssertNil(finiteStateMachine.currentState, "Should not have a current state")
            try finiteStateMachine.addState("state1")
            XCTAssertNil(finiteStateMachine.currentState, "Should still not have a current state")
        }
        catch let error {
            XCTFail("Error: \(error)")
        }
    }

    func testInitializingStateToValidState() {
        let finiteStateMachine = FSMFiniteStateMachine()
        do {
            let state = try finiteStateMachine.addState("state")
            XCTAssertNil(finiteStateMachine.currentState, "Should not have a current state")

            let result = try finiteStateMachine.setInitialState(state)
            XCTAssertEqual(state, result)
            XCTAssertEqual(state, finiteStateMachine.currentState, "current state should now match initial state")
        }
        catch let error {
            XCTFail("Error: \(error)")
        }
    }

    func testInitializingStateToInvalidState() {
        let finiteStateMachine = FSMFiniteStateMachine()
        do {
            try finiteStateMachine.addState("state")

            let invalidState = FSMState("invalidState", finiteStateMachine:FSMFiniteStateMachine())
            XCTAssertNotNil(invalidState)
            let states = finiteStateMachine.states
            XCTAssertNil(states["invalidState"])
            XCTAssertNil(finiteStateMachine.currentState, "Should not have a current state")

            try finiteStateMachine.setInitialState(invalidState)
            XCTFail("Should have failed")
        }
        catch {
        }

        XCTAssertNil(finiteStateMachine.currentState, "Should still not have a current state")
    }

    // MARK: - event tests

    func finiteStateMachineWithStateNames(stateNames:[String]) -> FSMFiniteStateMachine {
        let finiteStateMachine = FSMFiniteStateMachine()
        do {
            for stateName in stateNames {
                try finiteStateMachine.addState(stateName)
            }
        }
        catch let error {
            XCTFail("Error: \(error)")
        }
        return finiteStateMachine
    }

    func testEventInitializationWithValidStringValues() {
        let finiteStateMachine = finiteStateMachineWithStateNames(["source1","source2","destination"])

        do {
            let event = try finiteStateMachine.addEvent("event", sources:["source1","source2"], destination:"destination")
            XCTAssertEqual("event", event.name)
            XCTAssertEqual(2, event.sources.count)
            XCTAssertEqual("source1", event.sources[0].name)
            XCTAssertEqual("source2", event.sources[1].name)
            XCTAssertEqual("destination", event.destination.name)
        }
        catch let error {
            XCTFail("Error: \(error)")
        }
    }

    func testEventInitializationWithValidInstanceValues() {
        let finiteStateMachine = finiteStateMachineWithStateNames(["source1","source2","destination"])
        let source1 = finiteStateMachine.states["source1"]!
        let source2 = finiteStateMachine.states["source2"]!
        let destination = finiteStateMachine.states["destination"]!

        do {
            let event = try finiteStateMachine.addEvent("event", sources:[source1,source2], destination:destination)
            XCTAssertEqual("event", event.name)
            XCTAssertEqual(2, event.sources.count)
            XCTAssertEqual("source1", event.sources[0].name)
            XCTAssertEqual("source2", event.sources[1].name)
            XCTAssertEqual("destination", event.destination.name)
        }
        catch let error {
            XCTFail("Error: \(error)")
        }
    }


    func testEventInitializationWithInvalidStringValues() {
        let finiteStateMachine = finiteStateMachineWithStateNames(["source1","source2","destination"])

        do {
            try finiteStateMachine.addEvent("event", sources:["source1x","source2x"], destination:"destinationx")
            XCTFail("event creation should have failed")
        }
        catch FSMError.InvalidEvent(let errorMessages) {
            XCTAssertEqual(3, errorMessages.count)
        }
        catch let unknownError {
            XCTFail("Unknown error: \(unknownError)")
        }
    }

    func testEventNamesMustBeUnique() {
        let finiteStateMachine = finiteStateMachineWithStateNames(["source1","source2","destination"])

        let eventName = "event"
        do {
            try finiteStateMachine.addEvent(eventName, sources:["source1","source2"], destination:"destination")
            try finiteStateMachine.addEvent(eventName, sources:["source1","source2"], destination:"destination")
            XCTFail("event creation should have failed")
        }
        catch FSMError.InvalidEvent(let errorMessages) {
            XCTAssertEqual(1, errorMessages.count)
        }
        catch let unknownError {
            XCTFail("Unknown error: \(unknownError)")
        }
    }

    func testEventMustHaveAtLeastOnceSource() {
        let finiteStateMachine = finiteStateMachineWithStateNames(["source1","source2","destination"])

        do {
            try finiteStateMachine.addEvent("event", sources:[], destination:"destination")
            XCTFail("event creation should have failed")
        }
        catch FSMError.InvalidEvent(let errorMessages) {
            XCTAssertEqual(1, errorMessages.count)
        }
        catch let unknownError {
            XCTFail("Unknown error: \(unknownError)")
        }
    }

    func testDidChangeStateClosure() {
        let finiteStateMachine = FSMFiniteStateMachine()
        do {
            let state1 = try finiteStateMachine.addState("state1")
            let state2 = try finiteStateMachine.addState("state2")
            let event = try finiteStateMachine.addEvent("event", sources:[state1], destination:state2)

            finiteStateMachine.didChangeState = {
                (oldState:FSMState?,newState:FSMState?) in
                XCTAssertNil(oldState)
                XCTAssertEqual(state1, newState)
            }
            try finiteStateMachine.setInitialState(state1)

            finiteStateMachine.didChangeState = {
                (oldState:FSMState?,newState:FSMState?) in
                XCTAssertEqual(state1, oldState)
                XCTAssertEqual(state2, newState)
            }
            finiteStateMachine.fireEvent(event, eventTimeout:10.0, initialValue:nil)
        }
        catch let error {
            XCTFail("Error: \(error)")
        }
    }
}
