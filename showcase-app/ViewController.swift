//
//  ViewController.swift
//  showcase-app
//
//  Created by Tihomir Videnov on 7/9/16.
//  Copyright © 2016 Tihomir Videnov. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase

class ViewController: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    var checkForUsername: FIRDatabaseReference!
    var userEmail = ""
    var userImage = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if UserDefaults.standard.value(forKey: KEY_UID) != nil {
            //self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
            
            checkForUserName()
        }
    }

    //Logging with FACEBOOK
    @IBAction func fbBtnPressed(_ sender: UIButton!) {
        
        let facebookLogin = FBSDKLoginManager()

        facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in

            if error != nil {
                self.showErrorAlert("Opps", msg: "Something went wrong, please try again later.")
            } else if result?.isCancelled == true {
                    self.showErrorAlert("Error", msg: "The user cancelled authentication with Facebook")
            } else {
                let accessToken = FBSDKAccessToken.current().tokenString
                print("successfully logged in with Facebook. \(accessToken)")
                
                
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                
                FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
                    
                    if error != nil {
                        print("Login failed. \(error)")
                        self.showErrorAlert("Login failed", msg: "Facebook login has failed.")
                    } else {
                        print("Logged in. \(user)")
                        
                        if let usrEmail = user?.email {
                            self.userEmail = usrEmail
                        }
                        
                        if let usrImage = user?.photoURL {
                            self.userImage = usrImage.absoluteString
                        }
                        
                        let userData = ["provider": credential.provider, "email": self.userEmail, "profileImage": self.userImage]
                        DataService.ds.createFirebaseUser(user!.uid, user: userData)
                        
                        
                        UserDefaults.standard.setValue(user!.uid, forKey: KEY_UID)
                        
                        self.checkForUserName()
                     
                        
                    }
                })
            }
        }
    }
    
    //Logging with Email and Password
    @IBAction func attemptLogin(_ sender: UIButton!) {
        
        if let email = emailField.text , email != "", let pass = passwordField.text , pass != "" {
            
            FIRAuth.auth()?.signIn(withEmail: email, password: pass, completion: { (user, error) in
                
                if error != nil {
                    print(error!)
                    
                    //if the user account doesn't exist we will still create one
                    if error?._code == STATUS_ACCOUNT_NONEXIST {
                        FIRAuth.auth()?.createUser(withEmail: email, password: pass, completion: { user, error in
                            
                            //if there is some non specified yet error
                            if error != nil {
                                print(error!)
                                self.showErrorAlert("Could not create account", msg: "Problem creating the account. Try something else")
                            } else {
                                //creating the account and logging in the user
                                UserDefaults.standard.setValue(user!.uid, forKey: KEY_UID)
                                let userData = ["provider": "emailLogin", "email": email]
                                DataService.ds.createFirebaseUser(user!.uid, user: userData)
                                
                                self.checkForUserName()
                            }
                        })
                        
                        //If the email exist but the password is wrong written
                    } else {
                      self.showErrorAlert("Could not login", msg: "Please check your username or password")
                    }
                    
                } else {
                    
                    self.checkForUserName()
                }
                
            })
            
            //when some of the fields hasn't been filled
        } else {
            showErrorAlert("Email and Password Required!", msg: "You must enter email and a password")
        }
    }
    
    func checkForUserName() {
        DataService.ds.REF_USER_CURRENT.child("username").observeSingleEvent(of: .value, with: { snapshot in
            
            if snapshot.value is NSNull {
            self.performSegue(withIdentifier: SEGUE_USERNAME, sender: nil)
            } else {
            self.performSegue(withIdentifier: SEGUE_LOGGED_IN, sender: nil)
            }
        })
    }
    
    //custom alert controller
    func showErrorAlert(_ title: String, msg: String){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
}

