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
    var dummyError:NSError!

    override func setUp() {
        super.setUp()

        finiteStateMachine = FSMFiniteStateMachine()
        expectedSourceState = finiteStateMachine.addState("expectedSource", error:nil)!
        otherState = finiteStateMachine.addState("otherState", error:nil)!
        expectedDestinationState = finiteStateMachine.addState("expectedDestination", error:nil)!
        dummyError = NSError(domain:"test", code:-1, userInfo:nil)
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
                expectation.fulfill()
                return error
            }
        )

        waitForExpectationsWithTimeout(5.0, handler: nil)
    }

    func expectFailureWithEvent(event:FSMEvent) {
        XCTAssertEqualOptional(expectedSourceState, finiteStateMachine.currentState)
        let promise = finiteStateMachine.fireEvent(event, initialValue:nil)

        let expectation = expectationWithDescription("expectFailureWithEvent")
        promise.then({ (value) -> AnyObject? in
            XCTFail("Should not succeed");
            expectation.fulfill()
            return nil;
        }, reject: { (error) -> NSError in
            XCTAssertEqualOptional(self.expectedSourceState, self.finiteStateMachine.currentState)
            expectation.fulfill()
            return error
        })

        waitForExpectationsWithTimeout(5.0, handler: nil)
    }

    func testValidSimple() {
        finiteStateMachine.setInitialState(expectedSourceState, error:nil)
        let event = finiteStateMachine.addEvent("event", sources:[expectedSourceState], destination:expectedDestinationState, error:nil)!
        expectSuccessWithEvent(event, expectedValue:nil)
    }

    func testInvalidSource() {
        finiteStateMachine.setInitialState(expectedSourceState, error:nil)
        let event = finiteStateMachine.addEvent("event", sources:[otherState], destination:expectedDestinationState, error:nil)!
        expectFailureWithEvent(event)
    }

    func testWillFireEventFulfilled() {
        finiteStateMachine.setInitialState(expectedSourceState, error:nil)
        let event = finiteStateMachine.addEvent("event", sources:[expectedSourceState], destination:expectedDestinationState, error:nil)!
        let expectedValue = "expectedValue"
        event.willFireEvent = { (event, transition, value) -> AnyObject? in
            return expectedValue
        }
        expectSuccessWithEvent(event, expectedValue:expectedValue)
    }

    func testWillFireEventRejected() {
        finiteStateMachine.setInitialState(expectedSourceState, error:nil)
        let event = finiteStateMachine.addEvent("event", sources:[expectedSourceState], destination:expectedDestinationState, error:nil)!
        event.willFireEvent = { (event, transition, value) -> AnyObject? in
            return self.dummyError
        }
        expectFailureWithEvent(event)
    }
    
    func testDidFireEventFulfilled() {
        finiteStateMachine.setInitialState(expectedSourceState, error:nil)
        let event = finiteStateMachine.addEvent("event", sources:[expectedSourceState], destination:expectedDestinationState, error:nil)!
        let expectedValue = "expectedValue"
        event.didFireEvent = { (event, transition, value) -> AnyObject? in
            return expectedValue
        }
        expectSuccessWithEvent(event, expectedValue:expectedValue)
    }

    func testDidFireEventRejected() {
        finiteStateMachine.setInitialState(expectedSourceState, error:nil)
        let event = finiteStateMachine.addEvent("event", sources:[expectedSourceState], destination:expectedDestinationState, error:nil)!
        event.didFireEvent = { (event, transition, value) -> AnyObject? in
            return self.dummyError
        }
        expectFailureWithEvent(event)
    }
    
    func testWillExitStateFulfilled() {
        finiteStateMachine.setInitialState(expectedSourceState, error:nil)
        let event = finiteStateMachine.addEvent("event", sources:[expectedSourceState], destination:expectedDestinationState, error:nil)!
        let expectedValue = "expectedValue"
        expectedSourceState.willExitState = { (state, transition, value) -> AnyObject? in
            return expectedValue
        }
        expectSuccessWithEvent(event, expectedValue:expectedValue)
    }

    func testWillExitStateRejected() {
        finiteStateMachine.setInitialState(expectedSourceState, error:nil)
        let event = finiteStateMachine.addEvent("event", sources:[expectedSourceState], destination:expectedDestinationState, error:nil)!
        expectedSourceState.willExitState = { (state, transition, value) -> AnyObject? in
            return self.dummyError
        }
        expectFailureWithEvent(event)
    }

    func testDidExitStateFulfilled() {
        finiteStateMachine.setInitialState(expectedSourceState, error:nil)
        let event = finiteStateMachine.addEvent("event", sources:[expectedSourceState], destination:expectedDestinationState, error:nil)!
        let expectedValue = "expectedValue"
        expectedSourceState.didExitState = { (state, transition, value) -> AnyObject? in
            return expectedValue
        }
        expectSuccessWithEvent(event, expectedValue:expectedValue)
    }

    func testDidExitStateRejected() {
        finiteStateMachine.setInitialState(expectedSourceState, error:nil)
        let event = finiteStateMachine.addEvent("event", sources:[expectedSourceState], destination:expectedDestinationState, error:nil)!
        expectedSourceState.didExitState = { (state, transition, value) -> AnyObject? in
            return self.dummyError
        }
        expectFailureWithEvent(event)
    }

    func testWillEnterStateFulfilled() {
        finiteStateMachine.setInitialState(expectedSourceState, error:nil)
        let event = finiteStateMachine.addEvent("event", sources:[expectedSourceState], destination:expectedDestinationState, error:nil)!
        let expectedValue = "expectedValue"
        expectedDestinationState.willEnterState = { (state, transition, value) -> AnyObject? in
            return expectedValue
        }
        expectSuccessWithEvent(event, expectedValue:expectedValue)
    }

    func testWillEnterStateRejected() {
        finiteStateMachine.setInitialState(expectedSourceState, error:nil)
        let event = finiteStateMachine.addEvent("event", sources:[expectedSourceState], destination:expectedDestinationState, error:nil)!
        expectedDestinationState.willEnterState = { (state, transition, value) -> AnyObject? in
            return self.dummyError
        }
        expectFailureWithEvent(event)
    }

    func testDidEnterStateFulfilled() {
        finiteStateMachine.setInitialState(expectedSourceState, error:nil)
        let event = finiteStateMachine.addEvent("event", sources:[expectedSourceState], destination:expectedDestinationState, error:nil)!
        let expectedValue = "expectedValue"
        expectedDestinationState.didEnterState = { (state, transition, value) -> AnyObject? in
            return expectedValue
        }
        expectSuccessWithEvent(event, expectedValue:expectedValue)
    }

    func testDidEnterStateRejected() {
        finiteStateMachine.setInitialState(expectedSourceState, error:nil)
        let event = finiteStateMachine.addEvent("event", sources:[expectedSourceState], destination:expectedDestinationState, error:nil)!
        expectedDestinationState.didEnterState = { (state, transition, value) -> AnyObject? in
            return self.dummyError
        }
        expectFailureWithEvent(event)
    }

}
