//
//  FSMLockingTests.swift
//  SwiftFiniteStateMachine
//
//  Created by Douglas Sjoquist on 2/26/15.
//  Copyright (c) 2015 Ivy Gulch LLC. All rights reserved.
//

import UIKit
import XCTest

class FSMLockingTests: FSMTestCase {

    var finiteStateMachine:FSMFiniteStateMachine!
    var state1:FSMState!
    var state2:FSMState!
    var state3:FSMState!
    var event1to2:FSMEvent!
    var event2to3:FSMEvent!
    var event3to1:FSMEvent!

    override func setUp() {
        super.setUp()

        finiteStateMachine = FSMFiniteStateMachine()
        state1 = finiteStateMachine.addState("state1", error:nil)
        state2 = finiteStateMachine.addState("state2", error:nil)
        state3 = finiteStateMachine.addState("state3", error:nil)
        event1to2 = finiteStateMachine.addEvent("event1to2", sources:[state1], destination:state2, error:nil)
        event2to3 = finiteStateMachine.addEvent("event2to3", sources:[state2], destination:state3, error:nil)
        event3to1 = finiteStateMachine.addEvent("event3to1", sources:[state3], destination:state1, error:nil)

        finiteStateMachine.setInitialState(state1, error:nil)
    }

    func testSimpleConflictingCall() {
        let timeout:NSTimeInterval = 1.0
        event1to2.eventTimeout = timeout

        let event1to2Expectation = expectationWithDescription("event1to2Expectation")
        event1to2.willFireEvent = { (event,transition,value) in
            // Delay one of the steps for a bit, but shorter than the event timeout threshold
            return self.delayedFulfilledPromise(timeout/2.0, value:value)
        }

        let promise = finiteStateMachine.fireEvent(event1to2, initialValue:nil)
        promise.then(
            { (value) -> AnyObject? in
                event1to2Expectation.fulfill()
                return value
            }, reject: { (error) -> NSError in
                event1to2Expectation.fulfill()
                XCTFail("Should not have been rejected")
                return error
        })

        let conflictingPromise = finiteStateMachine.fireEvent(event2to3, initialValue:nil)
        XCTAssertTrue(conflictingPromise.isRejected)

        // wait long enough for timeout to trigger
        waitForExpectationsWithTimeout(timeout*2.0, handler:nil)

        let nonConflictingPromise = finiteStateMachine.fireEvent(event2to3, initialValue:nil)
        XCTAssertFalse(nonConflictingPromise.isRejected)
    }

    func testAsyncConflictingCall() {
        let timeout:NSTimeInterval = 1.0
        event1to2.eventTimeout = timeout

        let event1to2Expectation = expectationWithDescription("event1to2Expectation")
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            self.event1to2.willFireEvent = { (event,transition,value) -> AnyObject? in
                XCTAssertNotNil(self.finiteStateMachine.pendingEvent)

                // Delay one of the steps for a bit, but shorter than the event timeout threshold
                return self.delayedFulfilledPromise(timeout/2.0, value:value)
            }
            let promise1to2 = self.finiteStateMachine.fireEvent(self.event1to2, initialValue:nil)
            promise1to2.then(
                { (value) -> AnyObject? in
                    event1to2Expectation.fulfill()
                    XCTAssertNil(self.finiteStateMachine.pendingEvent)
                    return value
                }, reject: { (error) -> NSError in
                    event1to2Expectation.fulfill()
                    XCTFail("Should not have been rejected")
                    return error
                }
            )
        })

        // ensure second event isn't attempted until after first has a chance to start
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.2 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            let conflictingPromise = self.finiteStateMachine.fireEvent(self.event2to3, initialValue:nil)
            XCTAssertTrue(conflictingPromise.isRejected)
        })

        // wait long enough for timeout to trigger
        waitForExpectationsWithTimeout(timeout*2.0, handler:nil)
    }

}
