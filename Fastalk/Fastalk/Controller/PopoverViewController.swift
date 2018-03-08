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
    private var chatsRef = Constants.refs.databaseChats
    private var userChatsRef: DatabaseReference?
    private var friendChatsRef: DatabaseReference?
    var username: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        getUsername()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Private Methods
    private func getDate() -> String{
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm MM/dd/yy"
        let convertedDate = dateFormatter.string(from: currentDate)
        return convertedDate
    }
    
    @objc private func checkIfUsrExists() {
        let username = usernameTextField!.text
        self.usersRef.queryOrderedByKey().queryEqual(toValue: username).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                self.actionToEnable!.isEnabled = true
                self.alertController?.message = "User Found"
            } else {
                self.alertController?.message = "User does not exist"
            }
        })
    }
    
    private func addNewContact() {
        
    }
    
    private func getUsername() {
        let userId = Auth.auth().currentUser?.uid
        self.usersRef.queryOrdered(byChild: "userId").queryEqual(toValue: userId).observeSingleEvent(of: .value, with: { (snapshot) in
            if (snapshot.exists()) {
                let value = snapshot.value as? NSDictionary
                for (k, _) in value! {
                    let username = (k as! String)
                    self.username = username
                    self.userChatsRef = self.chatsRef.child(username)
                }
            }
        })
    }
    
    // MARK: - UI Actions
    //TODO: - navigate to contacts
    @IBAction func newChatClickedAction(_ sender: Any) {
        //TODO: navigate to contacts
        self.alertController = UIAlertController(title: "New Chat", message: "Please provide the username", preferredStyle: UIAlertControllerStyle.alert)
        
        let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            let newUserChatsRef = self.userChatsRef!.childByAutoId()
            //TODO: - change date to last message
            let date = self.getDate()
            let friendname = self.usernameTextField!.text!
            let chatItem = [
                "title": friendname,
                "timeStamp": date
            ]
            newUserChatsRef.setValue(chatItem)
            let chatId = newUserChatsRef.key
            
            self.usersRef.queryOrderedByKey().queryEqual(toValue: friendname).observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() {
                    let friendChatsRef = self.chatsRef.child(friendname).child(chatId)
                    let date = self.getDate()
                    let chatItem = [
                        "title": self.username,
                        "timeStamp": date
                    ]
                    friendChatsRef.setValue(chatItem)
                } else {
                    
                }
            })
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
        
        self.usernameTextField!.addTarget(self, action: #selector(checkIfUsrExists), for: .editingChanged)
    }
    
    // TODO: - Dismiss Popover after click

    /*
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
