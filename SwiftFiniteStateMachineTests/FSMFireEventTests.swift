//
//  FSMFireEventTests.swift
//  SwiftFiniteStateMachine
//
//  Created by Douglas Sjoquist on 2/26/15.
//  Copyright (c) 2015 Ivy Gulch LLC. All rights reserved.
//

import UIKit
import XCTest
@testable import SwiftFiniteStateMachine

class FSMFireEventTests: XCTestCase {

    let defaultEventTimeout:NSTimeInterval = 10.0

    var finiteStateMachine:FSMFiniteStateMachine!
    var expectedSourceState:FSMState!
    var otherState:FSMState!
    var expectedDestinationState:FSMState!
    var dummyError:NSError!

    override func setUp() {
        super.setUp()

        finiteStateMachine = FSMFiniteStateMachine()
        do {
            expectedSourceState = try finiteStateMachine.addState("expectedSource")
            otherState = try finiteStateMachine.addState("otherState")
            expectedDestinationState = try finiteStateMachine.addState("expectedDestination")
            dummyError = NSError(domain:"test", code:-1, userInfo:nil)
        }
        catch let error {
            XCTFail("Error: \(error)")
        }
    }

    // MARK: - fire event tests

    func expectSuccessWithEvent(event:FSMEvent, expectedValue:String?) {
        XCTAssertEqual(expectedSourceState, finiteStateMachine.currentState)
        let promise = finiteStateMachine.fireEvent(event, eventTimeout:defaultEventTimeout, initialValue:nil)

        let expectation = expectationWithDescription("expectSuccessWithEvent")
        promise.then(
            {
                value in
                if (expectedValue == nil) {
                    XCTAssertNil(value)
                } else {
                    if let actualValue = value as? String {
                        XCTAssertEqual(expectedValue, actualValue)
                    } else {
                        XCTFail("Expected \(expectedValue) but found \(value)")
                    }
                }
                XCTAssertEqual(self.expectedDestinationState, self.finiteStateMachine.currentState, "currentState should change")
                expectation.fulfill()
                return .Value(nil)
            }, reject: {
                error in
                XCTFail("Should not fail")
                expectation.fulfill()
                return .Error(error)
            }
        )

        waitForExpectationsWithTimeout(5.0, handler: nil)
    }

    func expectFailureWithEvent(event:FSMEvent, expectedCurrentState:FSMState?) {
        XCTAssertEqual(expectedSourceState, finiteStateMachine.currentState)
        let promise = finiteStateMachine.fireEvent(event, eventTimeout:defaultEventTimeout, initialValue:nil)

        let expectation = expectationWithDescription("expectFailureWithEvent")
        promise.then(
            {
                value in
                XCTFail("Should not succeed")
                expectation.fulfill()
                return .Value(nil)
            }, reject: {
                error in
                XCTAssertEqual(expectedCurrentState, self.finiteStateMachine.currentState)
                expectation.fulfill()
                return .Error(error)
        })

        waitForExpectationsWithTimeout(5.0, handler: nil)
    }

    func testValidSimple() {
        do {
            try finiteStateMachine.setInitialState(expectedSourceState)
            let event = try finiteStateMachine.addEvent("event", sources:[expectedSourceState], destination:expectedDestinationState)
            expectSuccessWithEvent(event, expectedValue:nil)
        }
        catch let error {
            XCTFail("Error: \(error)")
        }
    }

    func testInvalidSource() {
        do {
            try finiteStateMachine.setInitialState(expectedSourceState)
            let event = try finiteStateMachine.addEvent("event", sources:[otherState], destination:expectedDestinationState)
            expectFailureWithEvent(event, expectedCurrentState:finiteStateMachine.currentState)
        }
        catch let error {
            XCTFail("Error: \(error)")
        }
    }

    func testWillFireEventFulfilled() {
        do {
            try finiteStateMachine.setInitialState(expectedSourceState)
            let event = try finiteStateMachine.addEvent("event", sources:[expectedSourceState], destination:expectedDestinationState)
            let expectedValue = "expectedValue"
            event.willFireEvent = { (event, transition, value) -> AnyObject? in
                return expectedValue
            }
            expectSuccessWithEvent(event, expectedValue:expectedValue)
        }
        catch let error {
            XCTFail("Error: \(error)")
        }
    }

