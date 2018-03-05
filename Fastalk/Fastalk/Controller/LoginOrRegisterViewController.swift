//
//  LoginOrRegisterViewController.swift
//  Fastalk
//
//  Created by Dan Xu on 3/3/18.
//  Copyright © 2018 IOSGroup7. All rights reserved.
//

import UIKit
import Firebase

class LoginOrRegisterViewController: UIViewController {
    @IBOutlet weak var textFieldUsername: UITextField!
    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    @IBOutlet weak var segControl: UISegmentedControl!
    
    private var usersRef = Constants.refs.databaseUsers
    private var usersRefHandle: DatabaseHandle?
    
    var username: String?
    var email: String?
    var password: String?

    var currentOption = 0
    var alertController:UIAlertController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textFieldPassword.isSecureTextEntry = true
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func segControlAction(_ sender: Any) {
        self.currentOption = self.segControl.selectedSegmentIndex
    }
    
    @IBAction func goButtonClicked(_ sender: Any) {
        self.email = textFieldEmail.text!
        self.password = textFieldPassword.text!
        self.username = textFieldUsername.text!
        if (email == "" || password == "") {
            self.alertController = UIAlertController(title: "Empty Fields", message: "Please provide both email and password!", preferredStyle: UIAlertControllerStyle.alert)
            
            let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
            alertController!.addAction(OKAction)
            
            present(self.alertController!, animated: true, completion:nil)
        } else if (password!.count < 6) {
            self.alertController = UIAlertController(title: "Password error", message: "Password should be at least 6 characters", preferredStyle: UIAlertControllerStyle.alert)
            
            let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
            alertController!.addAction(OKAction)
            
            present(self.alertController!, animated: true, completion:nil)
        }
        if (currentOption == 0) {
            Auth.auth().signIn(withEmail: email!, password: password!) { (user, error) in
                if let err = error {
                    //print("error: " + err.localizedDescription)
                    self.alertController = UIAlertController(title: "Login error", message: "\(err.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
                    
                    let OKAction = UIAlertAction(title: "Try Again", style: UIAlertActionStyle.default)
                    self.alertController!.addAction(OKAction)
                    
                    self.present(self.alertController!, animated: true, completion:nil)
                    return
                }
                // TODO: - change to set username after register
                if let user = user {
                    let username = [
                        "username": self.textFieldUsername.text
                    ]
                    self.usersRef.child(user.uid).setValue(username)
                }
                self.performSegue(withIdentifier: "LoginOrRegisterToChat", sender: nil)
            }
        } else {
            Auth.auth().createUser(withEmail: email!, password: password!) { (user, error) in
                if let err = error {
                    //print("error: " + err.localizedDescription)
                    self.alertController = UIAlertController(title: "Register error", message: "\(err.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
                    
                    let OKAction = UIAlertAction(title: "Try Again", style: UIAlertActionStyle.default)
                    self.alertController!.addAction(OKAction)
                    
                    self.present(self.alertController!, animated: true, completion:nil)
                    return
                }
                // TODO: - change to set username after register
                if let user = user {
                    let username = [
                        "username": self.textFieldUsername.text
                    ]
                    self.usersRef.child(user.uid).setValue(username)
                }
                self.performSegue(withIdentifier: "LoginOrRegisterToChat", sender: nil)
            }
        }
        // TODO: - add email format check here
        // TODO: - add a logout somewhere
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let tabVc = segue.destination as! MyTabBarController
        if (currentOption != 0) {
            tabVc.freshLaunch = true
        }
//        let navVc = tabVc.viewControllers!.first as! UINavigationController
//        let chatListVc = navVc.viewControllers.first as! ChatsListTableViewController
//        chatListVc.senderDisplayName = username
    }
    
}
