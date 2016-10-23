//
//  usernameViewController.swift
//  showcase-app
//
//  Created by Tihomir Videnov on 7/22/16.
//  Copyright © 2016 Tihomir Videnov. All rights reserved.
//

import UIKit
import Firebase
import Alamofire
import FirebaseStorage

class usernameViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var userNameText: MaterialTextField!
    @IBOutlet weak var profileImg: UIImageView!
    
    var userName = ""
    var currentUser: FIRDatabaseReference!
    var userRef: FIRDatabaseReference!
    var imgRef: FIRDatabaseReference!
    var imageUrl = ""
    var request: Request?
    var imagePicker: UIImagePickerController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //configuring the tap recognizer which invokes image picker controller
        let tap = UITapGestureRecognizer(target: self, action: #selector(usernameViewController.imageTapped(_:)))
        tap.numberOfTapsRequired = 1
        profileImg.addGestureRecognizer(tap)
        profileImg.isUserInteractionEnabled = true
        
        
        profileImg.layer.cornerRadius = profileImg.frame.size.width / 2
        profileImg.clipsToBounds = true
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        userRef = DataService.ds.REF_USERS
        currentUser = DataService.ds.REF_USER_CURRENT.child("username")
        imgRef = DataService.ds.REF_USER_CURRENT.child("profileImage")
        
        
        imgRef.observeSingleEvent(of: .value, with: { snapshot in
            
            if snapshot.value is NSNull {
                print("Snapshot value is nsnull: \(snapshot.value)")
                self.profileImg.image = UIImage(named: "profileImage")
            } else {
                
                if let profImg = snapshot.value {
                    self.imageUrl = profImg as! String
                    print("Test: \(self.imageUrl)")
                }
                
                self.request = Alamofire.request(self.imageUrl).response { response in
                    
                    if response.error == nil {
                        let img = UIImage(data: response.data!)
                        self.profileImg.image = img
                    }
                
                }
            }
        })
            
        }
        

    @IBAction func userNameSubmit(_ sender: AnyObject) {
        
        //check if there is anything typed
        if userNameText.text != "" {
            userName = userNameText.text!
            
            //check if the choosen username is already taken
            userRef.queryOrdered(byChild: "username").queryEqual(toValue: "\(userName)").observeSingleEvent(of: .value, with: { snapshot in
            
            if snapshot.value is NSNull {
                //if not exist - save it for the user
                
                self.currentUser.setValue("\(self.userName)")
                self.performSegue(withIdentifier: SEGUE_FEED, sender: nil)
                
            } else {
                //if exist - show error message
                //print(snapshot.value)
                
                self.showErrorAlert("Username already taken", msg: "Please choose another username")
            }
         
            
        })

           //when there no input found
        } else {
            showErrorAlert("Please type a valid username", msg: "There was an error while validating your username")
        }
    }
    
    //custom alert controller
    func showErrorAlert(_ title: String, msg: String){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        imagePicker.dismiss(animated: true, completion: nil)
        profileImg.image = image
        
        let imgData = UIImageJPEGRepresentation(image, 0.2)!
        let imgPath = "\(Date.timeIntervalSinceReferenceDate)"
        
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/jpeg"
        
        DataService.ds.REF_IMAGES.child(imgPath).put(imgData, metadata: metadata, completion: { metadata, error in
            
            if error != nil {
                self.showErrorAlert("Error", msg: "There was an error while uploading your image")
            } else {
                
                if let meta = metadata {
                    if let imgLink = meta.downloadURL()?.absoluteString {
                        self.imgRef.setValue("\(imgLink)")
                    }
                }
                
            }
        })
        
    }
    
    func imageTapped(_ sender: UITapGestureRecognizer) {
        present(imagePicker, animated: true, completion: nil)
    }
  
}
