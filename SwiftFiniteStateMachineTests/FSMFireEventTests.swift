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

    let defaultEventTimeout:NSTimeInterval = 10.0

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
        let promise = finiteStateMachine.fireEvent(event, eventTimeout:defaultEventTimeout, initialValue:nil)

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

    func expectFailureWithEvent(event:FSMEvent, expectedCurrentState:FSMState?) {
        XCTAssertEqualOptional(expectedSourceState, finiteStateMachine.currentState)
        let promise = finiteStateMachine.fireEvent(event, eventTimeout:defaultEventTimeout, initialValue:nil)

        let expectation = expectationWithDescription("expectFailureWithEvent")
        promise.then(
            { (value) -> AnyObject? in
                XCTFail("Should not succeed")
                expectation.fulfill()
                return nil
            }, reject: { (error) -> NSError in
                XCTAssertEqualOptional(expectedCurrentState, self.finiteStateMachine.currentState)
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
        expectFailureWithEvent(event, expectedCurrentState:finiteStateMachine.currentState)
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
        expectFailureWithEvent(event, expectedCurrentState:finiteStateMachine.currentState)
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
        expectFailureWithEvent(event, expectedCurrentState:expectedDestinationState)
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
        expectFailureWithEvent(event, expectedCurrentState:finiteStateMachine.currentState)
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
        expectFailureWithEvent(event, expectedCurrentState:expectedDestinationState)
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
        expectFailureWithEvent(event, expectedCurrentState:finiteStateMachine.currentState)
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
        expectFailureWithEvent(event, expectedCurrentState:expectedDestinationState)
    }

    func testEventOrder() {
        finiteStateMachine.setInitialState(expectedSourceState, error:nil)
        let event = finiteStateMachine.addEvent("event", sources:[expectedSourceState], destination:expectedDestinationState, error:nil)!

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
            { (value) -> AnyObject? in
                XCTAssertEqual(6, firingOrder, "Should be last step")
                expectation.fulfill()
                return value
            }, reject: { (error) -> NSError in
                XCTFail("Should not fail")
                expectation.fulfill()
                return error
        })

        waitForExpectationsWithTimeout(5.0, handler:nil)
    }

    func testEventRejectionPropagation() {
        finiteStateMachine.setInitialState(expectedSourceState, error:nil)
        let event = finiteStateMachine.addEvent("event", sources:[expectedSourceState], destination:expectedDestinationState, error:nil)!

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
            { (value) -> AnyObject? in
                XCTFail("Should have failed at step 3")
                expectation.fulfill()
                return value
            }, reject: { (error) -> NSError in
                XCTAssertEqual(3, firingOrder, "Should fail at step 3")
                expectation.fulfill()
                return error
        })

        waitForExpectationsWithTimeout(5.0, handler:nil)
    }

    func testEventInitialValue() {
        finiteStateMachine.setInitialState(expectedSourceState, error:nil)
        let event = finiteStateMachine.addEvent("event", sources:[expectedSourceState], destination:expectedDestinationState, error:nil)!

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

        var initialValue:[Int] = []
        let promise = finiteStateMachine.fireEvent(event, eventTimeout:defaultEventTimeout, initialValue:initialValue)
        let expectation = expectationWithDescription("expectEventSequence")

        promise.then(
            { (value) -> AnyObject? in
                if let array = value as? [Int] {
                    let expectedValue = [1,2,3,4,5,6]
                    XCTAssertEqual(expectedValue, array, "should have accumulated values in array passed in as intial value")
                } else {
                    XCTFail("value should be [Int]")
                }
                expectation.fulfill()
                return value
            }, reject: { (error) -> NSError in
                XCTFail("Should not fail")
                expectation.fulfill()
                return error
        })

        waitForExpectationsWithTimeout(5.0, handler:nil)
    }

}
