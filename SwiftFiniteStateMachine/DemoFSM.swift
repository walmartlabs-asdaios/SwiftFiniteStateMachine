//
//  DemoFSM.swift
//  SwiftFiniteStateMachine
//
//  Created by Douglas Sjoquist on 2/27/15.
//  Copyright (c) 2015 Ivy Gulch LLC. All rights reserved.
//

import UIKit

class DemoFSM {
    let rootViewController:UIViewController

    var username:String? = nil
    var userRecord:String? = nil

    var finiteStateMachine:FSMFiniteStateMachine!
    var signedOutState:FSMState!
    var authenticatedState:FSMState!
    var signedInState:FSMState!
    var authenticateEvent:FSMEvent!
    var loadRecordEvent:FSMEvent!
    var signOutEvent:FSMEvent!

    init(rootViewController:UIViewController) {
        self.rootViewController = rootViewController
        configureFiniteStateMachine()
    }

    func configureFiniteStateMachine() {
        finiteStateMachine = FSMFiniteStateMachine()

        signedOutState = finiteStateMachine.addState("signedOut", error:nil)
        signedOutState.didEnterState = {
            (state:FSMState, transition:FSMTransition, value:AnyObject?) -> AnyObject? in
            self.username = nil
            self.userRecord = nil
            return value
        }
        authenticatedState = finiteStateMachine.addState("authenticated", error:nil)
        authenticatedState.didEnterState = {
            (state:FSMState, transition:FSMTransition, value:AnyObject?) -> AnyObject? in
            self.username = value as? String
            return value
        }
        signedInState = finiteStateMachine.addState("signedIn", error:nil)
        signedInState.didEnterState = {
            (state:FSMState, transition:FSMTransition, value:AnyObject?) -> AnyObject? in
            self.userRecord = value as? String
            return value
        }

        authenticateEvent = finiteStateMachine.addEvent("authenticate", sources:[signedOutState], destination:authenticatedState, error:nil)
        authenticateEvent.willFireEvent = {
            (event:FSMEvent, transition:FSMTransition, value:AnyObject?) -> AnyObject? in
            return self.dummyAuthenticationPromise()
        }

        loadRecordEvent = finiteStateMachine.addEvent("loadRecord", sources:[authenticatedState], destination:signedInState, error:nil)
        loadRecordEvent.willFireEvent = {
            (event:FSMEvent, transition:FSMTransition, value:AnyObject?) -> AnyObject? in
            return self.dummySignInPromise()
        }

        signOutEvent = finiteStateMachine.addEvent("signOut", sources:[authenticatedState,signedInState], destination:signedOutState, error:nil)
        signOutEvent.willFireEvent = {
            (event:FSMEvent, transition:FSMTransition, value:AnyObject?) -> AnyObject? in
            return self.dummySignOutPromise()
        }

        finiteStateMachine.setInitialState(signedOutState, error:nil)
    }

    func dummyAuthenticationPromise() -> Promise {
        let result = Promise()
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

    func dummySignInPromise() -> Promise {
        let result = Promise()
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
    
    func dummySignOutPromise() -> Promise {
        let result = Promise()
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
    
    func login() -> Promise {
        return finiteStateMachine.fireEvent(authenticateEvent, initialValue:nil)
    }

    func loadRecord() -> Promise {
        return finiteStateMachine.fireEvent(loadRecordEvent, initialValue:nil)
    }

    func logout() -> Promise {
        return finiteStateMachine.fireEvent(signOutEvent, initialValue:nil)
    }

}