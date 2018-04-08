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
    var joinGroupId: String?
    let userId = Auth.auth().currentUser!.uid

    override func viewDidLoad() {
        super.viewDidLoad()
        userChatsRef = chatsRef.child(userId)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func getDate() -> String{
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm MM/dd/yy"
        let convertedDate = dateFormatter.string(from: currentDate)
        return convertedDate
    }
    
    @IBAction func newGroupButtonClicked(_ sender: Any) {
        self.alertController = UIAlertController(title: "New Group", message: "Please provide the group name", preferredStyle: UIAlertControllerStyle.alert)
        
        self.alertController!.addTextField { (textField) -> Void in
            self.groupNameTextField = textField
            self.groupNameTextField?.placeholder = "Enter the group name"
        }
        
        let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            let groupName = self.groupNameTextField!.text!
            //TODO: - change date to last message
            let date = self.getDate()
            
            let groupItem = [
                "groupName" : groupName,
                "ownerId": self.userId
            ]
            let currentGroupRef = self.groupsRef.childByAutoId()
            currentGroupRef.setValue(groupItem)
            let currentGroupId = currentGroupRef.key
            
            let groupChatItem = [
                "receiverId": "group",
                "receiverName" : groupName,
                "timeStamp": date
            ]
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
            //TODO: - change date to last message
            let date = self.getDate()
            let groupChatItem = [
                "receiverId": "group",
                "receiverName" : groupName,
                "timeStamp": date
            ]
            self.userChatsRef!.child(self.joinGroupId!).setValue(groupChatItem)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel)
        self.alertController!.addAction(OKAction)
        self.alertController!.addAction(cancelAction)
        OKAction.isEnabled = false
        actionToEnable = OKAction
        present(self.alertController!, animated: true, completion:nil)
        
        self.groupNameTextField!.addTarget(self, action: #selector(checkIfGroupExists), for: .editingChanged)
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

    /*
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
