//
//  LoginViewController.swift
//  Fastalk
//
//  Created by Dan Xu on 2/26/18.
//  Copyright © 2018 IOSGroup7. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
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
    
    @IBAction func loginBtnClicked(_ sender: Any) {
        let email = textFieldEmail.text!
        let password = textFieldPassword.text!
        if (email == "" || password == "") {
            self.alertController = UIAlertController(title: "Empty Fields", message: "Please provide both email and password!", preferredStyle: UIAlertControllerStyle.alert)
            
            let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
            alertController!.addAction(OKAction)
            
            present(self.alertController!, animated: true, completion:nil)
        } else if (password.count < 6) {
            self.alertController = UIAlertController(title: "Password error", message: "Password should be at least 6 characters", preferredStyle: UIAlertControllerStyle.alert)
            
            let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
            alertController!.addAction(OKAction)
            
            present(self.alertController!, animated: true, completion:nil)
        }
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let err = error {
                //print("error: " + err.localizedDescription)
                self.alertController = UIAlertController(title: "Login error", message: "\(err.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
                
                let OKAction = UIAlertAction(title: "Try Again", style: UIAlertActionStyle.default)
                self.alertController!.addAction(OKAction)
                
                self.present(self.alertController!, animated: true, completion:nil)
                return
            }
            if let user = user {
                let uid = user.uid
                let email = user.email
                let photoURL = user.photoURL
                // ...
            }
            self.performSegue(withIdentifier: "LoginToChat", sender: nil)
        }
    }
    
     // MARK: - Navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        let navVc = segue.destination as! UINavigationController
        let channelVc = navVc.viewControllers.first as! ChannelListTableViewController
        
        channelVc.senderDisplayName = textFieldEmail?.text
     }
    
}
