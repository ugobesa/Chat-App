//
//  ViewController.swift
//  ChatApp
//
//  Created by Ugo Besa on 14/01/2016.
//  Copyright © 2016 Ugo Besa. All rights reserved.
//

import UIKit
import Parse

class LoginVC: UIViewController,UITextFieldDelegate {
    
    
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setApparence()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.hidesBackButton = true;
    }
    
    func setApparence(){
        
        let width = view.frame.size.width
        let height = view.frame.size.height
        
        welcomeLabel.center = CGPointMake(width/2, 130);
        usernameTextField.frame = CGRectMake(16, 200, width-32, 30)
        passwordTextField.frame = CGRectMake(16, 240, width-32, 30)
        loginButton.center = CGPointMake(width/2, 330)
        signupButton.center = CGPointMake(width/2, height-30);
    }
    
    //MARK: textfield methods
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true) // STOP all kinf of editing (keyboard) when we touch somewhere
    }

    //MARK: IBAction methods
    @IBAction func logIn(sender: AnyObject) {
        PFUser.logInWithUsernameInBackground(usernameTextField.text!, password:passwordTextField.text!, block: {
            (user:PFUser?,error:NSError?) -> Void in
            if error == nil{
                print("Log In!")
                
                // Add the user to the PFInstallation class (for notifications)
                let installation:PFInstallation = PFInstallation.currentInstallation()
                installation["user"] = PFUser.currentUser()
                installation.saveInBackgroundWithBlock({ (success:Bool?, error:NSError?) -> Void in
                    if error == nil{
                        print("push installation success")
                    }
                    else {
                        print("push installation error")
                    }
                })
                
                self.performSegueWithIdentifier("goToUsersVC", sender: self)
            }
            else{
                print("Can't Log In")
            }
        })
    }

}

