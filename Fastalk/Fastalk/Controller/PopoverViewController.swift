//
//  PopoverViewController.swift
//  Fastalk
//
//  Created by Dan Xu on 3/5/18.
//  Copyright © 2018 IOSGroup7. All rights reserved.
//

import UIKit
import Firebase

class PopoverViewController: UIViewController {
    var alertController:UIAlertController?
    var usernameTextField: UITextField?
    var actionToEnable: UIAlertAction?
    private var chatsRefHandle: DatabaseHandle?
    private var usersRef = Constants.refs.databaseUsers
    private var chatsRef: DatabaseReference?

    override func viewDidLoad() {
        super.viewDidLoad()
        chatsRef = usersRef.child(Config.userId()).child("chats")
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func newChatClickedAction(_ sender: Any) {
        //TODO: navigate to contacts
        self.alertController = UIAlertController(title: "New Chat", message: "Please provide the username", preferredStyle: UIAlertControllerStyle.alert)
        
        let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            let newChatsRef = self.chatsRef!.childByAutoId()
            let date = self.getDate()
            let username = self.usernameTextField!.text as! String
            let chatItem = [
                "title": username,
                "timeStamp": date
            ]
            newChatsRef.setValue(chatItem)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel)
        
        alertController!.addAction(OKAction)
        alertController!.addAction(cancelAction)
        
        self.alertController!.addTextField { (textField) -> Void in
            self.usernameTextField = textField
            self.usernameTextField?.placeholder = "Enter the username"
        }
        present(self.alertController!, animated: true, completion:nil)
    }
    
    private func getDate() -> String{
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm MM/dd/yy"
        let convertedDate = dateFormatter.string(from: currentDate)
        return convertedDate
    }
    
    @IBAction func addContactClickedAction(_ sender: Any) {
        self.alertController = UIAlertController(title: "Add Contact", message: "Please provide the username", preferredStyle: UIAlertControllerStyle.alert)
        
        let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            //add user to contacts
            self.addNewContact()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel)
        
        alertController!.addAction(OKAction)
        alertController!.addAction(cancelAction)
        
        self.alertController!.addTextField { (textField) -> Void in
            self.usernameTextField = textField
            self.usernameTextField?.placeholder = "Enter the username"
        }
        OKAction.isEnabled = false
        actionToEnable = OKAction
        present(self.alertController!, animated: true, completion:nil)
        
        self.usernameTextField!.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        if let username = textField.text {
            self.usersRef.queryOrdered(byChild: "username").queryEqual(toValue: username).observeSingleEvent(of: .value, with: { (snapshot) in
                print(snapshot.exists())
                if snapshot.exists() {
                    self.actionToEnable!.isEnabled = true
                    self.alertController?.message = "User Found"
                } else {
                    self.alertController?.message = "User does not exist"
                }
            })
        }
    }
    
    private func addNewContact() {
        
    }

    /*
    self.alertController = UIAlertController(title: "Start Chat", message: "Please provide the email", preferredStyle: UIAlertControllerStyle.alert)
    
    let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) -> Void in
        if let email = self.emailTextField?.text {
            let newChatsRef = self.chatsRef.childByAutoId()
            let date = self.getDate()
            let chatItem = [
                "title": email,
                "timeStamp": date
            ]
            newChatsRef.setValue(chatItem)
        }
    })
    
    alertController!.addAction(OKAction)
    
    self.alertController!.addTextField { (textField) -> Void in
    self.emailTextField = textField
    self.emailTextField?.placeholder = "Enter the email"
    }
    present(self.alertController!, animated: true, completion:nil)
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
