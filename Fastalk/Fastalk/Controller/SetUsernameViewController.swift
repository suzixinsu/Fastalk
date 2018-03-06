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
    @IBOutlet weak var textFieldUsername: UITextField!
    var username: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func okClickedAction(_ sender: Any) {
        self.username = textFieldUsername.text!
        let userId = Auth.auth().currentUser?.uid
        let email = Auth.auth().currentUser?.email
        let userItem = [
            "userId": userId,
            "email": email
        ]
        self.usersRef.child(username!).setValue(userItem)
        
        Config.setUserId(userId!)
        Config.setUsername(username!)
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
