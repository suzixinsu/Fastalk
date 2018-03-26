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
    let userId = Auth.auth().currentUser!.uid

    override func viewDidLoad() {
        super.viewDidLoad()
        updateReference()
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
    
    private func updateReference() {
        let userId = Auth.auth().currentUser?.uid
        self.userChatsRef = self.chatsRef.child(userId!)
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
    
    // MARK: - UI Actions
    //TODO: - navigate to contacts
    @IBAction func newChatClickedAction(_ sender: Any) {
        //TODO: navigate to contacts
        self.alertController = UIAlertController(title: "New Chat", message: "Please provide the username", preferredStyle: UIAlertControllerStyle.alert)
        
        self.alertController!.addTextField { (textField) -> Void in
            self.usernameTextField = textField
            self.usernameTextField?.placeholder = "Enter the username"
        }

        let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            let friendname = self.usernameTextField!.text!
            //TODO: - change date to last message
            let date = self.getDate()
            let friendChatItem = [
                "title": self.username,
                "timeStamp": date
            ]
            let friendNewChatRef = self.friendChatsRef!.childByAutoId()
            friendNewChatRef.setValue(friendChatItem)
            
            let chatId = friendNewChatRef.key
            let userNewChatRef = self.chatsRef.child(self.userId).child(chatId)
            let userChatItem = [
                "title": friendname,
                "timeStamp": date
            ]
            userNewChatRef.setValue(userChatItem)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel)
        alertController!.addAction(OKAction)
        alertController!.addAction(cancelAction)
        OKAction.isEnabled = false
        actionToEnable = OKAction
        present(self.alertController!, animated: true, completion:nil)
        
        self.usernameTextField!.addTarget(self, action: #selector(checkIfUserExists), for: .editingChanged)
    }
    
    @objc func checkIfUserExists() {
        self.alertController?.message = "Checking..."
        let username = usernameTextField!.text
        guard !(username?.isEmpty)! else {
            return
        }
        self.usersRef.queryOrdered(byChild: "username").queryEqual(toValue: username).observeSingleEvent(of: .value, with: { (snapshot) in
            if (snapshot.exists()) {
                self.alertController?.message = "Ready to chat with \(username ?? "the user")?"
                self.actionToEnable!.isEnabled = true
                let friend = snapshot.value as! NSDictionary
                let keys = friend.allKeys as! [String]
                let friendId = keys[0]
                self.friendChatsRef = self.chatsRef.child(friendId)
            } else {
                self.alertController?.message = "Sorry, user not exists."
                self.actionToEnable!.isEnabled = false
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
