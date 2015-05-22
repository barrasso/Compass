//
//  MenuTableViewController.swift
//  Compass
//
//  Created by Mark on 5/7/15.
//  Copyright (c) 2015 MEB. All rights reserved.
//

import UIKit

class MenuTableViewController: UITableViewController {
    
    // user arrays
    var userArray = [String]()
    var sortedUserArray = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None

        // load users 
        var query = PFUser.query()
        query.whereKey("username", notEqualTo: PFUser.currentUser().username)
        
        // async query
        query.findObjectsInBackgroundWithBlock { (objects:[AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                
                if let users = objects as? [PFObject] {
                    for user in users {
                        
                        let username = user.objectForKey("username") as! String
                        
                        // add usernames to user array 
                        self.userArray.append(username)
                        
                        // update table view
                        self.tableView.reloadData()
                        
                        // sort user array alphabetically
                        self.sortedUserArray = self.userArray.sorted({
                            $0.localizedCaseInsensitiveCompare($1) == NSComparisonResult.OrderedAscending
                        })
                    }
                }
            } else {
                println(error)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return  userArray.count
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let spacing = UIView(frame: CGRectMake(0, 0, self.tableView.frame.size.width, 20.0))
        spacing.backgroundColor = UIColor.clearColor()
        return spacing
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return 1
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.dequeueReusableCellWithIdentifier("usercell", forIndexPath: indexPath) as! UserCell
        
        // set cell labels
        cell.userCellTitle.text = sortedUserArray[indexPath.section]

        // set queried user defaults
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(sortedUserArray[indexPath.section], forKey: "queriedUser")
        
        // post internal notification
        NSNotificationCenter.defaultCenter().postNotificationName("QueryIdentifier", object: nil)
        
        // segue to map view and start following
        self.revealViewController().revealToggleAnimated(true)
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("usercell", forIndexPath: indexPath) as! UserCell

        // set cell labels
        cell.userCellTitle.text = sortedUserArray[indexPath.section]
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
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
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
