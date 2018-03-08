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
    var userAlreadyExist = false
    
    @IBOutlet weak var labelUsername: UILabel!
    @IBOutlet weak var labelEmail: UILabel!
    @IBOutlet weak var buttonSet: UIButton!
    
    var username: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        labelEmail.text = Config.email()
        self.title = "Complete Profile"
        checkUsername()
    }
    
    // TODO: - Require username

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Private Methods
    private func checkUsername() {
        let userId = Auth.auth().currentUser?.uid
        self.usersRef.queryOrdered(byChild: "userId").queryEqual(toValue: userId).observeSingleEvent(of: .value, with: { (snapshot) in
            if (snapshot.exists()) {
                self.userAlreadyExist = true
                
                let value = snapshot.value as? NSDictionary
                for (k, _) in value! {
                    self.labelUsername.text = (k as! String)
                }
                self.buttonSet.isHidden = true
            }
        })
    }
    
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
        
        self.usernameTextField!.addTarget(self, action: #selector(checkIfUserExists), for: .editingChanged)
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
    
    @objc func checkIfUserExists() {
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
    @IBAction func setClickedAction(_ sender: Any) {
        presentAlert()
    }
    
    /*
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
