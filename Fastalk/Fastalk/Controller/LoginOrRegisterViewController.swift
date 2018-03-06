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
    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    @IBOutlet weak var segControl: UISegmentedControl!
    @IBOutlet weak var labelEmail: UILabel!
    @IBOutlet weak var labelPassword: UILabel!
    
    var email: String?
    var password: String?

    var currentOption = 0
    var alertController:UIAlertController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textFieldPassword.isSecureTextEntry = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Private methods
    private func presentAlert(err: Error) {
        self.alertController = UIAlertController(title: "Error", message: "\(err.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)

        let OKAction = UIAlertAction(title: "Try Again", style: UIAlertActionStyle.default)
        self.alertController!.addAction(OKAction)

        self.present(self.alertController!, animated: true, completion:nil)
    }
    
    // MARK: - UI Actions
    @IBAction func segControlAction(_ sender: Any) {
        self.currentOption = self.segControl.selectedSegmentIndex
    }
    
    @IBAction func goButtonClicked(_ sender: Any) {
        self.email = textFieldEmail.text!
        self.password = textFieldPassword.text!
        // TODO: - fix log in
        if (email!.isEmpty) {
            labelEmail.text = "Please provide an email"
            return
        } else if (password!.isEmpty) {
            labelPassword.text = "Please provide a password"
            return
        } else if (password!.count < 6) {
            labelPassword.text = "Password should contain at least 6 characters"
            return
        }
        
        if (currentOption == 0) {
            Auth.auth().signIn(withEmail: email!, password: password!) { (user, error) in
                if let err = error {
                    self.presentAlert(err: err)
                    return
                }
                self.performSegue(withIdentifier: "LoginOrRegisterToChat", sender: nil)
            }
        } else {
            Auth.auth().createUser(withEmail: email!, password: password!) { (user, error) in
                if let err = error {
                    self.presentAlert(err: err)
                    return
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
    }
    
}
