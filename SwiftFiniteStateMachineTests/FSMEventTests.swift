//
//  FSMEventTests.swift
//  SwiftFiniteStateMachine
//
//  Created by Douglas Sjoquist on 2/26/15.
//  Copyright (c) 2015 Ivy Gulch LLC. All rights reserved.
//

import UIKit
import XCTest
@testable import SwiftFiniteStateMachine

class FSMEventTests: XCTestCase {

    var dummyFiniteStateMachine:FSMFiniteStateMachine!
    var dummySourceState1:FSMState!
    var dummySourceState2:FSMState!
    var dummyDestinationState:FSMState!
    var event:FSMEvent!

    override func setUp() {
        super.setUp()

        dummyFiniteStateMachine = FSMFiniteStateMachine()
        dummySourceState1 = FSMState("source1", finiteStateMachine:dummyFiniteStateMachine)
        dummySourceState2 = FSMState("source2", finiteStateMachine:dummyFiniteStateMachine)
        dummyDestinationState = FSMState("destination", finiteStateMachine:dummyFiniteStateMachine)

        event = FSMEvent("test", sources:[dummySourceState1,dummySourceState2], destination:dummyDestinationState, finiteStateMachine:dummyFiniteStateMachine)
    }

    func testCreation() {
        XCTAssertEqual("test", event.name)
        XCTAssertEqual([dummySourceState1,dummySourceState2], event.sources)
        XCTAssertEqual(dummyDestinationState, event.destination)
        XCTAssertEqual(dummyFiniteStateMachine, event.finiteStateMachine)
    }

    // MARK: - fireEvent tests

    func testWillFireEvent() {
        var actualEvent:FSMEvent?
        var actualTransition:FSMTransition?
        var actualValue:AnyObject?

        event.willFireEvent = {
            (event, transition, value) -> AnyObject? in
            actualEvent = event
            actualTransition = transition
            actualValue = value
            return value
        }

        let expectedTransition = FSMTransition(event,source:dummySourceState1,finiteStateMachine:dummyFiniteStateMachine)
        let expectedValue:AnyObject? = "expected value"

        let result = event.willFireEventWithTransition(expectedTransition, value:expectedValue)
        result.then(
            {
                value in
                XCTAssertEqual(self.event, actualEvent)
                XCTAssertEqual(expectedTransition, actualTransition)
                XCTAssertTrue(expectedValue === actualValue)
                return .Value(nil)
            }, reject: {
                error in
                XCTFail("should not fail")
                return .Error(error)
        })
    }

    func testDidFireEvent() {
        var actualEvent:FSMEvent?
        var actualTransition:FSMTransition?
        var actualValue:AnyObject?

        event.didFireEvent = {
            (event, transition, value) -> AnyObject? in
            actualEvent = event
            actualTransition = transition
            actualValue = value
            return value
        }

        let expectedTransition = FSMTransition(event,source:dummySourceState1,finiteStateMachine:dummyFiniteStateMachine)
        let expectedValue:AnyObject? = "expected value"

        let result = event.didFireEventWithTransition(expectedTransition, value:expectedValue)
        result.then(
            {
                value in
                XCTAssertEqual(self.event, actualEvent)
                XCTAssertEqual(expectedTransition, actualTransition)
                XCTAssertTrue(expectedValue === actualValue)
                return .Value(nil)
            }, reject: {
                error in
                XCTFail("should not fail")
                return .Error(error)
        })
    }
    
}
