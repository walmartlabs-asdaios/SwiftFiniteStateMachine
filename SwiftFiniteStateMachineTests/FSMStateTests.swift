//
//  FSMStateTests.swift
//  SwiftFiniteStateMachine
//
//  Created by Douglas Sjoquist on 2/26/15.
//  Copyright (c) 2015 Ivy Gulch LLC. All rights reserved.
//

import Foundation
import XCTest

class FSMStateTests: FSMTestCase {

    let dummyFiniteStateMachine = FSMFiniteStateMachine()

    func testCreation() {
        let state = FSMState("test", finiteStateMachine: dummyFiniteStateMachine);

        XCTAssertEqual("test", state.name)
        XCTAssertEqual(dummyFiniteStateMachine, state.finiteStateMachine)
    }

    // MARK: enterState tests

    func testWillEnterState() {
        let dummySource = FSMState("source", finiteStateMachine: dummyFiniteStateMachine);
        let expectedState = FSMState("destination", finiteStateMachine: dummyFiniteStateMachine);

        var actualState:FSMState? = nil
        var actualTransition:FSMTransition? = nil
        var actualValue:AnyObject? = nil

        expectedState.willEnterState = {
            (state, transition, value) -> AnyObject? in
            actualState = state;
            actualTransition = transition;
            actualValue = value;
            return value
        }

        let event = FSMEvent("event",sources:[dummySource],destination:expectedState,finiteStateMachine:dummyFiniteStateMachine)
        let expectedTransition = FSMTransition(event,source:dummySource,finiteStateMachine:dummyFiniteStateMachine)
        let expectedValue:AnyObject? = "expected value"

        let result = expectedState.willEnterStateWithTransition(expectedTransition, value:expectedValue)
        result.then(
            { (value) -> AnyObject? in
                XCTAssertEqualOptional(expectedState, actualState);
                XCTAssertEqualOptional(expectedTransition, actualTransition);
                XCTAssertTrue(expectedValue === actualValue);
                return nil
            }, reject: { (error) -> NSError in
                XCTFail("should not fail")
                return error
        })
    }

    func testDidEnterState() {
        let dummySource = FSMState("source", finiteStateMachine: dummyFiniteStateMachine);
        let expectedState = FSMState("destination", finiteStateMachine: dummyFiniteStateMachine);

        var actualState:FSMState? = nil
        var actualTransition:FSMTransition? = nil
        var actualValue:AnyObject? = nil

        expectedState.didEnterState = {
            (state, transition, value) -> AnyObject? in
            actualState = state;
            actualTransition = transition;
            actualValue = value;
            return value
        }

        let event = FSMEvent("event",sources:[dummySource],destination:expectedState,finiteStateMachine:dummyFiniteStateMachine)
        let expectedTransition = FSMTransition(event,source:dummySource,finiteStateMachine:dummyFiniteStateMachine)
        let expectedValue:AnyObject? = "expected value"

        let result = expectedState.didEnterStateWithTransition(expectedTransition, value:expectedValue)
        result.then(
            { (value) -> AnyObject? in
                XCTAssertEqualOptional(expectedState, actualState);
                XCTAssertEqualOptional(expectedTransition, actualTransition);
                XCTAssertTrue(expectedValue === actualValue);
                return nil
            }, reject: { (error) -> NSError in
                XCTFail("should not fail")
                return error
        })
    }
    
    // MARK: exitState tests

    func testWillExitState() {
        let expectedState = FSMState("source", finiteStateMachine: dummyFiniteStateMachine);
        let dummyDestination = FSMState("destination", finiteStateMachine: dummyFiniteStateMachine);

        var actualState:FSMState? = nil
        var actualTransition:FSMTransition? = nil
        var actualValue:AnyObject? = nil

        expectedState.willExitState = {
            (state, transition, value) -> AnyObject? in
            actualState = state;
            actualTransition = transition;
            actualValue = value;
            return value
        }

        let event = FSMEvent("event",sources:[expectedState],destination:dummyDestination,finiteStateMachine:dummyFiniteStateMachine)
        let expectedTransition = FSMTransition(event,source:expectedState,finiteStateMachine:dummyFiniteStateMachine)
        let expectedValue:AnyObject? = "expected value"

        let result = expectedState.willExitStateWithTransition(expectedTransition, value:expectedValue)
        result.then(
            { (value) -> AnyObject? in
                XCTAssertEqualOptional(expectedState, actualState);
                XCTAssertEqualOptional(expectedTransition, actualTransition);
                XCTAssertTrue(expectedValue === actualValue);
                return nil
            }, reject: { (error) -> NSError in
                XCTFail("should not fail")
                return error
        })
    }

    func testDidExitState() {
        let expectedState = FSMState("source", finiteStateMachine: dummyFiniteStateMachine);
        let dummyDestination = FSMState("destination", finiteStateMachine: dummyFiniteStateMachine);

        var actualState:FSMState? = nil
        var actualTransition:FSMTransition? = nil
        var actualValue:AnyObject? = nil

        expectedState.didExitState = {
            (state, transition, value) -> AnyObject? in
            actualState = state;
            actualTransition = transition;
            actualValue = value;
            return value
        }

        let event = FSMEvent("event",sources:[expectedState],destination:dummyDestination,finiteStateMachine:dummyFiniteStateMachine)
        let expectedTransition = FSMTransition(event,source:expectedState,finiteStateMachine:dummyFiniteStateMachine)
        let expectedValue:AnyObject? = "expected value"

        let result = expectedState.didExitStateWithTransition(expectedTransition, value:expectedValue)
        result.then(
            { (value) -> AnyObject? in
                XCTAssertEqualOptional(expectedState, actualState);
                XCTAssertEqualOptional(expectedTransition, actualTransition);
                XCTAssertTrue(expectedValue === actualValue);
                return nil
            }, reject: { (error) -> NSError in
                XCTFail("should not fail")
                return error
        })
    }
    
}
