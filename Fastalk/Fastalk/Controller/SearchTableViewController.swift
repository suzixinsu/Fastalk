//
//  SearchTableViewController.swift
//  Fastalk
//
//  Created by Dan Xu on 3/30/18.
//  Copyright © 2018 IOSGroup7. All rights reserved.
//

import UIKit
import Firebase
enum Section: Int {
    case searchSection = 0
    case resultsSection
}

class SearchTableViewController: UITableViewController {
    var senderDisplayName: String?
    var textFieldSearch: UITextField?
    private var messages: [Message] = []

    var userId = Auth.auth().currentUser!.uid
    let messagesByUserRef = Constants.refs.databaseMessagesByUser
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //messages.append(Message(id: "1", text: "Message1"))
        self.tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Search"

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let currentSection: Section = Section(rawValue: section) {
            switch currentSection {
            case .searchSection:
                return 1
            case .resultsSection:
                return messages.count
            }
        } else {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = (indexPath as NSIndexPath).section == Section.searchSection.rawValue ? "Search" : "Results"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        
        if (indexPath as NSIndexPath).section == Section.searchSection.rawValue {
            if let searchMessageCell = cell as? SearchMessageCell {
                textFieldSearch = searchMessageCell.textFieldSearchKeyword
                searchMessageCell.delegate = self;
            }
        } else if (indexPath as NSIndexPath).section == Section.resultsSection.rawValue {
            cell.textLabel?.text = messages[(indexPath as NSIndexPath).row].text
            cell.detailTextLabel?.text = messages[(indexPath as NSIndexPath).row].id
        }
        return cell
    }

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SearchTableViewController: SearchMessageCellProtocol {
    func searchClicked(_ sender: SearchMessageCell) {
        let keyword = self.textFieldSearch?.text
        self.messagesByUserRef.child(userId).queryOrdered(byChild: "text").queryEqual(toValue: keyword).observeSingleEvent(of: .value, with: { (snapshot) in
            if (snapshot.exists()) {
                print(snapshot)
            }
        })
    }
}
