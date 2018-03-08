//
//  ChatsListTableViewController.swift
//  Fastalk
//
//  Created by Dan Xu on 3/3/18.
//  Copyright © 2018 IOSGroup7. All rights reserved.
//

import UIKit
import Firebase

class ChatsListTableViewController: UITableViewController {
    private var chats: [Chat] = []
    private var chatsRef = Constants.refs.databaseChats
    private var usersRef = Constants.refs.databaseUsers
    private var chatsRefHandle: DatabaseHandle?
    var alertController:UIAlertController? = nil
    var emailTextField: UITextField? = nil
    var senderDisplayName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Chats"
        getUsernameThenObserve()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
    }
    
    deinit {
        if let refHandle = chatsRefHandle {
            chatsRef.removeObserver(withHandle: refHandle)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source
    // MARK: - Overriden Methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = "ExistingChats"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        cell.textLabel?.text = chats[(indexPath as NSIndexPath).row].title
        cell.detailTextLabel?.text = chats[(indexPath as NSIndexPath).row].timeStamp
        return cell
    }
    
    // MARK: - Privage Methods
    /* show full date if time difference larger than 24 hours
    private func showDate(_ thenDateString:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm MM/dd/yy"
        let thenDate = dateFormatter.date(from: thenDateString)
        let nowDate = Date()
        let calendar = Calendar.current
        let diffHours = calendar.dateComponents([.hour], from: thenDate!, to: nowDate).hour ?? 0
        if (diffHours >= 24) {
            return thenDateString
        } else {
            dateFormatter.dateFormat = "hh:mm"
            let convertedDate = dateFormatter.string(from: thenDate!)
            return convertedDate
        }
    }
    */
    
    private func getUsernameThenObserve() {
        let userId = Auth.auth().currentUser?.uid
        self.usersRef.queryOrdered(byChild: "userId").queryEqual(toValue: userId).observeSingleEvent(of: .value, with: { (snapshot) in
            if (snapshot.exists()) {
                let value = snapshot.value as? NSDictionary
                for (k, _) in value! {
                    let username = (k as! String)
                    self.chatsRef = self.chatsRef.child(username)
                    self.observeChats()
                }
            }
        })
    }
    
    private func observeChats() {
        chatsRefHandle = chatsRef.observe(.childAdded, with: { (snapshot) -> Void in
            let chatsData = snapshot.value as! Dictionary<String, AnyObject>
            let id = snapshot.key
            if let title = chatsData["title"] as! String!, let timeStamp = chatsData["timeStamp"] as! String!, title.count > 0 {
                self.chats.append(Chat(id: id, title: title, timeStamp: timeStamp))
                self.tableView.reloadData()
            } else {
                print("Error! Could not decode chat data")
            }
        })
    }

    // MARK: - UI Actions
    @IBAction func AddClickedAction(_ sender: UIBarButtonItem) {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "popoverViewController")
        vc.modalPresentationStyle = UIModalPresentationStyle.popover
        vc.preferredContentSize = CGSize(width: 150, height: 100)
        let popover = vc.popoverPresentationController!
        popover.barButtonItem = sender
        popover.delegate = self
        present(vc, animated: true, completion:nil)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = tableView.indexPathForSelectedRow{
            let selectedRow = indexPath.row
            let chatVc = segue.destination as! ChatViewController
            let selectedChat = chats[selectedRow]
            chatVc.chat = selectedChat
            chatVc.messagesRef = Constants.refs.databaseMessages.child("chats").child(selectedChat.id)
        }
    }
}

extension ChatsListTableViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
}
