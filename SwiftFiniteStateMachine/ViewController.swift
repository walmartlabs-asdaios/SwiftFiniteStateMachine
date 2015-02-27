//
//  ViewController.swift
//  SwiftFiniteStateMachine
//
//  Created by Douglas Sjoquist on 2/26/15.
//  Copyright (c) 2015 Ivy Gulch LLC. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var demoFSM:DemoFSM!
    @IBOutlet var stateLabel:UILabel!
    @IBOutlet var usernameLabel:UILabel!
    @IBOutlet var userRecordLabel:UILabel!
    @IBOutlet var messageLabel:UILabel!
    @IBOutlet var loginButton:UIButton!
    @IBOutlet var logoutButton:UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        demoFSM = DemoFSM(rootViewController:self)
        stateLabel.text = demoFSM.finiteStateMachine.currentState?.name
        demoFSM.finiteStateMachine.didChangeState = {
            (oldState,newState) in
            self.stateLabel.text = newState?.name
        }
    }

    @IBAction func login() {
        messageLabel.text = "login started"
        usernameLabel.text = ""
        userRecordLabel.text = ""

        demoFSM.login().then(
            { (value:AnyObject?) -> AnyObject? in
                self.usernameLabel.text = value as? String
                self.messageLabel.text = "Logged in"
                dispatch_async(dispatch_get_main_queue(), {
                    self.loadRecord()
                })
                return value
            }, reject: { (error) -> NSError in
                self.messageLabel.text = "Could not login: \(error.localizedDescription)"
                return error
            }
        )
    }

    func loadRecord() {
        messageLabel.text = "load record started"

        demoFSM.loadRecord().then(
            { (value:AnyObject?) -> AnyObject? in
                self.userRecordLabel.text = value as? String
                self.messageLabel.text = "Record loaded"
                return value
            }, reject: { (error) -> NSError in
                self.messageLabel.text = "Could not load record: \(error.localizedDescription)"
                return error
            }
        )
    }

    @IBAction func logout() {
        messageLabel.text = "logout started"

        demoFSM.logout().then(
            { (value:AnyObject?) -> AnyObject? in
                self.usernameLabel.text = ""
                self.userRecordLabel.text = ""
                self.messageLabel.text = "Logged out"
                return value
            }, reject: { (error) -> NSError in
                self.messageLabel.text = "Could not logout: \(error.localizedDescription)"
                return error
            }
        )
    }

}

