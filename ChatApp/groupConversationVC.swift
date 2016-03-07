//
//  groupConversationVC.swift
//  ChatApp
//
//  Created by Ugo Besa on 23/01/2016.
//  Copyright © 2016 Ugo Besa. All rights reserved.
//

import UIKit
import Parse

var groupConversationTitle = ""

class groupConversationVC: UIViewController,UIScrollViewDelegate,UITextFieldDelegate {
    
    //MARK: Outlets
    @IBOutlet weak var resultsScrollView: UIScrollView!
    @IBOutlet weak var frameMessageView: UIView!
    @IBOutlet weak var lineLabel: UILabel! // to trace a line
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    
    // MARK: Variables
    var scrollViewOriginalY:CGFloat = 0 // We initialize global value to prevent synthesize error
    var frameMessageOriginalY:CGFloat = 0
    
    let enterTextIndicationLabel = UILabel(frame: CGRectMake(5,8,200,20)) // message textView doesn't have a placeholder to indicate it's here the user write the message so we use this new label to indicate it
    
    // Coordinates of first message
    var messageX:CGFloat = 37.0
    var messageY:CGFloat = 26.0
    // for the second label to do the border
    var frameX:CGFloat = 32.0
    var frameY:CGFloat = 21.0
    // fot the profile image
    var imageX:CGFloat = 3.0
    var imageY:CGFloat = 3.0
    
    var messages = [String]()
    var senders = [String]()
    
    var senderImage:UIImage? = UIImage()
    
    // I think an array is useless since there is only one sender and one other here
    var resultsImageFiles = [PFFile]()
    var resultsImageFiles2 = [PFFile]()
    
    
    //MARK: view... functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let width = view.frame.size.width
        let height = view.frame.size.height
        
        resultsScrollView.frame = CGRectMake(0, 64, width, height-114)
        resultsScrollView.layer.zPosition = 20
        frameMessageView.frame = CGRectMake(0, resultsScrollView.frame.maxY, width, 50)
        lineLabel.frame = CGRectMake(0, 0, width, 1)
        messageTextView.frame = CGRectMake(2, 1, frameMessageView.frame.size.width-52, 48)
        sendButton.center = CGPointMake(frameMessageView.frame.size.width-30, 24)
        
        scrollViewOriginalY = resultsScrollView.frame.origin.y
        frameMessageOriginalY = frameMessageView.frame.origin.y
        
        enterTextIndicationLabel.text = "Type a message"
        enterTextIndicationLabel.backgroundColor = UIColor.clearColor()
        enterTextIndicationLabel.textColor = UIColor.lightGrayColor()
        messageTextView.addSubview(enterTextIndicationLabel)
        
        // when the keyboard is shown, the "keyBoardWasShown" is launched
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyBoardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyBoardWillHide", name: UIKeyboardWillHideNotification, object: nil)
        
