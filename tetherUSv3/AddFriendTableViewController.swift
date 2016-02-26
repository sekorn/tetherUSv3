//
//  AddFriendTableViewController.swift
//  tetherUSv3
//
//  Created by Scott on 2/19/16.
//  Copyright © 2016 Scott Kornblatt. All rights reserved.
//

import UIKit
import Firebase

class AddFriendTableViewController: UITableViewController {

    var user: User?
    let AddFriendSegue = "AddFriendListToAddFriendSegue"
    
    let usersRef = Firebase(url: FirebaseConstants.USERLIST)
    var userSnapshot: FDataSnapshot? = nil
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var results:[String] = []
    var ids:[String] = []
    
    var selectedIndex:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        //searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        searchController.searchBar.delegate = self
        
        tableView.dataSource = self
        tableView.delegate = self
    
    }

    override func viewWillAppear(animated: Bool) {
        usersRef.observeSingleEventOfType(.Value, withBlock: {(snapshot) -> Void in
            if snapshot.exists() {
                self.userSnapshot = snapshot
            }
        })
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return results.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! FriendTableViewCell

        cell.emailLabel.text = results[indexPath.row]
        
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selectedIndex = indexPath.row
        //self.performSegueWithIdentifier(AddFriendSegue, sender: nil)
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        self.searchController.searchBar.text?.removeAll()
        results = []
        self.tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == AddFriendSegue {
            let vc = segue.destinationViewController as? AddFriendViewController
            vc?.friendEmail = results[self.selectedIndex]
            vc?.friendId = ids[self.selectedIndex]
            print(results[self.selectedIndex])
        }
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension AddFriendTableViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        //print(self.searchController.searchBar.text!)
        
        let searchExclusions = FirebaseUtils.GetSearchExclusions(self.user!.uid)
        
        if userSnapshot != nil {
            
            let enumerator = userSnapshot?.children
            while let item = enumerator?.nextObject() as? FDataSnapshot {
                if !searchExclusions.contains(item.key) {
                    if let email = item.value.objectForKey("email")?.lowercaseString where email == self.searchController.searchBar.text!.lowercaseString {
                        print("email: \(email)")
                        results.append(email)
                        ids.append(item.key)
                        tableView.reloadData()
                    }
                }
            }
        }
    }
}
