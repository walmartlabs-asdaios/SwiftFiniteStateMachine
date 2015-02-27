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
        event.willFireEvent = { (event, transition, value) -> AnyObject? in
            return nil
        }
        expectSuccessWithEvent(event, expectedValue:nil)
    }

    func testWillFireEventRejected() {
        finiteStateMachine.setInitialState(expectedSourceState, error:nil)
        let event = finiteStateMachine.addEvent("event", sources:[expectedSourceState], destination:expectedDestinationState, error:nil)!
        event.willFireEvent = { (event, transition, value) -> AnyObject? in
            return self.dummyError
        }
        expectFailureWithEvent(event)
    }

    func testWillExitStateFulfilled() {
        finiteStateMachine.setInitialState(expectedSourceState, error:nil)
        let event = finiteStateMachine.addEvent("event", sources:[expectedSourceState], destination:expectedDestinationState, error:nil)!
        expectedSourceState.willExitState = { (state, transition, value) -> AnyObject? in
            return nil
        }
        expectSuccessWithEvent(event, expectedValue:nil)
    }

    func testWillExitStateRejected() {
        finiteStateMachine.setInitialState(expectedSourceState, error:nil)
        let event = finiteStateMachine.addEvent("event", sources:[expectedSourceState], destination:expectedDestinationState, error:nil)!
        expectedSourceState.willExitState = { (state, transition, value) -> AnyObject? in
            return self.dummyError
        }
        expectFailureWithEvent(event)
    }

