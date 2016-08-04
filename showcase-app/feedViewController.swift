//
//  feedViewController.swift
//  showcase-app
//
//  Created by Tihomir Videnov on 7/14/16.
//  Copyright © 2016 Tihomir Videnov. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class feedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var postField: MaterialTextField!
    @IBOutlet weak var selectedImageView: UIImageView!
    
    
    var imageSelected = true
    var posts = [Post]()
    static var imageCache = NSCache()
    
    var imagePicker: UIImagePickerController!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = 400
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        
        
        DataService.ds.REF_POSTS.observeEventType(.Value, withBlock: { snapshot in
            self.tableView.reloadData()
            
            self.posts = []
            
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshots {
                    
                    if let postDict = snap.value as? Dictionary<String,AnyObject> {
                        let key = snap.key
                        let post = Post(postKey: key, dictionary: postDict)
                        self.posts.append(post)
                    }
                }
            }
            self.tableView.reloadData()
            
        })
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        let post = posts[indexPath.row]
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as? PostCell {
            
            cell.request?.cancel()
            
            var img: UIImage?
            
            if let url = post.imageUrl {
                img = feedViewController.imageCache.objectForKey(url) as? UIImage
            }
            
            cell.configureCell(post, img: img)
            return cell
            } else {
            return PostCell()
            }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let post = posts[indexPath.row]
        
        if post.imageUrl == nil {
            return 200
        } else {
            return tableView.estimatedRowHeight
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        selectedImageView.image = image
        imageSelected = true
    }
    
    @IBAction func selectImage(sender: UITapGestureRecognizer) {
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    @IBAction func makePost(sender: AnyObject) {
        if let txt = postField.text where txt != "" {
            
            let cameraImage = UIImage(named: "camera")
            
            if let img = selectedImageView.image where img != cameraImage && imageSelected == true {
                let imgData = UIImageJPEGRepresentation(img, 0.2)!
                
                let imgPath = "\(NSDate.timeIntervalSinceReferenceDate())"
                
                let metadata = FIRStorageMetadata()
                metadata.contentType = "image/jpeg"
                
                DataService.ds.REF_IMAGES.child(imgPath).putData(imgData, metadata: metadata, completion: { metadata, error in
                    
                    if error != nil {
                        print("Error uploading the image. Exact error \(error.debugDescription)")
                    } else {
                        if let meta = metadata {
                            if let imgLink = meta.downloadURL()?.absoluteString {
                                print("Image uploaded successfully. \(imgLink)")
                                self.postToFirebase(imgLink)
                        
                            }
                        }
                    }
                })
            } else {
                self.postToFirebase(nil)
            }
        }
    }
    
    func postToFirebase(imgUrl: String?) {
        var post: Dictionary<String, AnyObject> = [
            "description" : postField.text!,
            "likes": 0
        ]
        
        if imgUrl != nil {
             post["imageURL"] = imgUrl!
        }
            let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
            firebasePost.setValue(post)
        
        postField.text = ""
        selectedImageView.image = UIImage(named: "camera")
        imageSelected = false
        
        tableView.reloadData()
    }
    
}






