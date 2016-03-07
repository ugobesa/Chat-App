//
//  usersVC.swift
//  ChatApp
//
//  Created by Ugo Besa on 15/01/2016.
//  Copyright © 2016 Ugo Besa. All rights reserved.
//

import UIKit
import Parse

// Global variables. Can be access anywhere. Caution of the life cycle
var username = ""

class usersVC: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet weak var resultsTable: UITableView!
    
    var usernames = [String]()
    var profileImageFiles = [PFFile]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let width = view.frame.size.width
        let height = view.frame.size.height
        
        
        resultsTable.frame = CGRectMake(0, 0, width, height-64) // 64 is the height of the navigation controller
        
        let messagesBarButton = UIBarButtonItem(title: "Messages", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("messages"))
        
        let groupBarButton = UIBarButtonItem(title: "Group", style: .Plain, target: self, action: Selector("group"))
        
        let buttons = NSArray(objects: messagesBarButton,groupBarButton)
        navigationItem.rightBarButtonItems = buttons as? [UIBarButtonItem]
        
        
        username = (PFUser.currentUser()?.username)!
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.hidesBackButton = true;
        
        usernames.removeAll(keepCapacity: false)
        profileImageFiles.removeAll(keepCapacity: false)
        
        let predicate = NSPredicate(format: "username != '"+username+"'")
        let query = PFQuery(className: "_User", predicate: predicate) // We get all the users without the current user
        query.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error:NSError?) -> Void in
            if error == nil{
                for object in objects!{
                    let user:PFUser = object as!PFUser
                    self.usernames.append(user.username!)
                    // if we want to get an extrafield that we created
                    // extrafield = object["extraFieldName"] as!String
                    self.profileImageFiles.append(object["photo"]as!PFFile)
                    
                    self.resultsTable.reloadData() // reload each time
                    print("reload")
                }
            }
        }
    }
    
    //MARK: buttons methods
    
    func messages() {
        self.performSegueWithIdentifier("goToMessagesVCFromUsersVC", sender: self)
    }
    
    func group() {
        self.performSegueWithIdentifier("goToGroupVCFromUsersVC", sender: self)
    }

    
    //MARK: table view methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usernames.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:resultsCell = tableView.dequeueReusableCellWithIdentifier("Cell") as!resultsCell // as!... -> cast
        
        cell.profileNameLabel.text = usernames[indexPath.row];
        
        profileImageFiles[indexPath.row].getDataInBackgroundWithBlock { (imageData:NSData?, error:NSError?) -> Void in
            if error == nil{
                let image = UIImage(data:imageData!)
                cell.profileImage.image = image
            }
        }
        
        return cell;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)as!resultsCell
        otherName = cell.profileNameLabel.text!
        performSegueWithIdentifier("goToConversationVC", sender: self)
        
    }
    
    //MARK: IBAction methods
    
    @IBAction func logout(sender: AnyObject) {
        PFUser.logOut()
        navigationController?.popToRootViewControllerAnimated(true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
