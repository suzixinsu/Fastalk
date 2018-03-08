//
//  SetUsernameViewController.swift
//  Fastalk
//
//  Created by Dan Xu on 3/4/18.
//  Copyright © 2018 IOSGroup7. All rights reserved.
//

import UIKit
import Firebase

class SetUsernameViewController: UIViewController {
    private var usersRef = Constants.refs.databaseUsers
    var alertController:UIAlertController? = nil
    var usernameTextField: UITextField?
    var actionToEnable: UIAlertAction?
    
    @IBOutlet weak var labelUsername: UILabel!
    @IBOutlet weak var labelSignOut: UILabel!
    @IBOutlet weak var labelEmail: UILabel!
    
    var username: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        labelEmail.text = Config.email()
        self.title = "My Profile"
        //TODO: - Dinamically show username
        //labelUsername.text = Config.username()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Private Methods
    private func presentAlert() {
        self.alertController = UIAlertController(title: "Change Username", message: "", preferredStyle: UIAlertControllerStyle.alert)
        self.alertController!.addTextField { (textField) -> Void in
            self.usernameTextField = textField
            self.usernameTextField?.placeholder = "Enter the username"
        }
        let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            //change label
            self.username = self.usernameTextField!.text
            self.labelUsername.text = self.username
            self.updateUserInfo()
        })
        
        OKAction.isEnabled = false
        actionToEnable = OKAction
        self.alertController!.addAction(OKAction)
        self.present(self.alertController!, animated: true, completion:nil)
        
        self.usernameTextField!.addTarget(self, action: #selector(checkIfUsrExists), for: .editingChanged)
    }
    
    private func updateUserInfo() {
        let userId = Auth.auth().currentUser?.uid
        let email = Auth.auth().currentUser?.email
        let userItem = [
            "userId": userId,
            "email": email
        ]
        self.usersRef.child(username!).setValue(userItem)
        
        Config.setUsername(username!)
    }
    
    @objc func checkIfUsrExists() {
        self.alertController?.message = "Checking..."
        let username = usernameTextField!.text
        guard !(username?.isEmpty)! else {
            return
        }
        self.usersRef.queryOrderedByKey().queryEqual(toValue: username).observeSingleEvent(of: .value, with: { (snapshot) in
            if (snapshot.exists()) {
                self.alertController?.message = "User already exists"
                self.actionToEnable!.isEnabled = false
            } else {
                self.alertController?.message = "Nice Name"
                self.actionToEnable!.isEnabled = true
            }
        })
    }
    
    // MARK: - UI Actions
    @IBAction func changeClickedAction(_ sender: Any) {
        presentAlert()
    }
    
    @IBAction func signOutClickedAction(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            labelSignOut.text = signOutError.localizedDescription
        }
        self.performSegue(withIdentifier: "LoginOutToLogIn", sender: self)
    }
    
    /*
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
