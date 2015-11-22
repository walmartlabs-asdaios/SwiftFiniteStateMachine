//
//  DemoFSM.swift
//  SwiftFiniteStateMachine
//
//  Created by Douglas Sjoquist on 2/27/15.
//  Copyright (c) 2015 Ivy Gulch LLC. All rights reserved.
//

import UIKit
import SwiftFiniteStateMachine

class DemoFSM {
    let rootViewController:UIViewController

    var username:String?
    var userRecord:String?

    var finiteStateMachine:FSMFiniteStateMachine!
    var signedOutState:FSMState!
    var authenticatedState:FSMState!
    var signedInState:FSMState!
    var authenticateEvent:FSMEvent!
    var loadRecordEvent:FSMEvent!
    var signOutEvent:FSMEvent!

    let defaultEventTimeout:NSTimeInterval = 10.0

    init(rootViewController:UIViewController) {
        self.rootViewController = rootViewController
        configureFiniteStateMachine()
    }

    func configureFiniteStateMachine() {
        finiteStateMachine = FSMFiniteStateMachine()

        do {
            signedOutState = try finiteStateMachine.addState("signedOut")
            signedOutState.didEnterState = {
                (state:FSMState, transition:FSMTransition, value:AnyObject?) -> AnyObject? in
                self.username = nil
                self.userRecord = nil
                return value
            }
            authenticatedState = try finiteStateMachine.addState("authenticated")
            authenticatedState.didEnterState = {
                (state:FSMState, transition:FSMTransition, value:AnyObject?) -> AnyObject? in
                self.username = value as? String
                return value
            }
            signedInState = try finiteStateMachine.addState("signedIn")
            signedInState.didEnterState = {
                (state:FSMState, transition:FSMTransition, value:AnyObject?) -> AnyObject? in
                self.userRecord = value as? String
                return value
            }

            authenticateEvent = try finiteStateMachine.addEvent("authenticate", sources:[signedOutState], destination:authenticatedState)
            authenticateEvent.willFireEvent = {
                (event:FSMEvent, transition:FSMTransition, value:AnyObject?) -> AnyObject? in
                return self.dummyAuthenticationPromise()
            }

            loadRecordEvent = try finiteStateMachine.addEvent("loadRecord", sources:[authenticatedState], destination:signedInState)
            loadRecordEvent.willFireEvent = {
                (event:FSMEvent, transition:FSMTransition, value:AnyObject?) -> AnyObject? in
                return self.dummySignInPromise()
            }

            signOutEvent = try finiteStateMachine.addEvent("signOut", sources:[authenticatedState,signedInState], destination:signedOutState)
            signOutEvent.willFireEvent = {
                (event:FSMEvent, transition:FSMTransition, value:AnyObject?) -> AnyObject? in
                return self.dummySignOutPromise()
            }

            try finiteStateMachine.setInitialState(signedOutState)
        }
        catch let error {
            print("DBG: error configuring states: \(error)")
        }
    }

    func dummyAuthenticationPromise() -> Promise<AnyObject> {
        let result:Promise<AnyObject> = Promise()
        let alertController = UIAlertController(title: "Dummy Authentication", message: "Tap fail or enter a username and tap authenticate", preferredStyle: .Alert)
        var usernameTextField:UITextField!
        alertController.addTextFieldWithConfigurationHandler { (textField:UITextField!) -> Void in
            usernameTextField = textField
            usernameTextField.placeholder = "Username"
        }

        alertController.addAction(UIAlertAction(title: "Fail", style: .Cancel) { (action) in
            result.reject(NSError(domain:"Dummy Authentication Fail", code: 0, userInfo: nil))
            })

        alertController.addAction(UIAlertAction(title: "Authenticate", style: .Default) { (action) in
            result.fulfill(usernameTextField.text)
            })

        rootViewController.presentViewController(alertController, animated: true) {
        }
        return result
    }

    func dummySignInPromise() -> Promise<AnyObject> {
        let result:Promise<AnyObject> = Promise()
        let alertController = UIAlertController(title: "Dummy Load Record", message: "Tap fail or enter userRecord and tap load record", preferredStyle: .Alert)
        var userRecordTextField:UITextField!
        alertController.addTextFieldWithConfigurationHandler { (textField:UITextField!) -> Void in
            userRecordTextField = textField
            userRecordTextField.placeholder = "User record"
        }

        alertController.addAction(UIAlertAction(title: "Fail", style: .Cancel) { (action) in
            result.reject(NSError(domain:"Dummy Load Record Fail", code: 0, userInfo: nil))
            })

        alertController.addAction(UIAlertAction(title: "Load Record", style: .Default) { (action) in
            result.fulfill(userRecordTextField.text)
            })

        rootViewController.presentViewController(alertController, animated: true) {
        }
        return result
    }

    func dummySignOutPromise() -> Promise<AnyObject> {
        let result:Promise<AnyObject> = Promise()
        let alertController = UIAlertController(title: "Dummy Logout", message: "Tap fail or logout", preferredStyle: .Alert)

        alertController.addAction(UIAlertAction(title: "Fail", style: .Cancel) { (action) in
            result.reject(NSError(domain:"Dummy Logout Fail", code: 0, userInfo: nil))
            })

        alertController.addAction(UIAlertAction(title: "Logout", style: .Default) { (action) in
            result.fulfill(nil)
            })

        rootViewController.presentViewController(alertController, animated: true) {
        }
        return result
    }

    func login() -> Promise<AnyObject> {
        return finiteStateMachine.fireEvent(authenticateEvent, eventTimeout:defaultEventTimeout, initialValue:nil)
    }

    func loadRecord() -> Promise<AnyObject> {
        return finiteStateMachine.fireEvent(loadRecordEvent, eventTimeout:defaultEventTimeout, initialValue:nil)
    }
    
    func logout() -> Promise<AnyObject> {
        return finiteStateMachine.fireEvent(signOutEvent, eventTimeout:defaultEventTimeout, initialValue:nil)
    }
    
}