    func testWillFireEventRejected() {
        do {
            try finiteStateMachine.setInitialState(expectedSourceState)
            let event = try finiteStateMachine.addEvent("event", sources:[expectedSourceState], destination:expectedDestinationState)
            event.willFireEvent = { (event, transition, value) -> AnyObject? in
                return self.dummyError
            }
            expectFailureWithEvent(event, expectedCurrentState:finiteStateMachine.currentState)
        }
        catch let error {
            XCTFail("Error: \(error)")
        }
    }

    func testDidFireEventFulfilled() {
        do {
            try finiteStateMachine.setInitialState(expectedSourceState)
            let event = try finiteStateMachine.addEvent("event", sources:[expectedSourceState], destination:expectedDestinationState)
            let expectedValue = "expectedValue"
            event.didFireEvent = { (event, transition, value) -> AnyObject? in
                return expectedValue
            }
            expectSuccessWithEvent(event, expectedValue:expectedValue)
        }
        catch let error {
            XCTFail("Error: \(error)")
        }
    }

    func testDidFireEventRejected() {
        do {
            try finiteStateMachine.setInitialState(expectedSourceState)
            let event = try finiteStateMachine.addEvent("event", sources:[expectedSourceState], destination:expectedDestinationState)
            event.didFireEvent = { (event, transition, value) -> AnyObject? in
                return self.dummyError
            }
            expectFailureWithEvent(event, expectedCurrentState:expectedDestinationState)
        }
        catch let error {
            XCTFail("Error: \(error)")
        }
    }

    func testWillExitStateFulfilled() {
        do {
            try finiteStateMachine.setInitialState(expectedSourceState)
            let event = try finiteStateMachine.addEvent("event", sources:[expectedSourceState], destination:expectedDestinationState)
            let expectedValue = "expectedValue"
            expectedSourceState.willExitState = { (state, transition, value) -> AnyObject? in
                return expectedValue
            }
            expectSuccessWithEvent(event, expectedValue:expectedValue)
        }
        catch let error {
            XCTFail("Error: \(error)")
        }
    }

    func testWillExitStateRejected() {
        do {
            try finiteStateMachine.setInitialState(expectedSourceState)
            let event = try finiteStateMachine.addEvent("event", sources:[expectedSourceState], destination:expectedDestinationState)
            expectedSourceState.willExitState = { (state, transition, value) -> AnyObject? in
                return self.dummyError
            }
            expectFailureWithEvent(event, expectedCurrentState:finiteStateMachine.currentState)
        }
        catch let error {
            XCTFail("Error: \(error)")
        }
    }

    func testDidExitStateFulfilled() {
        do {
            try finiteStateMachine.setInitialState(expectedSourceState)
            let event = try finiteStateMachine.addEvent("event", sources:[expectedSourceState], destination:expectedDestinationState)
            let expectedValue = "expectedValue"
            expectedSourceState.didExitState = { (state, transition, value) -> AnyObject? in
                return expectedValue
            }
            expectSuccessWithEvent(event, expectedValue:expectedValue)
        }
        catch let error {
            XCTFail("Error: \(error)")
        }
    }

    func testDidExitStateRejected() {
        do {
            try finiteStateMachine.setInitialState(expectedSourceState)
            let event = try finiteStateMachine.addEvent("event", sources:[expectedSourceState], destination:expectedDestinationState)
            expectedSourceState.didExitState = { (state, transition, value) -> AnyObject? in
                return self.dummyError
            }
            expectFailureWithEvent(event, expectedCurrentState:expectedSourceState)
        }
        catch let error {
            XCTFail("Error: \(error)")
        }
    }

    func testWillEnterStateFulfilled() {
        do {
            try finiteStateMachine.setInitialState(expectedSourceState)
            let event = try finiteStateMachine.addEvent("event", sources:[expectedSourceState], destination:expectedDestinationState)
            let expectedValue = "expectedValue"
            expectedDestinationState.willEnterState = { (state, transition, value) -> AnyObject? in
                return expectedValue
            }
            expectSuccessWithEvent(event, expectedValue:expectedValue)
        }
        catch let error {
            XCTFail("Error: \(error)")
        }
    }

