//
//  messagesVC.swift
//  ChatApp
//
//  Created by Ugo Besa on 20/01/2016.
//  Copyright © 2016 Ugo Besa. All rights reserved.
//

import UIKit
import Parse

class messagesVC: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    //MARK: Outlets
    @IBOutlet weak var resultsTableView: UITableView!
    
    
    
    //MARK: Variables
    var resultsNames = [String]()
    var resultsImageFiles = [PFFile]()
    
    var senders = [String]()
    var others = [String]()
    var messages = [String]()

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
                
                // Ensenmble de for : coder avec le cul mais marche. il faut recommencer plusieurs fois cette boucle pour que ça marche
                for var times = 1 ; times < 4 ; times++ {
                    
                    for var i = 0 ; i<self.senders.count ; i++ {
                        
                        let senderA = self.senders[i]
                        let otherB = self.others[i]
                        
                        for var j = i + 1 ; j<self.senders.count ;j++ {
                            if ( (senderA == self.senders[j] && otherB == self.others[j]) || (senderA == self.others[j] && otherB == self.senders[j]) ){
                                self.senders.removeAtIndex(j)
                                self.others.removeAtIndex(j)
                                self.messages.removeAtIndex(j)
                            }
                        }
                    }
                
                }
                
                self.results = self.others.count
                self.currentResult = 0
                self.fetchResults()
                
            }
        }
        
    }
    
    
    func fetchResults(){
        
        if currentResult < results {
            
            let queryF = PFUser.query()
            
            // We want the profile of the one we are talking with. Not our profile
            if(senders[currentResult] == username){
                 queryF!.whereKey("username", equalTo: self.others[currentResult])
            }
            else{
                queryF!.whereKey("username", equalTo: self.senders[currentResult])
            }
            
            let objects = try!queryF!.findObjects()
            
            for object in objects {
                self.resultsNames.append(object.objectForKey("username") as!String)
                self.resultsImageFiles.append(object.objectForKey("photo") as!PFFile)
                
                self.currentResult += 1
                self.fetchResults()
                
                self.resultsTableView.reloadData() // should may be put it before fetchResults()
            }
            
        }
    }
    
    func removeArrays(){
        resultsNames.removeAll(keepCapacity: false)
        resultsImageFiles.removeAll(keepCapacity: false)
        
        senders.removeAll(keepCapacity: false)
        others.removeAll(keepCapacity: false)
        messages.removeAll(keepCapacity: false)
    }

    //MARK:table functions
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:messageCell = tableView.dequeueReusableCellWithIdentifier("Cell") as!messageCell
        
        cell.usernameLabel.text = self.resultsNames[indexPath.row]
        cell.messageLabel.text = self.messages[indexPath.row]
        //cell.nameLabel.text = self.others3[indexPath.row]
        
        resultsImageFiles[indexPath.row].getDataInBackgroundWithBlock { (imageData:NSData?, error:NSError?) -> Void in
            if error == nil {
                let image = UIImage(data: imageData!);
                cell.profileImageView.image = image
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)as!messageCell
        otherName = cell.usernameLabel.text!
        performSegueWithIdentifier("goToConversationVC2", sender: self)
    }

}
