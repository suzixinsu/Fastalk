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
    @IBOutlet weak var textFieldName: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginBtnClicked(_ sender: Any) {
        if textFieldName?.text != "" {
            Auth.auth().signInAnonymously(completion: { (user, error) in
                if let err = error {
                    print(err.localizedDescription)
                    return
                }
                self.performSegue(withIdentifier: "LoginToChat", sender: nil)
            })
        }
    }
    
     // MARK: - Navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        let navVc = segue.destination as! UINavigationController
        let channelVc = navVc.viewControllers.first as! ChannelListTableViewController
        
        channelVc.senderDisplayName = textFieldName?.text
     }
    
}
