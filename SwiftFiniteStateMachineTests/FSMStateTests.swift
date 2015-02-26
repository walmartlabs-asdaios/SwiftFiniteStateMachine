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

    /*
    - (void) testDidEnterStateBlock;
    {
    ASDAFSMState *expectedState = [[ASDAFSMState alloc] initWithFiniteStateMachine:self.dummyFiniteStateMachine name:@"test"];
    __block ASDAFSMState *actualState = nil;
    __block ASDAFSMTransition *actualTransition = nil;
    __block id actualValue = nil;
    expectedState.didEnterStateBlock = ^SDPromise*(ASDAFSMState *stateArg, ASDAFSMTransition *transitionArg, id value) {
    actualState = stateArg;
    actualTransition = transitionArg;
    actualValue = value;
    return nil;
    };
    ASDAFSMTransition *expectedTransition = [[ASDAFSMTransition alloc] init];
    id expectedValue = @"expected value";
    SDPromise *result = [expectedState willExitStateWithTransition:expectedTransition value:expectedValue];

    [result then:^id(id dataObject) {
    XCTAssertEqualObjects(expectedState, actualState);
    XCTAssertEqualObjects(expectedTransition, actualTransition);
    XCTAssertEqualObjects(expectedValue, actualValue);
    XCTAssertEqualObjects(expectedValue, dataObject);
    return nil;
    }];
    }
    */

    // exitState block tests

    /*
    - (void) testWillExitStateBlock;
    {
    ASDAFSMState *expectedState = [[ASDAFSMState alloc] initWithFiniteStateMachine:self.dummyFiniteStateMachine name:@"test"];
    __block ASDAFSMState *actualState = nil;
    __block ASDAFSMTransition *actualTransition = nil;
    __block id actualValue = nil;
    expectedState.willExitStateBlock = ^SDPromise*(ASDAFSMState *stateArg, ASDAFSMTransition *transitionArg, id value) {
    actualState = stateArg;
    actualTransition = transitionArg;
    actualValue = value;
    return nil;
    };
    ASDAFSMTransition *expectedTransition = [[ASDAFSMTransition alloc] init];
    id expectedValue = @"expected value";
    SDPromise *result = [expectedState willExitStateWithTransition:expectedTransition value:expectedValue];

    [result then:^id(id dataObject) {
    XCTAssertEqualObjects(expectedState, actualState);
    XCTAssertEqualObjects(expectedTransition, actualTransition);
    XCTAssertEqualObjects(expectedValue, actualValue);
    XCTAssertEqualObjects(expectedValue, dataObject);
    return nil;
    }];
    }
    */
    /*
    - (void) testDidExitStateBlock;
    {
    ASDAFSMState *expectedState = [[ASDAFSMState alloc] initWithFiniteStateMachine:self.dummyFiniteStateMachine name:@"test"];
    __block ASDAFSMState *actualState = nil;
    __block ASDAFSMTransition *actualTransition = nil;
    __block id actualValue = nil;
    expectedState.didExitStateBlock = ^SDPromise*(ASDAFSMState *stateArg, ASDAFSMTransition *transitionArg, id value) {
    actualState = stateArg;
    actualTransition = transitionArg;
    actualValue = value;
    return nil;
    };
    ASDAFSMTransition *expectedTransition = [[ASDAFSMTransition alloc] init];
    id expectedValue = @"expected value";
    SDPromise *result = [expectedState willExitStateWithTransition:expectedTransition value:expectedValue];

    [result then:^id(id dataObject) {
    XCTAssertEqualObjects(expectedState, actualState);
    XCTAssertEqualObjects(expectedTransition, actualTransition);
    XCTAssertEqualObjects(expectedValue, actualValue);
    XCTAssertEqualObjects(expectedValue, dataObject);
    return nil;
    }];
    }
    */
    
}
