//
//  FSMEventTests.swift
//  SwiftFiniteStateMachine
//
//  Created by Douglas Sjoquist on 2/26/15.
//  Copyright (c) 2015 Ivy Gulch LLC. All rights reserved.
//

import UIKit
import XCTest

class FSMEventTests: FSMTestCase {

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
        XCTAssertEqual("test", event.name);
        XCTAssertEqual([dummySourceState1,dummySourceState2], event.sources);
        XCTAssertEqual(dummyDestinationState, event.destination);
        XCTAssertEqual(dummyFiniteStateMachine, event.finiteStateMachine);
        XCTAssertEqual(kFSMDefaultEventTimeout, event.eventTimeout);
    }
    
}
