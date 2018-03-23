//
//  ContactsTableViewController.swift
//  Fastalk
//
//  Created by Dan Xu on 3/6/18.
//  Copyright © 2018 IOSGroup7. All rights reserved.
//

import UIKit
import Firebase

class ContactsTableViewController: UITableViewController {
    private var contacts: [Contact] = []
    private var contactsRef = Constants.refs.databaseContacts
    private var userContactsRef: DatabaseReference?
    private var userContactsRefHandle: DatabaseHandle?
    private var usersRef = Constants.refs.databaseUsers
    var alertController: UIAlertController?
    var usernameTextField: UITextField?
    var actionToEnable: UIAlertAction?
    var contactUsername: String?
    var contactUserId: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Contacts"
        startObserve()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
    }
    
    deinit {
        if let refHandle = userContactsRefHandle {
            self.userContactsRef!.removeObserver(withHandle: refHandle)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    // MARK: - Overriden Methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return contacts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = "ExistingContacts"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        cell.textLabel?.text = contacts[(indexPath as NSIndexPath).row].username
        return cell
    }
    
    // MARK: - Privage Methods
    private func startObserve() {
        let userId = Auth.auth().currentUser?.uid
        self.userContactsRef = self.contactsRef.child(userId!)
        self.userContactsRefHandle = self.userContactsRef!.observe(.childAdded, with: { (snapshot) -> Void in
            print(snapshot)
            let contactsData = snapshot.value as! Dictionary<String, AnyObject>
            if let username = contactsData["username"] as! String!, username.count > 0 {
                self.contacts.append(Contact(username: username, userId: userId!))
                self.tableView.reloadData()
            } else {
                print("Error! Could not decode contact data")
            }
        })
    }
    
    private func addNewContact() {
        let contactItem = [
            "username": self.contactUsername!
        ]
        self.userContactsRef!.child(self.contactUserId!).setValue(contactItem)
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

    /*
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

}
