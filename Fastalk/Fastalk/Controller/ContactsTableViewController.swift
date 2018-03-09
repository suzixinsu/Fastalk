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
    private var usersRef = Constants.refs.databaseUsers
    private var contactsRefHandle: DatabaseHandle?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Contacts"
        getUsernameThenObserve()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
    }
    
    deinit {
        if let refHandle = contactsRefHandle {
            contactsRef.removeObserver(withHandle: refHandle)
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
    private func getUsernameThenObserve() {
        let userId = Auth.auth().currentUser?.uid
        self.usersRef.queryOrdered(byChild: "userId").queryEqual(toValue: userId).observeSingleEvent(of: .value, with: { (snapshot) in
            if (snapshot.exists()) {
                let value = snapshot.value as? NSDictionary
                for (k, _) in value! {
                    let username = (k as! String)
                    self.contactsRef = self.contactsRef.child(username)
                    self.observeContacts()
                }
            }
        })
    }
    
    private func observeContacts() {
        contactsRefHandle = contactsRef.observe(.childAdded, with: { (snapshot) -> Void in
            print(snapshot)
            let contactsData = snapshot.value as! Dictionary<String, AnyObject>
            if let username = contactsData["username"] as! String!, let userId = contactsData["userId"] as! String!, username.count > 0 {
                self.contacts.append(Contact(username: username, userId: userId))
                self.tableView.reloadData()
            } else {
                print("Error! Could not decode contact data")
            }
        })
    }

    /*
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
