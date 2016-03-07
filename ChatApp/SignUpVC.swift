//
//  SignUpVC.swift
//  ChatApp
//
//  Created by Ugo Besa on 14/01/2016.
//  Copyright © 2016 Ugo Besa. All rights reserved.
//

import UIKit
import Parse


class SignUpVC: UIViewController,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITextFieldDelegate {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signupButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
         setApparence()
    }

    
    // MARK: helper methods
    func setApparence(){
        
        let width = view.frame.size.width
        
        profileImage.center = CGPointMake(width/2, 140)
        profileImage.layer.cornerRadius = profileImage.frame.size.width/2
        profileImage.clipsToBounds = true
        addPhotoButton.center = CGPointMake(profileImage.frame.maxX+50, 140)
        usernameTextField.frame = CGRectMake(16, 230, width-32, 30)
        passwordTextField.frame = CGRectMake(16, 270, width-32, 30)
        emailTextField.frame = CGRectMake(16, 310, width-32, 30)
        signupButton.center = CGPointMake(width/2, 380)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    //MARK: IBActions
    @IBAction func addProfilePhoto(sender: AnyObject) {
        
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        image.allowsEditing = true
        self.presentViewController(image, animated: true, completion: nil)
    }
    
    @IBAction func signup(sender: AnyObject) {
        
        let user = PFUser()
        user.username = usernameTextField.text
        user.password = passwordTextField.text
        user.email = emailTextField.text
        
        let imageData = UIImagePNGRepresentation(profileImage.image!)
        let imageFile = PFFile(name: "profilePhoto.png", data: imageData!)
        user["photo"] = imageFile
        
        user.signUpInBackgroundWithBlock { (succeded:Bool, signupError:NSError?) -> Void in
            if signupError == nil {
                print("Sign up!")
                
                let installation:PFInstallation = PFInstallation.currentInstallation()
                installation["user"]=PFUser.currentUser()
                installation.saveInBackground()
                
                self.performSegueWithIdentifier("goToUsersVC2", sender: self)
            }
            else{
                print("Can't signup!")
            }
        }
    }
    
    
    // MARK: PickerController methods
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        profileImage.image = image;
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    //MARK: textfield methods
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        let width = view.frame.size.width
        let height = view.frame.size.height
        
        if(UIScreen.mainScreen().bounds.height == 568){ // if it's an iPhone 5 or 5s
            if(textField == emailTextField){
                UIView.animateWithDuration(0.3, delay: 0, options: .CurveLinear, animations: {
                    // We animate the main view
                    self.view.center = CGPointMake(width/2, (height/2)-40)
                    
                    }, completion: {(finished:Bool)in
                        
                })
            }
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        let width = view.frame.size.width
        let height = view.frame.size.height
        
        if(UIScreen.mainScreen().bounds.height == 568){ // if it's an iPhone 5 or 5s
            if(textField == emailTextField){
                UIView.animateWithDuration(0.3, delay: 0, options: .CurveLinear, animations: {
                    // We animate the main view, go back to initial position
                    self.view.center = CGPointMake(width/2, (height/2))
                    
                    }, completion: {(finished:Bool)in
                        
                })
            }
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true) // STOP all kinf of editing (keyboard) when we touch somewhere
    }

}
