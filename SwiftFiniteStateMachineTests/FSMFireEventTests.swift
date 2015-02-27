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

    func expectFailureWithEvent(event:FSMEvent, expectedCurrentState:FSMState?) {
        XCTAssertEqualOptional(expectedSourceState, finiteStateMachine.currentState)
        let promise = finiteStateMachine.fireEvent(event, initialValue:nil)

        let expectation = expectationWithDescription("expectFailureWithEvent")
        promise.then({ (value) -> AnyObject? in
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

        let promise = finiteStateMachine.fireEvent(event, initialValue:nil)
        let expectation = expectationWithDescription("expectEventSequence")

        promise.then({ (value) -> AnyObject? in
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

    /*
    - (void) testEventRejectionPropagation
    {
    [self.finiteStateMachine initializeWithState:self.expectedSourceState error:nil]
    ASDAFSMEvent *event = [self.finiteStateMachine addEventWithName:"event"
    sources:@[self.expectedSourceState]
    destination:self.expectedDestinationState
    error:nil]

    @weakify(self)
    __block NSInteger firingOrder = 0
    event.willFireEventBlock = ^id(ASDAFSMEvent *eventArg, ASDAFSMTransition *transitionArg, id value) {
    @strongify(self)
    XCTAssertEqual(1, ++firingOrder, "Step 1")
    return nil
    }
    event.destinationState.willEnterStateBlock = ^id(ASDAFSMState *stateArg, ASDAFSMTransition *transitionArg, id value) {
    @strongify(self)
    XCTAssertEqual(2, ++firingOrder, "Step 2")
    return nil
    }
    event.destinationState.willExitStateBlock = ^id(ASDAFSMState *stateArg, ASDAFSMTransition *transitionArg, id value) {
    @strongify(self)
    XCTFail("should not call destinationState.willExitState")
    return nil
    }
    self.expectedSourceState.willEnterStateBlock = ^id(ASDAFSMState *stateArg, ASDAFSMTransition *transitionArg, id value) {
    @strongify(self)
    XCTFail("should not call expectedSourceState.willEnterState")
    return nil
    }
    self.expectedSourceState.willExitStateBlock = ^id(ASDAFSMState *stateArg, ASDAFSMTransition *transitionArg, id value) {
    firingOrder += 1
    return rejectedPromise([NSError errorWithDomain:"fail at willExitState" code:-1 userInfo:nil])
    }

    self.expectedSourceState.didEnterStateBlock = ^id(ASDAFSMState *stateArg, ASDAFSMTransition *transitionArg, id value) {
    @strongify(self)
    XCTFail("should not call expectedSourceState.didEnterState")
    return nil
    }
    self.expectedSourceState.didExitStateBlock = ^id(ASDAFSMState *stateArg, ASDAFSMTransition *transitionArg, id value) {
    @strongify(self)
    XCTAssertEqual(4, ++firingOrder, "Step 4")
    return nil
    }
    event.destinationState.didEnterStateBlock = ^id(ASDAFSMState *stateArg, ASDAFSMTransition *transitionArg, id value) {
    @strongify(self)
    XCTAssertEqual(5, ++firingOrder, "Step 5")
    return nil
    }
    event.destinationState.didExitStateBlock = ^id(ASDAFSMState *stateArg, ASDAFSMTransition *transitionArg, id value) {
    @strongify(self)
    XCTFail("should not call destinationState.didExitState")
    return nil
    }
    event.didFireEventBlock = ^id(ASDAFSMEvent *eventArg, ASDAFSMTransition *transitionArg, id value) {
    @strongify(self)
    XCTAssertEqual(6, ++firingOrder, "Step 6")
    return nil
    }

    SDPromise *result = [self.finiteStateMachine fireEvent:event withInitialValue:nil]
    XCTAssertTrue([result isKindOfClass:[SDPromise class]])
    XCTestExpectation *expectation = [self expectationWithDescription:"expectEventSequence"]
    [result then:^id(id dataObject) {
    @strongify(self)
    XCTFail("Should have failed at step 3")
    [expectation fulfill]
    return nil
    } reject:^id(NSError *error) {
    @strongify(self)
    XCTAssertEqual(3, firingOrder, "Should fail at step 3")
    [expectation fulfill]
    return nil
    }]
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
    XCTAssertNil(error)
    }]
    }


    - (void) testEventInitialValue
    {
    [self.finiteStateMachine initializeWithState:self.expectedSourceState error:nil]
    ASDAFSMEvent *event = [self.finiteStateMachine addEventWithName:"event"
    sources:@[self.expectedSourceState]
    destination:self.expectedDestinationState
    error:nil]

    // assume value passed through is mutable array
    __block NSInteger firingOrder = 0
    @weakify(self)
    event.willFireEventBlock = ^id(ASDAFSMEvent *eventArg, ASDAFSMTransition *transitionArg, id value) {
    [value addObject:@(++firingOrder)]
    return value
    }
    event.destinationState.willEnterStateBlock = ^id(ASDAFSMState *stateArg, ASDAFSMTransition *transitionArg, id value) {
    [value addObject:@(++firingOrder)]
    return value
    }
    event.destinationState.willExitStateBlock = ^id(ASDAFSMState *stateArg, ASDAFSMTransition *transitionArg, id value) {
    @strongify(self)
    XCTFail("should not call destinationState.willExitState")
    return nil
    }
    self.expectedSourceState.willEnterStateBlock = ^id(ASDAFSMState *stateArg, ASDAFSMTransition *transitionArg, id value) {
    @strongify(self)
    XCTFail("should not call expectedSourceState.willEnterState")
    return nil
    }
    self.expectedSourceState.willExitStateBlock = ^id(ASDAFSMState *stateArg, ASDAFSMTransition *transitionArg, id value) {
    [value addObject:@(++firingOrder)]
    return value
    }

    self.expectedSourceState.didEnterStateBlock = ^id(ASDAFSMState *stateArg, ASDAFSMTransition *transitionArg, id value) {
    @strongify(self)
    XCTFail("should not call expectedSourceState.didEnterState")
    return nil
    }
    self.expectedSourceState.didExitStateBlock = ^id(ASDAFSMState *stateArg, ASDAFSMTransition *transitionArg, id value) {
    [value addObject:@(++firingOrder)]
    return value
    }
    event.destinationState.didEnterStateBlock = ^id(ASDAFSMState *stateArg, ASDAFSMTransition *transitionArg, id value) {
    [value addObject:@(++firingOrder)]
    return value
    }
    event.destinationState.didExitStateBlock = ^id(ASDAFSMState *stateArg, ASDAFSMTransition *transitionArg, id value) {
    @strongify(self)
    XCTFail("should not call destinationState.didExitState")
    return nil
    }
    event.didFireEventBlock = ^id(ASDAFSMEvent *eventArg, ASDAFSMTransition *transitionArg, id value) {
    [value addObject:@(++firingOrder)]
    return value
    }

    NSMutableArray *initialValue = [NSMutableArray array]
    SDPromise *result = [self.finiteStateMachine fireEvent:event withInitialValue:initialValue]
    XCTAssertTrue([result isKindOfClass:[SDPromise class]])
    XCTestExpectation *expectation = [self expectationWithDescription:"expectEventSequence"]
    [result then:^id(id dataObject) {
    @strongify(self)
    XCTAssertEqual(initialValue, dataObject, "In this example, it should be the exact same object passed in originally")
    NSArray *expectedValue = @[@(1),@(2),@(3),@(4),@(5),@(6)]
    XCTAssertEqualObjects(expectedValue, dataObject, "should have accumulated values in array passed in as intial value")
    [expectation fulfill]
    return nil
    } reject:^id(NSError *error) {
    @strongify(self)
    XCTFail("Should not fail")
    [expectation fulfill]
    return nil
    }]
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
    XCTAssertNil(error)
    }]
    }
    
    
    */
    
}