        // to hide the keyboard when we tap the screen
        let tapScrollViewGesture = UITapGestureRecognizer(target: self, action: "didTapScrollView")
        tapScrollViewGesture.numberOfTapsRequired = 1
        resultsScrollView.addGestureRecognizer(tapScrollViewGesture)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "getGroupMessageFunc", name: "getGroupMessage", object: nil)


    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        title = groupConversationTitle
        
        let query = PFQuery(className: "_User")
        query.whereKey("username", equalTo: username)
        let objects = try!query.findObjects()
        resultsImageFiles.removeAll(keepCapacity: false)
        
        for object in objects {
            
            resultsImageFiles.append(object["photo"]as!PFFile)
            resultsImageFiles[0].getDataInBackgroundWithBlock({ (imageData:NSData?, error:NSError?) -> Void in
                if error == nil {
                    self.senderImage = UIImage(data: imageData!)
                    self.refreshResults()
                }
            })
        }
    }
    
    //MARK: Refresh
    func refreshResults(){
        
        let width = view.frame.size.width
        //let height = view.frame.size.height
        
        messageX = 37.0
        messageY = 26.0
        frameX = 32.0
        frameY = 21.0
        imageX = 3
        imageY = 3
        
        messages.removeAll(keepCapacity: false)
        senders.removeAll(keepCapacity: false)
        
        
        
        let query = PFQuery(className: "GroupMessages")
        query.addAscendingOrder("createdAt")
        query.whereKey("group", equalTo: groupConversationTitle)
        query.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error:NSError?) -> Void in
            if error == nil{
                for object in objects!{
                    self.senders.append(object.objectForKey("sender")as!String)
                    self.messages.append(object.objectForKey("message")as!String)
                }
            }
            
            for subView in self.resultsScrollView.subviews {
                subView.removeFromSuperview()
            }
            
            // We check where the sender is the actual user
            for var i = 0; i<=self.messages.count-1; i++ {
                if self.senders[i] == username{
                    
                    let messageLbl:UILabel = UILabel(frame: CGRectMake(0,0,self.resultsScrollView.frame.size.width-94,CGFloat.max))
                    messageLbl.backgroundColor = UIColor(red: 74/255, green: 141/255, blue: 242/255, alpha: 1.0)
                    messageLbl.lineBreakMode = NSLineBreakMode.ByWordWrapping // tester cette ligne ?
                    messageLbl.textAlignment = NSTextAlignment.Left
                    messageLbl.numberOfLines = 0 // can have maximum of lines
                    messageLbl.font = UIFont(name: "Helvetica Neuse", size: 17.0)
                    messageLbl.textColor = UIColor.whiteColor()
                    messageLbl.text = self.messages[i]
                    messageLbl.sizeToFit()
                    messageLbl.layer.zPosition = 20
                    messageLbl.frame.origin.x = (self.resultsScrollView.frame.size.width - self.messageX) - messageLbl.frame.size.width
                    messageLbl.frame.origin.y = self.messageY
                    self.resultsScrollView.addSubview(messageLbl)
                    self.messageY += messageLbl.frame.size.height + 30 // update the y position for the next message
                    
                    let frameLbl:UILabel = UILabel()
                    frameLbl.frame.size = CGSizeMake(messageLbl.frame.size.width+10, messageLbl.frame.size.height+10)
                    frameLbl.frame.origin.x = (self.resultsScrollView.frame.size.width - self.frameX) - frameLbl.frame.size.width
                    frameLbl.frame.origin.y = self.frameY
                    frameLbl.backgroundColor = UIColor(red: 74/255, green: 141/255, blue: 242/255, alpha: 1.0)
                    frameLbl.layer.masksToBounds = true
                    frameLbl.layer.cornerRadius = 10
                    self.resultsScrollView.addSubview(frameLbl)
                    self.frameY += frameLbl.frame.size.height + 20
                    
                    let imageView:UIImageView = UIImageView()
                    imageView.image = self.senderImage
                    imageView.frame.size = CGSizeMake(34,34)
                    imageView.frame.origin.x = (self.resultsScrollView.frame.width - self.imageX) - imageView.frame.size.width
                    imageView.frame.origin.y = self.imageY
                    imageView.layer.zPosition = 30
                    imageView.layer.cornerRadius = imageView.frame.size.width/2
                    imageView.clipsToBounds = true
                    self.resultsScrollView.addSubview(imageView)
                    self.imageY += frameLbl.frame.size.height + 20
                    
                    self.resultsScrollView.contentSize = CGSizeMake(width,self.messageY)
                    
                }
                else{
                    let messageLbl:UILabel = UILabel(frame: CGRectMake(0,0,self.resultsScrollView.frame.size.width-94,CGFloat.max))
                    messageLbl.backgroundColor = UIColor.groupTableViewBackgroundColor()
                    messageLbl.lineBreakMode = NSLineBreakMode.ByWordWrapping // tester cette ligne ?
                    messageLbl.textAlignment = NSTextAlignment.Left
                    messageLbl.numberOfLines = 0 // can have maximum of lines
                    messageLbl.font = UIFont(name: "Helvetica Neuse", size: 17.0)
                    messageLbl.textColor = UIColor.blackColor()
                    messageLbl.text = self.messages[i]
                    messageLbl.sizeToFit()
                    messageLbl.layer.zPosition = 20
                    messageLbl.frame.origin.x = self.messageX
                    messageLbl.frame.origin.y = self.messageY
                    self.resultsScrollView.addSubview(messageLbl)
                    self.messageY += messageLbl.frame.size.height + 30 // update the y position for the next message
                    
                    let frameLbl:UILabel = UILabel()
                    frameLbl.frame = CGRectMake(self.frameX, self.frameY, messageLbl.frame.size.width + 10, messageLbl.frame.size.height + 10)
                    frameLbl.backgroundColor = UIColor.groupTableViewBackgroundColor()
                    frameLbl.layer.masksToBounds = true
                    frameLbl.layer.cornerRadius = 10
                    self.resultsScrollView.addSubview(frameLbl)
                    self.frameY += frameLbl.frame.size.height + 20
                    
                    // Get the corresponding image for the other... Don't work
                    let imageView:UIImageView = UIImageView()
                    let query = PFQuery(className: "_Users")
                    query.whereKey("username", equalTo: self.senders[i])
                    query.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in
                        
                        if error == nil{
                            
                            self.resultsImageFiles2.removeAll(keepCapacity: false)
                            for object in objects! {
                                self.resultsImageFiles2.append(object["photo"]as!PFFile)
                                
                                self.resultsImageFiles2[0].getDataInBackgroundWithBlock({ (imageData:NSData?, error:NSError?) -> Void in
                                    if error == nil {
                                        imageView.image = UIImage(data: imageData!)
                                        
                                        print("other image ok")
                                    }
                                    else{
                                        print("other image error")
                                    }
                                    
                                })
                            }
                        }
                    })
                    imageView.frame = CGRectMake(self.imageX, self.imageY, 34, 34)
                    imageView.layer.zPosition = 30
                    imageView.layer.cornerRadius = imageView.frame.size.width/2
                    imageView.clipsToBounds = true
                    self.resultsScrollView.addSubview(imageView)
                    self.imageY += frameLbl.frame.size.height + 20
                    
                    
                    self.resultsScrollView.contentSize = CGSizeMake(width,self.messageY)
                }
                // A scroll view manages a content view, which is usually larger than the scroll view itself. The scroll view is like a window that shows just a piece of the larger content view. As you scroll, the content view moves so that different parts of it appear in the window
                //Every view as frame and bounds properties. The frame of a view is the rectangle that encloses the view in the coordinate system of its superview. The bounds is the same rectangle, but expressed in the view's own coordinate system.
                
                // With this, the scrollview is placed at the end
                let bottomOffset:CGPoint = CGPointMake(0, self.resultsScrollView.contentSize.height - self.resultsScrollView.bounds.size.height)
                self.resultsScrollView.setContentOffset(bottomOffset, animated: false)
            }
        }
        
    }
    
    //MARK: keyboard notification
    func keyBoardWillShow(notification:NSNotification){
        
        let dic:NSDictionary = notification.userInfo!
        let s:NSValue = dic.valueForKey(UIKeyboardFrameEndUserInfoKey) as!NSValue
        let rect:CGRect = s.CGRectValue() // rect is the width/height of the keyboard
        
        // We animate the scrollview + the  frame message + the offsetscrollview UP when the keyboard show
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveLinear, animations: { () -> Void in
            
            self.resultsScrollView.frame.origin.y = self.scrollViewOriginalY - rect.height
            self.frameMessageView.frame.origin.y = self.frameMessageOriginalY - rect.height
            
            let bottomOffset:CGPoint = CGPointMake(0, self.resultsScrollView.contentSize.height - self.resultsScrollView.bounds.size.height)
            self.resultsScrollView.setContentOffset(bottomOffset, animated: false) // useless ..?
            
            }) { (finished:Bool) -> Void in
        }
        
    }
    
    func keyBoardWillHide(){
        
        // We animate the scrollview + the  frame message + the offsetscrollview DOWN when the keyboard show
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveLinear, animations: { () -> Void in
            
            self.resultsScrollView.frame.origin.y = self.scrollViewOriginalY
            self.frameMessageView.frame.origin.y = self.frameMessageOriginalY
            
            let bottomOffset:CGPoint = CGPointMake(0, self.resultsScrollView.contentSize.height - self.resultsScrollView.bounds.size.height)
            self.resultsScrollView.setContentOffset(bottomOffset, animated: false)
            
            }) { (finished:Bool) -> Void in
        }
        
    }
    
    func didTapScrollView() {
        self.view.endEditing(true)
    }
    
    
    //MARK: textView delegate functions
    func textViewDidChange(textView: UITextView) {
        // if the user enter text, we hide the indication
        if !messageTextView.hasText() {
            enterTextIndicationLabel.hidden = false
            sendButton.enabled = false
        }
        else{
            enterTextIndicationLabel.hidden = true
            sendButton.enabled = true
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if !messageTextView.hasText() {
            enterTextIndicationLabel.hidden = false
            sendButton.enabled = false
        }
    }
    
    //MARK: push notification
    func getGroupMessageFunc (){
        refreshResults() // + App Delegate
    }
    
    
    //MARK: IBAction fucntions
    @IBAction func send(sender: AnyObject) {
        
        if messageTextView.text == "" {
        }
        else{
            
            let groupMessage = PFObject(className: "GroupMessages")
            groupMessage["group"] = groupConversationTitle
            groupMessage["sender"] = username
            groupMessage["message"] = messageTextView.text
            groupMessage.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                if success == true {
                    
                    // Send a push to the others
                    var senderSet = Set([""])
                    senderSet.removeAll(keepCapacity: false) // Useless ?
                    
                    for var i = 0 ; i <= self.senders.count-1 ; i++ {
                        if self.senders[i] != username {
                            senderSet.insert(self.senders[i])
                        }
                    }
                    
                    let senderSetArray:NSArray = Array(senderSet)
                    
                    for var i2 = 0 ; i2 <= senderSetArray.count-1 ; i2++ {
                        
                        // Create a query that will find the user target
                        let userQuery:PFQuery = PFUser.query()!
                        userQuery.whereKey("username", equalTo:senderSetArray[i2])
                        // this query search the PFInstallation class
                        let pushQuery:PFQuery = PFInstallation.query()!
                        pushQuery.whereKey("user", matchesQuery: userQuery)
                        // Create the push
                        let push:PFPush = PFPush()
                        push.setQuery(pushQuery)
                        push.setMessage("New Group message")
                        push.sendPushInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                            
                        })
                    }
                    
                    self.messageTextView.text = ""
                    self.enterTextIndicationLabel.hidden = false
                    self.sendButton.enabled = false
                    
                    self.refreshResults()
                }
            })
        }
    }
    

}
