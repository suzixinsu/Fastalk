//
//  SettingsViewController.swift
//  Fastalk
//
//  Created by Dan Xu on 3/8/18.
//  Copyright © 2018 IOSGroup7. All rights reserved.
//

import UIKit
import Firebase

class SettingsViewController: UIViewController {
    private var usersRef = Constants.refs.databaseUsers
    var username: String?
    let userId = Auth.auth().currentUser?.uid
    var colorId: Int?
    
    @IBOutlet weak var labelSignOutError: UILabel!
    @IBOutlet weak var labelUsername: UILabel!
    @IBOutlet weak var labelEmail: UILabel!
    @IBOutlet weak var fontSize: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Settings"
        getAndSetUsername()
        self.labelEmail.text = Auth.auth().currentUser?.email
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func getAndSetUsername() {
        self.usersRef.queryOrderedByKey().queryEqual(toValue: userId).observeSingleEvent(of: .value, with: { (snapshot) in
            if (snapshot.exists()) {
                let user = snapshot.value as! NSDictionary
                let value = user[self.userId!] as! NSDictionary
                let username = value["username"] as! String
                self.username = username
                self.labelUsername.text = username
            }
        })
    }
    
    @IBAction func buttonLogOutClickedAction(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            labelSignOutError.text = signOutError.localizedDescription
        }
        self.performSegue(withIdentifier: "LogOutToLogIn", sender: self)
    }
    
    @IBAction func changeColor(_ sender: Any) {
        self.navigationController?.navigationBar.barTintColor = UIColor.yellow
        self.view.backgroundColor = UIColor.lightGray
    }
    
    
    @IBAction func fontAdd(_ sender: Any) {
        if let k = self.fontSize?.text{
            self.fontSize.text = String(Int(k)!+1)
            global.font = Int(k)!
        }
    }
    
    @IBAction func fontMinus(_ sender: Any) {
        if let k = self.fontSize?.text{
            self.fontSize.text = String(Int(k)!-1)
            global.font = Int(k)!
        }
    }
    
    struct global{
        static var font = Int()
        }
}
    
     // MARK: - Navigation
/*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
