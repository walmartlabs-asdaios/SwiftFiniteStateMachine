//
//  FSMFireEventTests.swift
//  SwiftFiniteStateMachine
//
//  Created by Douglas Sjoquist on 2/26/15.
//  Copyright (c) 2015 Ivy Gulch LLC. All rights reserved.
//

import UIKit
import XCTest

class FSMFireEventTests: FSMTestCase {

    var finiteStateMachine:FSMFiniteStateMachine!
    var expectedSourceState:FSMState!
    var otherState:FSMState!
    var expectedDestinationState:FSMState!

    override func setUp() {
        super.setUp()

        finiteStateMachine = FSMFiniteStateMachine()
        expectedSourceState = finiteStateMachine.addState("expectedSource", error:nil)!
        otherState = finiteStateMachine.addState("otherState", error:nil)!
        expectedDestinationState = finiteStateMachine.addState("expectedDestination", error:nil)!
    }

// MARK: - fire event tests

    func expectSuccessWithEvent(event:FSMEvent, expectedValue:String?) {
        XCTAssertEqualOptional(expectedSourceState, finiteStateMachine.currentState)
        let promise = finiteStateMachine.fireEvent(event, initialValue:nil)

        let expectation = expectationWithDescription("expectSuccessWithEvent")
        promise.then(
            { (value) -> AnyObject? in
                if (expectedValue == nil) {
                    XCTAssertNil(value)
                } else {
                    if let actualValue = value as? String {
                        XCTAssertEqualOptional(expectedValue, actualValue)
                    } else {
                        XCTFail("Expected \(expectedValue) but found \(value)")
                    }
                }
                XCTAssertEqualOptional(self.expectedDestinationState, self.finiteStateMachine.currentState, "currentState should change")
                expectation.fulfill()
                return nil
            }, reject: { (error) -> NSError in
                XCTFail("Should not fail")
                return error
            }
        )

        waitForExpectationsWithTimeout(5.0, handler: nil)
    }

/*
    - (void) expectFailureWithEvent:(ASDAFSMEvent *) event;
    {
    XCTAssertEqualObjects(self.expectedSourceState, self.finiteStateMachine.currentState);
    SDPromise *result = [self.finiteStateMachine fireEvent:event withInitialValue:nil];
    XCTAssertTrue([result isKindOfClass:[SDPromise class]]);

    XCTestExpectation *expectation = [self expectationWithDescription:@"expectFailureWithEvent"];
    @weakify(self);
    [result then:^id(id dataObject) {
    @strongify(self);
    XCTFail(@"Should not succeed");
    [expectation fulfill];
    return nil;
    } reject:^id(NSError *error) {
    @strongify(self);
    XCTAssertTrue([error isKindOfClass:[NSError class]]);
    XCTAssertEqualObjects(self.expectedSourceState, self.finiteStateMachine.currentState, @"currentState should NOT change");
    [expectation fulfill];
    return nil;
    }];
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
    XCTAssertNil(error);
    }];
    }
*/

    func testValidSimple() {
        finiteStateMachine.setInitialState(expectedSourceState, error:nil)

        let event = finiteStateMachine.addEvent("event", sources:[expectedSourceState], destination:expectedDestinationState, error:nil)!

        expectSuccessWithEvent(event, expectedValue:nil)
    }

}
