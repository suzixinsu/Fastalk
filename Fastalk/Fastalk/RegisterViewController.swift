//
//  RegisterViewController.swift
//  Fastalk
//
//  Created by Dan Xu on 2/28/18.
//  Copyright © 2018 IOSGroup7. All rights reserved.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {
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
    
    @IBAction func buttonRegisterClicked(_ sender: Any) {
        let email = textFieldEmail.text!
        let password = textFieldPassword.text!
        // Firebase default: Password should be at least 6 characters
        // Firebase default: Email???
        if (email == "" || password == "") {
            // TODO: - consider not using alert
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
        
        // TODO: - add email format check here
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let err = error {
                //print("error: " + err.localizedDescription)
                self.alertController = UIAlertController(title: "Register error", message: "\(err.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
                
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
            self.performSegue(withIdentifier: "RegisterToChat", sender: nil)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
