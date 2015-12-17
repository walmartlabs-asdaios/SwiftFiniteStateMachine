//
//  FSMLockingTests.swift
//  SwiftFiniteStateMachine
//
//  Created by Douglas Sjoquist on 2/26/15.
//  Copyright (c) 2015 Ivy Gulch LLC. All rights reserved.
//

import UIKit
import XCTest
@testable import SwiftFiniteStateMachine

class FSMLockingTests: XCTestCase {

    let defaultEventTimeout:NSTimeInterval = 10.0

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
        do {
            state1 = try finiteStateMachine.addState("state1")
            state2 = try finiteStateMachine.addState("state2")
            state3 = try finiteStateMachine.addState("state3")
            event1to2 = try finiteStateMachine.addEvent("event1to2", sources:[state1], destination:state2)
            event2to3 = try finiteStateMachine.addEvent("event2to3", sources:[state2], destination:state3)
            event3to1 = try finiteStateMachine.addEvent("event3to1", sources:[state3], destination:state1)

            try finiteStateMachine.setInitialState(state1)
        }
        catch let error {
            XCTFail("Error: \(error)")
        }
    }

    func testSimpleConflictingCall() {
        let timeout:NSTimeInterval = 1.0

        let event1to2Expectation = expectationWithDescription("event1to2Expectation")
        event1to2.willFireEvent = { (event,transition,value) in
            // Delay one of the steps for a bit, but shorter than the event timeout threshold
            return self.delayedFulfilledPromise(timeout/2.0, value:value)
        }

        let promise = finiteStateMachine.fireEvent(event1to2, eventTimeout:defaultEventTimeout, initialValue:nil)
        promise.then(
            {
                value in
                event1to2Expectation.fulfill()
                return .Value(value)
            }, reject: {
                error in
                event1to2Expectation.fulfill()
                XCTFail("Should not have been rejected")
                return .Error(error)
        })

        let conflictingPromise = finiteStateMachine.fireEvent(event2to3, eventTimeout:timeout, initialValue:nil)
        XCTAssertTrue(conflictingPromise.isRejected)

        // wait long enough for timeout to trigger
        waitForExpectationsWithTimeout(timeout*2.0, handler:nil)

        let nonConflictingPromise = finiteStateMachine.fireEvent(event2to3, eventTimeout:defaultEventTimeout, initialValue:nil)
        XCTAssertFalse(nonConflictingPromise.isRejected)
    }

    func testAsyncConflictingCall() {
        let timeout:NSTimeInterval = 1.0

        let event1to2Expectation = expectationWithDescription("event1to2Expectation")
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            self.event1to2.willFireEvent = { (event,transition,value) -> AnyObject? in
                XCTAssertNotNil(self.finiteStateMachine.pendingEvent)

                // Delay one of the steps for a bit, but shorter than the event timeout threshold
                return self.delayedFulfilledPromise(timeout/2.0, value:value)
            }
            let promise1to2 = self.finiteStateMachine.fireEvent(self.event1to2, eventTimeout:timeout, initialValue:nil)
            promise1to2.then(
                {
                    value in
                    event1to2Expectation.fulfill()
                    XCTAssertNil(self.finiteStateMachine.pendingEvent)
                    return .Value(value)
                }, reject: {
                    error in
                    event1to2Expectation.fulfill()
                    XCTFail("Should not have been rejected")
                    return .Error(error)
                }
            )
        })

        // ensure second event isn't attempted until after first has a chance to start
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.2 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            let conflictingPromise = self.finiteStateMachine.fireEvent(self.event2to3, eventTimeout:self.defaultEventTimeout, initialValue:nil)
            XCTAssertTrue(conflictingPromise.isRejected)
        })
        
        // wait long enough for timeout to trigger
        waitForExpectationsWithTimeout(timeout*2.0, handler:nil)
    }
    
}