    func testWillEnterStateRejected() {
        do {
            try finiteStateMachine.setInitialState(expectedSourceState)
            let event = try finiteStateMachine.addEvent("event", sources:[expectedSourceState], destination:expectedDestinationState)
            expectedDestinationState.willEnterState = { (state, transition, value) -> AnyObject? in
                return self.dummyError
            }
            expectFailureWithEvent(event, expectedCurrentState:finiteStateMachine.currentState)
        }
        catch let error {
            XCTFail("Error: \(error)")
        }
    }

    func testDidEnterStateFulfilled() {
        do {
            try finiteStateMachine.setInitialState(expectedSourceState)
            let event = try finiteStateMachine.addEvent("event", sources:[expectedSourceState], destination:expectedDestinationState)
            let expectedValue = "expectedValue"
            expectedDestinationState.didEnterState = { (state, transition, value) -> AnyObject? in
                return expectedValue
            }
            expectSuccessWithEvent(event, expectedValue:expectedValue)
        }
        catch let error {
            XCTFail("Error: \(error)")
        }
    }

    func testDidEnterStateRejected() {
        do {
            try finiteStateMachine.setInitialState(expectedSourceState)
            let event = try finiteStateMachine.addEvent("event", sources:[expectedSourceState], destination:expectedDestinationState)
            expectedDestinationState.didEnterState = { (state, transition, value) -> AnyObject? in
                return self.dummyError
            }
            expectFailureWithEvent(event, expectedCurrentState:expectedDestinationState)
        }
        catch let error {
            XCTFail("Error: \(error)")
        }
    }

    func testEventOrder() {
        do {
            try finiteStateMachine.setInitialState(expectedSourceState)
            let event = try finiteStateMachine.addEvent("event", sources:[expectedSourceState], destination:expectedDestinationState)

            var firingOrder = 0

            event.willFireEvent = { (event, transition, value) -> AnyObject? in
                XCTAssertEqual(1, ++firingOrder, "Step 1")
                return value
            }
            event.destination.willEnterState = { (state, transition, value) -> AnyObject? in
                XCTAssertEqual(2, ++firingOrder, "Step 2")
                return nil
            }
            event.destination.willExitState = { (state, transition, value) -> AnyObject? in
                XCTFail("should not call destination.willExitState")
                return nil
            }
            expectedSourceState.willEnterState = { (state, transition, value) -> AnyObject? in
                XCTFail("should not call expectedSourceState.willEnterState")
                return nil
            }
            expectedSourceState.willExitState = { (state, transition, value) -> AnyObject? in
                XCTAssertEqual(3, ++firingOrder, "Step 3")
                return nil
            }

            expectedSourceState.didEnterState = { (state, transition, value) -> AnyObject? in
                XCTFail("should not call expectedSourceState.didEnterState")
                return nil
            }
            expectedSourceState.didExitState = { (state, transition, value) -> AnyObject? in
                XCTAssertEqual(4, ++firingOrder, "Step 4")
                return nil
            }
            event.destination.didEnterState = { (state, transition, value) -> AnyObject? in
                XCTAssertEqual(5, ++firingOrder, "Step 5")
                return nil
            }
            event.destination.didExitState = { (state, transition, value) -> AnyObject? in
                XCTFail("should not call destinationState.didExitState")
                return nil
            }
            event.didFireEvent = { (event, transition, value) -> AnyObject? in
                XCTAssertEqual(6, ++firingOrder, "Step 6")
                return nil
            }

            let promise = finiteStateMachine.fireEvent(event, eventTimeout:defaultEventTimeout, initialValue:nil)
            let expectation = expectationWithDescription("expectEventSequence")

            promise.then(
                {
                    value in
                    XCTAssertEqual(6, firingOrder, "Should be last step")
                    expectation.fulfill()
                    return .Value(value)
                }, reject: {
                    error in
                    XCTFail("Should not fail")
                    expectation.fulfill()
                    return .Error(error)
            })
        }
        catch let error {
            XCTFail("Error: \(error)")
        }

        waitForExpectationsWithTimeout(5.0, handler:nil)
    }

