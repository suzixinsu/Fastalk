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
        chatsRef = usersRef.child(Config.username()).child("chats")
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
    
    // MARK: - UI Actions
    //TODO: - navigate to contacts
    @IBAction func newChatClickedAction(_ sender: Any) {
        //TODO: navigate to contacts
        self.alertController = UIAlertController(title: "New Chat", message: "Please provide the username", preferredStyle: UIAlertControllerStyle.alert)
        
        let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            let newChatsRef = self.chatsRef!.childByAutoId()
            //TODO: - change date to last message
            let date = self.getDate()
            let friendname = self.usernameTextField!.text!
            let chatItem = [
                "title": friendname,
                "timeStamp": date
            ]
            newChatsRef.setValue(chatItem)
            let chatId = newChatsRef.key
            
            self.usersRef.queryOrderedByKey().queryEqual(toValue: friendname).observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() {
                    let friendRef = self.usersRef.child(friendname)
                    let friendChatsRef = friendRef.child("chats").child(chatId)
                    let date = self.getDate()
                    let chatItem = [
                        "title": Config.username(),
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
