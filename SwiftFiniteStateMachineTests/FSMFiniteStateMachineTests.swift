//
//  FSMFiniteStateMachineTests.swift
//  SwiftFiniteStateMachine
//
//  Created by Douglas Sjoquist on 2/26/15.
//  Copyright (c) 2015 Ivy Gulch LLC. All rights reserved.
//

import UIKit
import XCTest

class FSMFiniteStateMachineTests: FSMTestCase {

// MARK: state tests

    func testStateNamesMustBeUnique() {
        let finiteStateMachine = FSMFiniteStateMachine()

        var error:NSError? = nil
        let result1 = finiteStateMachine.addState("state", error:&error)
        XCTAssertEqualOptional("state", result1?.name);
        XCTAssertNil(error);

        let result2 = finiteStateMachine.addState("state", error:&error)
        XCTAssertNil(result2);
        XCTAssertNotNil(error);

    }

}
