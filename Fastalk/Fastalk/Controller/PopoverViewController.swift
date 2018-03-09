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
        
        let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            let friendname = self.usernameTextField!.text!
            self.usersRef.queryOrdered(byChild: "username").queryEqual(toValue: friendname).observeSingleEvent(of: .value, with: { (snapshot) in
                if (snapshot.exists()) {
                    let friend = snapshot.value as! NSDictionary
                    let keys = friend.allKeys as! [String]
                    let friendId = keys[0]
                    let friendChatsRef = self.chatsRef.child(friendId)
                    let friendNewChatRef = friendChatsRef.childByAutoId()
                    //TODO: - change date to last message
                    let date = self.getDate()
                    let friendChatItem = [
                        "title": self.username,
                        "timeStamp": date
                    ]
                    friendNewChatRef.setValue(friendChatItem)
                    
                    let chatId = friendNewChatRef.key
                    let userNewChatRef = self.chatsRef.child(self.userId).child(chatId)
                    let userChatItem = [
                        "title": friendname,
                        "timeStamp": date
                    ]
                    userNewChatRef.setValue(userChatItem)
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
    
    
    
    // TODO: - Dismiss Popover after click

    /*
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
