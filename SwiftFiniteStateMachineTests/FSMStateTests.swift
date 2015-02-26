//
//  FSMStateTests.swift
//  SwiftFiniteStateMachine
//
//  Created by Douglas Sjoquist on 2/26/15.
//  Copyright (c) 2015 Ivy Gulch LLC. All rights reserved.
//

import Foundation
import XCTest

/// like XCTAssertEqual, but handles optional unwrapping
func XCTAssertEqualOptional<T:Equatable>(expression1: @autoclosure () -> T?, expression2: @autoclosure () -> T?, _ message: String? = nil, file: String = __FILE__, line: UInt = __LINE__) {
    if let exp1 = expression1() {
        if let exp2 = expression2() {
            XCTAssertEqual(exp1, exp2, (message != nil) ? message! : "", file: file, line: line)
        } else {
            XCTFail((message != nil) ? message! : "exp1 != nil, exp2 == nil", file: file, line: line)
        }
    } else if let exp2 = expression2() {
        XCTFail((message != nil) ? message! : "exp1 == nil, exp2 != nil", file: file, line: line)
    }
}

class FSMStateTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    func testCreation() {
        let state = FSMState("test", finiteStateMachine: FSMFiniteStateMachine());

        XCTAssertEqual("test", state.name)
    }

    // enterState block tests

    func testWillEnterStateBlock() {
        let expectedState = FSMState("test", finiteStateMachine: FSMFiniteStateMachine());

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

        let expectedTransition = FSMTransition()
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

    func testDidEnterStateBlock() {
        let expectedState = FSMState("test", finiteStateMachine: FSMFiniteStateMachine());

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

        let expectedTransition = FSMTransition()
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
    
    // exitState block tests

    func testWillExitStateBlock() {
        let expectedState = FSMState("test", finiteStateMachine: FSMFiniteStateMachine());

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

        let expectedTransition = FSMTransition()
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

    func testDidExitStateBlock() {
        let expectedState = FSMState("test", finiteStateMachine: FSMFiniteStateMachine());

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

        let expectedTransition = FSMTransition()
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
