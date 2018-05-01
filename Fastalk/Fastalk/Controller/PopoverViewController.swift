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
    var groupNameTextField: UITextField?
    var actionToEnable: UIAlertAction?
    private var groupsRefHandle: DatabaseHandle?
    private var groupsRef = Constants.refs.databaseGroups
    private var chatsRef = Constants.refs.databaseChats
    private var userChatsRef: DatabaseReference?
    var username: String?
    var joinGroupId: String?
    let userId = Auth.auth().currentUser!.uid
    
    //XIN: add action: commentes to be deletedd
    var usernameTextField: UITextField?
    var contactUsername: String?
    var contactUserId: String?
    private var userContactsRef: DatabaseReference?
    private var friendContactsRef: DatabaseReference?
    private var userContactsRefHandle: DatabaseHandle?
    private var usersRef = Constants.refs.databaseUsers
    private var contactsRef = Constants.refs.databaseContacts
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userChatsRef = chatsRef.child(userId)
        self.userContactsRef = self.contactsRef.child(userId)
        self.friendContactsRef = self.contactsRef
        getUsername()
    }
    
    deinit {
        if let refHandle = userContactsRefHandle {
            self.userContactsRef!.removeObserver(withHandle: refHandle)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func newGroupButtonClicked(_ sender: Any) {
        //self.dismiss(animated: true, completion: nil)
        self.alertController = UIAlertController(title: "New Group", message: "Please provide the group name", preferredStyle: UIAlertControllerStyle.alert)
        
        self.alertController!.addTextField { (textField) -> Void in
            self.groupNameTextField = textField
            self.groupNameTextField?.placeholder = "Enter the group name"
            
        }
        
        let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            let groupName = self.groupNameTextField!.text!
            let groupItem = [
                "groupName" : groupName,
                "ownerId": self.userId,
                "lastMessage": "",
                "timeStamp": "",
                "hasNewMessage": false
                ] as [String : Any]
            
            let currentGroupRef = self.groupsRef.childByAutoId()
            currentGroupRef.setValue(groupItem)
            let currentGroupId = currentGroupRef.key
            
            let groupChatItem = [
                "receiverId": "group",
                "receiverName" : groupName,
                "lastMessage": "",
                "timeStamp": "",
                "hasNewMessage": false
                ] as [String : Any]
            self.userChatsRef!.child(currentGroupId).setValue(groupChatItem)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel)
        self.alertController!.addAction(OKAction)
        self.alertController!.addAction(cancelAction)
        OKAction.isEnabled = false
        actionToEnable = OKAction
        present(self.alertController!, animated: true, completion:nil)

        self.groupNameTextField!.addTarget(self, action: #selector(checkIfNameExists), for: .editingChanged)
        
    }
    
    @IBAction func groupChatButtonClicked(_ sender: Any) {
        self.alertController = UIAlertController(title: "Join Group Chat", message: "Please provide the group name", preferredStyle: UIAlertControllerStyle.alert)
        
        self.alertController!.addTextField { (textField) -> Void in
            self.groupNameTextField = textField
            self.groupNameTextField?.placeholder = "Enter the group name"
        }
        
        let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            let groupName = self.groupNameTextField!.text!
            let groupChatItem = [
                "receiverId": "group",
                "receiverName" : groupName,
                "lastMessage": "",
                "timeStamp": "",
                "hasNewMessage": false
                ] as [String : Any]
            self.userChatsRef!.child(self.joinGroupId!).setValue(groupChatItem)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel)
        self.alertController!.addAction(OKAction)
        self.alertController!.addAction(cancelAction)
        OKAction.isEnabled = false
        actionToEnable = OKAction
        present(self.alertController!, animated: true, completion:nil)
        
        self.groupNameTextField!.addTarget(self, action: #selector(checkIfGroupExists), for: .editingChanged)
       // self.dismiss(animated: true, completion: nil)
    }

    @objc func checkIfGroupExists() {
        self.alertController?.message = "Checking..."
        let groupName = groupNameTextField!.text
        guard !(groupName?.isEmpty)! else {
            return
        }
        self.groupsRef.queryOrdered(byChild: "groupName").queryEqual(toValue: groupName).observeSingleEvent(of: .value, with: { (snapshot) in
            if (snapshot.exists()) {
                let groupData = snapshot.value as! NSDictionary
                self.joinGroupId = groupData.allKeys[0] as? String
                self.alertController?.message = "Ready to join the group?"
                self.actionToEnable!.isEnabled = true
            } else {
                self.alertController?.message = "Sorry, group not existed."
                self.actionToEnable!.isEnabled = false
            }
        })
    }
    
    @objc func checkIfNameExists() {
        self.alertController?.message = "Checking..."
        let groupName = groupNameTextField!.text
        guard !(groupName?.isEmpty)! else {
            return
        }
        self.groupsRef.queryOrdered(byChild: "groupName").queryEqual(toValue: groupName).observeSingleEvent(of: .value, with: { (snapshot) in
            if (snapshot.exists()) {
                self.alertController?.message = "Sorry, name already existed"
                self.actionToEnable!.isEnabled = false
            } else {
                self.alertController?.message = "Ready to create the group?"
                self.actionToEnable!.isEnabled = true
            }
        })
    }
    
    // TODO: - Dismiss Popover after click
    //XIN: add contacts moved to here
    @IBAction func buttonAddClickedAction(_ sender: Any) {
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
        
        self.usernameTextField!.addTarget(self, action: #selector(checkIfContactUsernameExists), for: .editingChanged)
    }
    
    private func addNewContact() {
        let contactItem = [
            "username": self.contactUsername!
        ]
        let friendContactItem = [
            "username": self.username!
        ]
        self.userContactsRef!.child(self.contactUserId!).setValue(contactItem)
        self.friendContactsRef!.child(self.contactUserId!).child(userId).setValue(friendContactItem)
        self.dismiss(animated: true, completion: nil)
    }
    
    private func getUsername() {
        self.usersRef.queryOrderedByKey().queryEqual(toValue: self.userId).observeSingleEvent(of: .value, with: { (snapshot) in
            if (snapshot.exists()) {
                let user = snapshot.value as! NSDictionary
                let value = user[self.userId] as! NSDictionary
                let username = value["username"] as! String
                self.username = username
            }
        })
    }

    @objc private func checkIfContactUsernameExists() {
        let contactUsername = usernameTextField!.text
        self.usersRef.queryOrdered(byChild: "username").queryEqual(toValue: contactUsername).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                self.actionToEnable!.isEnabled = true
                self.alertController?.message = "User Found"
                let contact = snapshot.value as! NSDictionary
                let keys = contact.allKeys as! [String]
                let contactUserId = keys[0]
                self.contactUserId = contactUserId
                self.contactUsername = contactUsername
            } else {
                self.alertController?.message = "User does not exist"
            }
        })
    }

    //new chat
    @IBAction func newChat(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle:nil)
        let popContactList = storyboard.instantiateViewController(withIdentifier: "newList")
        self.present(popContactList, animated: true, completion: nil)
    }
}