    func testEventRejectionPropagation() {
        do {
            try finiteStateMachine.setInitialState(expectedSourceState)
            let event = try finiteStateMachine.addEvent("event", sources:[expectedSourceState], destination:expectedDestinationState)

            var firingOrder = 0

            event.willFireEvent = { (event, transition, value) -> AnyObject? in
                XCTAssertEqual(1, ++firingOrder, "Step 1")
                return value
            }
            event.destination.willEnterState = { (state, transition, value) -> AnyObject? in
                XCTAssertEqual(2, ++firingOrder, "Step 2")
                return nil
            }
            event.destination.willExitState = { (state, transition, value) -> AnyObject? in
                XCTFail("should not call destination.willExitState")
                return nil
            }
            expectedSourceState.willEnterState = { (state, transition, value) -> AnyObject? in
                XCTFail("should not call expectedSourceState.willEnterState")
                return nil
            }
            expectedSourceState.willExitState = { (state, transition, value) -> AnyObject? in
                XCTAssertEqual(3, ++firingOrder, "Step 3")
                return self.dummyError
            }

            expectedSourceState.didEnterState = { (state, transition, value) -> AnyObject? in
                XCTFail("should not call expectedSourceState.didEnterState")
                return nil
            }
            expectedSourceState.didExitState = { (state, transition, value) -> AnyObject? in
                XCTAssertEqual(4, ++firingOrder, "Step 4")
                return nil
            }
            event.destination.didEnterState = { (state, transition, value) -> AnyObject? in
                XCTAssertEqual(5, ++firingOrder, "Step 5")
                return nil
            }
            event.destination.didExitState = { (state, transition, value) -> AnyObject? in
                XCTFail("should not call destinationState.didExitState")
                return nil
            }
            event.didFireEvent = { (event, transition, value) -> AnyObject? in
                XCTAssertEqual(6, ++firingOrder, "Step 6")
                return nil
            }

            let promise = finiteStateMachine.fireEvent(event, eventTimeout:defaultEventTimeout, initialValue:nil)
            let expectation = expectationWithDescription("expectEventSequence")

            promise.then(
                {
                    value in
                    XCTFail("Should have failed at step 3")
                    expectation.fulfill()
                    return .Value(value)
                }, reject: {
                    error in
                    XCTAssertEqual(3, firingOrder, "Should fail at step 3")
                    expectation.fulfill()
                    return .Error(error)
            })
        }
        catch let error {
            XCTFail("Error: \(error)")
        }

        waitForExpectationsWithTimeout(5.0, handler:nil)
    }

    func testEventInitialValue() {
        do {
            try finiteStateMachine.setInitialState(expectedSourceState)
            let event = try finiteStateMachine.addEvent("event", sources:[expectedSourceState], destination:expectedDestinationState)

            var firingOrder = 0

            event.willFireEvent = { (event, transition, value) -> AnyObject? in
                var array = value as! [Int]
                array.append(++firingOrder)
                return array
            }
            event.destination.willEnterState = { (state, transition, value) -> AnyObject? in
                var array = value as! [Int]
                array.append(++firingOrder)
                return array
            }
            expectedSourceState.willExitState = { (state, transition, value) -> AnyObject? in
                var array = value as! [Int]
                array.append(++firingOrder)
                return array
            }
            expectedSourceState.didExitState = { (state, transition, value) -> AnyObject? in
                var array = value as! [Int]
                array.append(++firingOrder)
                return array
            }
            event.destination.didEnterState = { (state, transition, value) -> AnyObject? in
                var array = value as! [Int]
                array.append(++firingOrder)
                return array
            }
            event.didFireEvent = { (event, transition, value) -> AnyObject? in
                var array = value as! [Int]
                array.append(++firingOrder)
                return array
            }

            let initialValue:[Int] = []
            let promise = finiteStateMachine.fireEvent(event, eventTimeout:defaultEventTimeout, initialValue:initialValue)
            let expectation = expectationWithDescription("expectEventSequence")

            promise.then(
                {
                    value in
                    if let array = value as? [Int] {
                        let expectedValue = [1,2,3,4,5,6]
                        XCTAssertEqual(expectedValue, array, "should have accumulated values in array passed in as intial value")
                    } else {
                        XCTFail("value should be [Int]")
                    }
                    expectation.fulfill()
                    return .Value(value)
                }, reject: {
                    error in
                    XCTFail("Should not fail")
                    expectation.fulfill()
                    return .Error(error)
            })
        }
        catch let error {
            XCTFail("Error: \(error)")
        }
        
        waitForExpectationsWithTimeout(5.0, handler:nil)
    }
    
}
