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
    private var chatsRefHandle: DatabaseHandle?
    var alertController:UIAlertController? = nil
    var emailTextField: UITextField? = nil
    var senderDisplayName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Chats"
        observeChats()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
    }
    
    @IBAction func AddClickedAction(_ sender: Any) {
        self.alertController = UIAlertController(title: "Start Chat", message: "Please provide the email", preferredStyle: UIAlertControllerStyle.alert)
        
        let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            if let email = self.emailTextField?.text {
                let newChatsRef = self.chatsRef.childByAutoId()
                let chatItem = [
                    "title": email
                ]
                newChatsRef.setValue(chatItem)
            }
        })
        
        alertController!.addAction(OKAction)
        
        self.alertController!.addTextField { (textField) -> Void in
            self.emailTextField = textField
            self.emailTextField?.placeholder = "Enter the email"
        }
        
        present(self.alertController!, animated: true, completion:nil)
    }
    
    deinit {
        if let refHandle = chatsRefHandle {
            chatsRef.removeObserver(withHandle: refHandle)
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
        return cell
    }
    
    private func observeChats() {
        chatsRefHandle = chatsRef.observe(.childAdded, with: { (snapshot) -> Void in
            let chatsData = snapshot.value as! Dictionary<String, AnyObject>
            let id = snapshot.key
            
            if let title = chatsData["title"] as! String!, title.count > 0 {
                self.chats.append(Chat(id: id, title: title))
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
            chatVc.chat = chats[selectedRow]
            chatVc.senderDisplayName = senderDisplayName
        }
    }
}
