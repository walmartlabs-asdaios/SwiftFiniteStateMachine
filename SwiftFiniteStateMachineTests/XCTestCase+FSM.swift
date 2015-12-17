//
//  XCTestCase+FSM.swift
//  SwiftFiniteStateMachine
//
//  Created by Douglas Sjoquist on 2/26/15.
//  Copyright (c) 2015 Ivy Gulch LLC. All rights reserved.
//

import UIKit
import XCTest
@testable import SwiftFiniteStateMachine

extension XCTestCase {

    func delayedFulfilledPromise(delay:NSTimeInterval, value:AnyObject?) -> Promise<AnyObject> {
        // Delay one of the steps longer than the event timeout threshold
        let deferred:Promise<AnyObject> = Promise()
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            deferred.fulfill(value)
        }
        return deferred
    }

}
