//
//  groupVC.swift
//  ChatApp
//
//  Created by Ugo Besa on 22/01/2016.
//  Copyright © 2016 Ugo Besa. All rights reserved.
//

import UIKit
import Parse

class groupVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    

    //MARK: Outlets
    @IBOutlet weak var resultsTableView: UITableView!
    
    //MARK: Variables
    var resultsNames = Set([""]) // Set is like array except we can't insert twice the same value
    var resultsNames2 = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let width = view.frame.size.width
        let height = view.frame.size.height
        
        resultsTableView.frame = CGRectMake(0, 0, width, height-64)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        groupConversationTitle = ""
        
        self.resultsNames.removeAll(keepCapacity: false)
        self.resultsNames2.removeAll(keepCapacity: false)
        
        let query = PFQuery(className: "GroupMessages")
        query.addAscendingOrder("group")
        query.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error:NSError?) -> Void in
            if error == nil {
                for object in objects! {
                    self.resultsNames.insert(object.objectForKey("group")as!String) // all groupes are different
                    self.resultsNames2 = Array(self.resultsNames)
                    
                    self.resultsTableView.reloadData()
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultsNames2.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("groupCell") as!groupCell
        
        cell.groupNameLabel.text = resultsNames2[indexPath.row]
        
        return cell
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 40;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //let cell = tableView.cellForRowAtIndexPath(indexPath) as!groupCell
        
        groupConversationTitle = resultsNames2[indexPath.row]
        
        performSegueWithIdentifier("goToGroupConversationVCFromGroupVC", sender: self)
    }
    
    @IBAction func addGroup(sender: AnyObject) {
        
        let alert = UIAlertController(title: "New Group", message: "Type the name of the group", preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler { (textField) -> Void in
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action:UIAlertAction) -> Void in
            
            let name = alert.textFields![0]
            
            // Create a new group
            let groupMessageObj = PFObject(className: "GroupMessages")
            groupMessageObj["sender"] = username
            groupMessageObj["message"] = "\(username) created a new group"
            groupMessageObj["group"] = name.text!
            
            groupMessageObj.saveInBackground()

            //segue to this conversation group
            groupConversationTitle = name.text!
            self.performSegueWithIdentifier("goToGroupConversationVCFromGroupVC", sender: self)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action:UIAlertAction) -> Void in
            
        }))
        
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    

}
