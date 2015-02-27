//
//  FSMEventTimeoutTests.swift
//  SwiftFiniteStateMachine
//
//  Created by Douglas Sjoquist on 2/26/15.
//  Copyright (c) 2015 Ivy Gulch LLC. All rights reserved.
//

import UIKit
import XCTest

class FSMEventTimeoutTests: FSMTestCase {
    
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

    func testSimpleTimeout() {
        let timeout:NSTimeInterval = 1.0
        event1to2.eventTimeout = timeout

        let expectation = expectationWithDescription("expectation")
        event1to2.willFireEvent = { (event, transition, value) -> AnyObject? in
            // Delay one of the steps longer than the event timeout threshold
            let deferred = Promise()
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(timeout * 5.0 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                deferred.fulfill(value)
            }
            return deferred
        }

        var actualTimeoutBlockEvent:FSMEvent? = nil
        var actualTimeoutBlockTransition:FSMTransition? = nil
        event1to2.eventDidTimeout = {(event,transition) -> Void in
            actualTimeoutBlockEvent = event
            actualTimeoutBlockTransition = transition
        }
        let promise = finiteStateMachine.fireEvent(event1to2, initialValue:nil)
        promise.then(
            { (value) -> AnyObject? in
                expectation.fulfill()
                XCTFail("Should have been rejected")
                return value
            }, reject: { (error) -> NSError in
                expectation.fulfill()
                XCTAssertEqual(kFSMErrorEventTimeout, error.code)
                return error
            }
        )

        // wait long enough for timeout to trigger
        waitForExpectationsWithTimeout(timeout*2.0, handler:nil)

        XCTAssertEqualOptional(event1to2, actualTimeoutBlockEvent)
        XCTAssertNotNil(actualTimeoutBlockTransition)
    }

    func testDelayWithoutTimeout() {
        let timeout:NSTimeInterval = 1.0
        event1to2.eventTimeout = timeout

        let expectation = expectationWithDescription("expectation")
        event1to2.willFireEvent = { (event, transition, value) -> AnyObject? in
            // Delay one of the steps for a bit, but shorter than the event timeout threshold
            let deferred = Promise()
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(timeout / 2.0 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                deferred.fulfill(value)
            }
            return deferred
        }

        let promise = finiteStateMachine.fireEvent(event1to2, initialValue:nil)
        promise.then(
            { (value) -> AnyObject? in
                expectation.fulfill()
                return value
            }, reject: { (error) -> NSError in
                expectation.fulfill()
                XCTFail("Should not have been rejected")
                return error
        })

        // wait long enough for timeout to trigger
        waitForExpectationsWithTimeout(timeout*2.0, handler:nil)
    }



}
