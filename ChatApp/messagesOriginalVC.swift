//
//  messagesVC.swift
//  ChatApp
//
//  Created by Ugo Besa on 20/01/2016.
//  Copyright © 2016 Ugo Besa. All rights reserved.
//

import UIKit
import Parse

class messagesOriginalVC: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    //MARK: Outlets
    @IBOutlet weak var resultsTableView: UITableView!
    
    
    
    //MARK: Variables
    var resultsNames = [String]()
    var resultsImageFiles = [PFFile]()
    
    var senders = [String]()
    var others = [String]()
    var messages = [String]()
    
    var senders2 = [String]()
    var others2 = [String]()
    var messages2 = [String]()
    
    var senders3 = [String]()
    var others3 = [String]()
    var messages3 = [String]()
    
    var results = 0
    var currentResult = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let width = view.frame.size.width
        let height = view.frame.size.height
        
        resultsTableView.frame = CGRectMake(0, 0, width, height-64)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        removeArrays()
        
        // All this code is for having the last messages of the username.....
        // Very complicated. Must be easier solution
        // !!!!!
        let predicate = NSPredicate(format: "sender = %@ OR other = %@", username,username)
        let query:PFQuery = PFQuery(className: "Messages", predicate: predicate)
        query.addDescendingOrder("createdAt")
        
        query.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error:NSError?) -> Void in
            if error == nil{
                
                for object in objects! {
                    self.senders.append(object.objectForKey("sender") as!String) // all the senders
                    self.others.append(object.objectForKey("other") as!String) // all the others
                    self.messages.append(object.objectForKey("message") as!String) // all the messages
                }
                
                for var i = 0 ; i <= self.senders.count-1 ; i++ {
                    if self.senders[i]==username {
                        // others2 is all the other that sent a message to username
                        self.others2.append(self.others[i])
                    }
                    else{
                        self.others2.append(self.senders[i])
                    }
                    
                    self.messages2.append(self.messages[i]) // ?
                    self.senders2.append(self.senders[i]) // ?
                }
                
                for var i2 = 0 ; i2 <= self.others2.count-1 ; i2++ {
                    
                    var isFound = false
                    
                    for var i3 = 0 ; i3 <= self.others3.count-1 ; i3++ {
                        if self.others3[i3] == self.others2[i2] {
                            isFound = true
                        }
                    }
                    
                    if isFound == false{
                        self.others3.append(self.others2[i2])
                        self.messages3.append(self.messages2[i2])
                        self.senders3.append(self.senders3[i2])
                    }
                    
                }
                
                self.results = self.others3.count
                self.currentResult = 0
                self.fetchResults()
                
            }
            else{
                
            }
        }
        // !!!!!
        
        
    }
    
    
    func fetchResults(){
        
        if currentResult < results {
            
            let queryF = PFUser.query()
            queryF!.whereKey("username", equalTo: self.others3[currentResult])
            let objects = try!queryF!.findObjects()
            
            for object in objects {
                self.resultsNames.append(object.objectForKey("username") as!String)
                self.resultsImageFiles.append(object.objectForKey("photo") as!PFFile)
                
                self.currentResult += 1
                self.fetchResults()
                
                self.resultsTableView.reloadData()
            }
            
        }
    }
    
    func removeArrays(){
        resultsNames.removeAll(keepCapacity: false)
        resultsImageFiles.removeAll(keepCapacity: false)
        
        senders.removeAll(keepCapacity: false)
        others.removeAll(keepCapacity: false)
        messages.removeAll(keepCapacity: false)
        
        senders2.removeAll(keepCapacity: false)
        others2.removeAll(keepCapacity: false)
        messages2.removeAll(keepCapacity: false)
        
        senders3.removeAll(keepCapacity: false)
        others3.removeAll(keepCapacity: false)
        messages3.removeAll(keepCapacity: false)
    }
    
    //MARK:table functions
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultsNames.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:messageCell = tableView.dequeueReusableCellWithIdentifier("Cell") as!messageCell
        
        cell.usernameLabel.text = self.resultsNames[indexPath.row]
        cell.messageLabel.text = self.messages3[indexPath.row]
        //cell.nameLabel.text = self.others3[indexPath.row]
        
        resultsImageFiles[indexPath.row].getDataInBackgroundWithBlock { (imageData:NSData?, error:NSError?) -> Void in
            if error == nil {
                let image = UIImage(data: imageData!);
                cell.profileImageView.image = image
            }
        }
        
        return cell
    }
    
}
