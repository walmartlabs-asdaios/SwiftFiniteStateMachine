//
//  FSMTestCase.swift
//  SwiftFiniteStateMachine
//
//  Created by Douglas Sjoquist on 2/26/15.
//  Copyright (c) 2015 Ivy Gulch LLC. All rights reserved.
//

import UIKit
import XCTest

/// like XCTAssertEqual, but handles optional unwrapping
func XCTAssertEqualOptional<T:Equatable>(@autoclosure expression1:  () -> T?, @autoclosure expression2:  () -> T?, _ message: String? = nil, file: String = __FILE__, line: UInt = __LINE__) {
    if let exp1 = expression1() {
        if let exp2 = expression2() {
            XCTAssertEqual(exp1, exp2, (message != nil) ? message! : "", file: file, line: line)
        } else {
            XCTFail((message != nil) ? message! : "exp1 != nil, exp2 == nil", file: file, line: line)
        }
    } else if let exp2 = expression2() {
        XCTFail((message != nil) ? message! : "exp1 == nil, exp2 != nil", file: file, line: line)
    }
}

class FSMTestCase: XCTestCase {

    func delayedFulfilledPromise(delay:NSTimeInterval, value:AnyObject?) -> Promise {
        // Delay one of the steps longer than the event timeout threshold
        let deferred = Promise()
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            deferred.fulfill(value)
        }
        return deferred
    }

}