/*
    - (void) testExitStateYES;
    {
    [self.finiteStateMachine initializeWithState:self.expectedSourceState error:nil];
    ASDAFSMEvent *event = [self.finiteStateMachine addEventWithName:@"event"
    sources:@[self.expectedSourceState]
    destination:self.expectedDestinationState
    error:nil];
    self.expectedSourceState.willExitStateBlock = ^id(ASDAFSMState *stateArg, ASDAFSMTransition *transitionArg, id value) {
    return nil;
    };
    [self expectSuccessWithEvent:event resolvedValue:nil];
    }

    - (void) testExitStateNO;
    {
    [self.finiteStateMachine initializeWithState:self.expectedSourceState error:nil];
    ASDAFSMEvent *event = [self.finiteStateMachine addEventWithName:@"event"
    sources:@[self.expectedSourceState]
    destination:self.expectedDestinationState
    error:nil];
    self.expectedSourceState.willExitStateBlock = ^id(ASDAFSMState *stateArg, ASDAFSMTransition *transitionArg, id value) {
    return [NSError errorWithDomain:@"test" code:-1 userInfo:nil];
    };
    [self expectFailureWithEvent:event];
    }

    - (void) testEnterStateYes;
    {
    [self.finiteStateMachine initializeWithState:self.expectedSourceState error:nil];
    ASDAFSMEvent *event = [self.finiteStateMachine addEventWithName:@"event"
    sources:@[self.expectedSourceState]
    destination:self.expectedDestinationState
    error:nil];
    id expectedValue = @"expected value";
    event.destinationState.willEnterStateBlock = ^id(ASDAFSMState *stateArg, ASDAFSMTransition *transitionArg, id value) {
    return resolvedPromise(expectedValue);
    };
    [self expectSuccessWithEvent:event resolvedValue:expectedValue];
    }

    - (void) testEnterStateNO;
    {
    [self.finiteStateMachine initializeWithState:self.expectedSourceState error:nil];
    ASDAFSMEvent *event = [self.finiteStateMachine addEventWithName:@"event"
    sources:@[self.expectedSourceState]
    destination:self.expectedDestinationState
    error:nil];
    event.destinationState.willEnterStateBlock = ^id(ASDAFSMState *stateArg, ASDAFSMTransition *transitionArg, id value) {
    return [NSError errorWithDomain:@"test" code:-1 userInfo:nil];
    };
    [self expectFailureWithEvent:event];
    }

    - (void) testEventOrder;
    {
    [self.finiteStateMachine initializeWithState:self.expectedSourceState error:nil];
    ASDAFSMEvent *event = [self.finiteStateMachine addEventWithName:@"event"
    sources:@[self.expectedSourceState]
    destination:self.expectedDestinationState
    error:nil];

    @weakify(self);
    __block NSInteger firingOrder = 0;
    event.willFireEventBlock = ^id(ASDAFSMEvent *eventArg, ASDAFSMTransition *transitionArg, id value) {
    @strongify(self);
    XCTAssertEqual(1, ++firingOrder, @"Step 1");
    return nil;
    };
    event.destinationState.willEnterStateBlock = ^id(ASDAFSMState *stateArg, ASDAFSMTransition *transitionArg, id value) {
    @strongify(self);
    XCTAssertEqual(2, ++firingOrder, @"Step 2");
    return nil;
    };
    event.destinationState.willExitStateBlock = ^id(ASDAFSMState *stateArg, ASDAFSMTransition *transitionArg, id value) {
    @strongify(self);
    XCTFail(@"should not call destinationState.willExitStateBlock");
    return nil;
    };
    self.expectedSourceState.willEnterStateBlock = ^id(ASDAFSMState *stateArg, ASDAFSMTransition *transitionArg, id value) {
    @strongify(self);
    XCTFail(@"should not call expectedSourceState.willEnterStateBlock");
    return nil;
    };
    self.expectedSourceState.willExitStateBlock = ^id(ASDAFSMState *stateArg, ASDAFSMTransition *transitionArg, id value) {
    @strongify(self);
    XCTAssertEqual(3, ++firingOrder, @"Step 3");
    return nil;
    };

    self.expectedSourceState.didEnterStateBlock = ^id(ASDAFSMState *stateArg, ASDAFSMTransition *transitionArg, id value) {
    @strongify(self);
    XCTFail(@"should not call expectedSourceState.didEnterStateBlock");
    return nil;
    };
    self.expectedSourceState.didExitStateBlock = ^id(ASDAFSMState *stateArg, ASDAFSMTransition *transitionArg, id value) {
    @strongify(self);
    XCTAssertEqual(4, ++firingOrder, @"Step 4");
    return nil;
    };
    event.destinationState.didEnterStateBlock = ^id(ASDAFSMState *stateArg, ASDAFSMTransition *transitionArg, id value) {
    @strongify(self);
    XCTAssertEqual(5, ++firingOrder, @"Step 5");
    return nil;
    };
    event.destinationState.didExitStateBlock = ^id(ASDAFSMState *stateArg, ASDAFSMTransition *transitionArg, id value) {
    @strongify(self);
    XCTFail(@"should not call destinationState.didExitStateBlock");
    return nil;
    };
    event.didFireEventBlock = ^id(ASDAFSMEvent *eventArg, ASDAFSMTransition *transitionArg, id value) {
    @strongify(self);
    XCTAssertEqual(6, ++firingOrder, @"Step 6");
    return nil;
    };

    SDPromise *result = [self.finiteStateMachine fireEvent:event withInitialValue:nil];
    XCTAssertTrue([result isKindOfClass:[SDPromise class]]);
    XCTestExpectation *expectation = [self expectationWithDescription:@"expectEventSequence"];
    [result then:^id(id dataObject) {
    @strongify(self);
    XCTAssertEqual(6, firingOrder, @"Should be last step");
    [expectation fulfill];
    return nil;
    } reject:^id(NSError *error) {
    @strongify(self);
    XCTFail(@"Should not fail");
    [expectation fulfill];
    return nil;
    }];
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
    XCTAssertNil(error);
    }];
    }

    - (void) testEventRejectionPropagation;
    {
    [self.finiteStateMachine initializeWithState:self.expectedSourceState error:nil];
    ASDAFSMEvent *event = [self.finiteStateMachine addEventWithName:@"event"
    sources:@[self.expectedSourceState]
    destination:self.expectedDestinationState
    error:nil];

    @weakify(self);
    __block NSInteger firingOrder = 0;
    event.willFireEventBlock = ^id(ASDAFSMEvent *eventArg, ASDAFSMTransition *transitionArg, id value) {
    @strongify(self);
    XCTAssertEqual(1, ++firingOrder, @"Step 1");
    return nil;
    };
    event.destinationState.willEnterStateBlock = ^id(ASDAFSMState *stateArg, ASDAFSMTransition *transitionArg, id value) {
    @strongify(self);
    XCTAssertEqual(2, ++firingOrder, @"Step 2");
    return nil;
    };
    event.destinationState.willExitStateBlock = ^id(ASDAFSMState *stateArg, ASDAFSMTransition *transitionArg, id value) {
    @strongify(self);
    XCTFail(@"should not call destinationState.willExitStateBlock");
    return nil;
    };
    self.expectedSourceState.willEnterStateBlock = ^id(ASDAFSMState *stateArg, ASDAFSMTransition *transitionArg, id value) {
    @strongify(self);
    XCTFail(@"should not call expectedSourceState.willEnterStateBlock");
    return nil;
    };
    self.expectedSourceState.willExitStateBlock = ^id(ASDAFSMState *stateArg, ASDAFSMTransition *transitionArg, id value) {
    firingOrder += 1;
    return rejectedPromise([NSError errorWithDomain:@"fail at willExitStateBlock" code:-1 userInfo:nil]);
    };

    self.expectedSourceState.didEnterStateBlock = ^id(ASDAFSMState *stateArg, ASDAFSMTransition *transitionArg, id value) {
    @strongify(self);
    XCTFail(@"should not call expectedSourceState.didEnterStateBlock");
    return nil;
    };
    self.expectedSourceState.didExitStateBlock = ^id(ASDAFSMState *stateArg, ASDAFSMTransition *transitionArg, id value) {
    @strongify(self);
    XCTAssertEqual(4, ++firingOrder, @"Step 4");
    return nil;
    };
    event.destinationState.didEnterStateBlock = ^id(ASDAFSMState *stateArg, ASDAFSMTransition *transitionArg, id value) {
    @strongify(self);
    XCTAssertEqual(5, ++firingOrder, @"Step 5");
    return nil;
    };
    event.destinationState.didExitStateBlock = ^id(ASDAFSMState *stateArg, ASDAFSMTransition *transitionArg, id value) {
    @strongify(self);
    XCTFail(@"should not call destinationState.didExitStateBlock");
    return nil;
    };
    event.didFireEventBlock = ^id(ASDAFSMEvent *eventArg, ASDAFSMTransition *transitionArg, id value) {
    @strongify(self);
    XCTAssertEqual(6, ++firingOrder, @"Step 6");
    return nil;
    };

    SDPromise *result = [self.finiteStateMachine fireEvent:event withInitialValue:nil];
    XCTAssertTrue([result isKindOfClass:[SDPromise class]]);
    XCTestExpectation *expectation = [self expectationWithDescription:@"expectEventSequence"];
    [result then:^id(id dataObject) {
    @strongify(self);
    XCTFail(@"Should have failed at step 3");
    [expectation fulfill];
    return nil;
    } reject:^id(NSError *error) {
    @strongify(self);
    XCTAssertEqual(3, firingOrder, @"Should fail at step 3");
    [expectation fulfill];
    return nil;
    }];
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
    XCTAssertNil(error);
    }];
    }


    - (void) testEventInitialValue;
    {
    [self.finiteStateMachine initializeWithState:self.expectedSourceState error:nil];
    ASDAFSMEvent *event = [self.finiteStateMachine addEventWithName:@"event"
    sources:@[self.expectedSourceState]
    destination:self.expectedDestinationState
    error:nil];

    // assume value passed through is mutable array
    __block NSInteger firingOrder = 0;
    @weakify(self);
    event.willFireEventBlock = ^id(ASDAFSMEvent *eventArg, ASDAFSMTransition *transitionArg, id value) {
    [value addObject:@(++firingOrder)];
    return value;
    };
    event.destinationState.willEnterStateBlock = ^id(ASDAFSMState *stateArg, ASDAFSMTransition *transitionArg, id value) {
    [value addObject:@(++firingOrder)];
    return value;
    };
    event.destinationState.willExitStateBlock = ^id(ASDAFSMState *stateArg, ASDAFSMTransition *transitionArg, id value) {
    @strongify(self);
    XCTFail(@"should not call destinationState.willExitStateBlock");
    return nil;
    };
    self.expectedSourceState.willEnterStateBlock = ^id(ASDAFSMState *stateArg, ASDAFSMTransition *transitionArg, id value) {
    @strongify(self);
    XCTFail(@"should not call expectedSourceState.willEnterStateBlock");
    return nil;
    };
    self.expectedSourceState.willExitStateBlock = ^id(ASDAFSMState *stateArg, ASDAFSMTransition *transitionArg, id value) {
    [value addObject:@(++firingOrder)];
    return value;
    };

    self.expectedSourceState.didEnterStateBlock = ^id(ASDAFSMState *stateArg, ASDAFSMTransition *transitionArg, id value) {
    @strongify(self);
    XCTFail(@"should not call expectedSourceState.didEnterStateBlock");
    return nil;
    };
    self.expectedSourceState.didExitStateBlock = ^id(ASDAFSMState *stateArg, ASDAFSMTransition *transitionArg, id value) {
    [value addObject:@(++firingOrder)];
    return value;
    };
    event.destinationState.didEnterStateBlock = ^id(ASDAFSMState *stateArg, ASDAFSMTransition *transitionArg, id value) {
    [value addObject:@(++firingOrder)];
    return value;
    };
    event.destinationState.didExitStateBlock = ^id(ASDAFSMState *stateArg, ASDAFSMTransition *transitionArg, id value) {
    @strongify(self);
    XCTFail(@"should not call destinationState.didExitStateBlock");
    return nil;
    };
    event.didFireEventBlock = ^id(ASDAFSMEvent *eventArg, ASDAFSMTransition *transitionArg, id value) {
    [value addObject:@(++firingOrder)];
    return value;
    };

    NSMutableArray *initialValue = [NSMutableArray array];
    SDPromise *result = [self.finiteStateMachine fireEvent:event withInitialValue:initialValue];
    XCTAssertTrue([result isKindOfClass:[SDPromise class]]);
    XCTestExpectation *expectation = [self expectationWithDescription:@"expectEventSequence"];
    [result then:^id(id dataObject) {
    @strongify(self);
    XCTAssertEqual(initialValue, dataObject, @"In this example, it should be the exact same object passed in originally");
    NSArray *expectedValue = @[@(1),@(2),@(3),@(4),@(5),@(6)];
    XCTAssertEqualObjects(expectedValue, dataObject, @"should have accumulated values in array passed in as intial value");
    [expectation fulfill];
    return nil;
    } reject:^id(NSError *error) {
    @strongify(self);
    XCTFail(@"Should not fail");
    [expectation fulfill];
    return nil;
    }];
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
    XCTAssertNil(error);
    }];
    }


*/

}
