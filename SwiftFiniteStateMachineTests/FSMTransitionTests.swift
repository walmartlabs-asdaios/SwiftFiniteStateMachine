//
//  FSMTransitionTests.swift
//  SwiftFiniteStateMachine
//
//  Created by Douglas Sjoquist on 2/26/15.
//  Copyright (c) 2015 Ivy Gulch LLC. All rights reserved.
//

import UIKit
import XCTest

class FSMTransitionTests: FSMTestCase {

    let dummyFiniteStateMachine = FSMFiniteStateMachine()

    func testCreation() {
        let sourceState = FSMState("source", finiteStateMachine:dummyFiniteStateMachine)
        let destinationState = FSMState("destination", finiteStateMachine:dummyFiniteStateMachine)
//        let event = FSMEvent("event", sources:[sourceState], destination:destinationState, finiteStateMachine:dummyFiniteStateMachine)
//
//        let transition = FSMTransition(event, source:sourceStatee, 
//        ASDAFSMTransition *transition = [[ASDAFSMTransition alloc] initWithFiniteStateMachine:self.dummyFiniteStateMachine
//        event:event
//        sourceState:sourceState];
//        XCTAssertEqualObjects(self.dummyFiniteStateMachine, transition.finiteStateMachine);
//        XCTAssertEqualObjects(event, transition.event);
//        XCTAssertEqualObjects(sourceState, transition.sourceState);
//        XCTAssertEqualObjects(destinationState, transition.destinationState);
//
//        XCTAssertEqual("test", state.name)
//        XCTAssertEqual(dummyFiniteStateMachine, state.finiteStateMachine)
    }

}
