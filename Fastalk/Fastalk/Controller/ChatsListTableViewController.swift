//
//  ChatsListTableViewController.swift
//  Fastalk
//
//  Created by Dan Xu on 3/3/18.
//  Copyright © 2018 IOSGroup7. All rights reserved.
//

import UIKit
import Firebase

class ChatsListTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate {
    private var chats: [Chat] = []
    private var chatsRef: DatabaseReference?
    private var chatsRefHandle: DatabaseHandle?
    var alertController:UIAlertController? = nil
    var emailTextField: UITextField? = nil
    var senderDisplayName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Chats"
        let userId = Auth.auth().currentUser?.uid
        chatsRef = Constants.refs.databaseUsers.child(userId!).child("chats")
        observeChats()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
    }
    
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
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    deinit {
        if let refHandle = chatsRefHandle {
            chatsRef!.removeObserver(withHandle: refHandle)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return chats.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = "ExistingChats"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        cell.textLabel?.text = chats[(indexPath as NSIndexPath).row].title
        cell.detailTextLabel?.text = chats[(indexPath as NSIndexPath).row].timeStamp
        return cell
    }
    
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
    
    private func observeChats() {
        chatsRefHandle = chatsRef!.observe(.childAdded, with: { (snapshot) -> Void in
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
    
    /*
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    */
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = tableView.indexPathForSelectedRow{
            let selectedRow = indexPath.row
            let chatVc = segue.destination as! ChatViewController
            let selectedChat = chats[selectedRow]
            chatVc.chat = selectedChat
            chatVc.messagesRef = Constants.refs.databaseMessages.child("chats").child(selectedChat.id)
//            chatVc.senderDisplayName = senderDisplayName
        }
    }
}
