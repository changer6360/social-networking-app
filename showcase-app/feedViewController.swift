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
    
    
    var imageSelected = false
    var posts = [Post]()
    static var imageCache = NSCache<NSString, AnyObject>()
    
    var imagePicker: UIImagePickerController!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = 400
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        
        
        DataService.ds.REF_POSTS.observe(.value, with: { snapshot in
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

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let post = posts[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as? PostCell {
            
            cell.request?.cancel()
            
            var img: UIImage?
            
            if let url = post.imageUrl {
                img = feedViewController.imageCache.object(forKey: url as NSString) as? UIImage
            }
            
            cell.configureCell(post: post, img: img)
            return cell
            } else {
            return PostCell()
            }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let post = posts[(indexPath as NSIndexPath).row]
        
        if post.imageUrl == nil {
            return 200
        } else {
            return tableView.estimatedRowHeight
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        imagePicker.dismiss(animated: true, completion: nil)
        selectedImageView.image = image
        imageSelected = true
    }
    
    @IBAction func selectImage(_ sender: UITapGestureRecognizer) {
        present(imagePicker, animated: true, completion: nil)
    }
    @IBAction func makePost(_ sender: AnyObject) {
        if let txt = postField.text , txt != "" {
            
            let cameraImage = UIImage(named: "camera")
            
            if let img = selectedImageView.image , img != cameraImage && imageSelected == true {
                let imgData = UIImageJPEGRepresentation(img, 0.2)!
                
                let imgPath = "\(Date.timeIntervalSinceReferenceDate)"
                
                let metadata = FIRStorageMetadata()
                metadata.contentType = "image/jpeg"
                
                DataService.ds.REF_IMAGES.child(imgPath).put(imgData, metadata: metadata, completion: { metadata, error in
                    
                    if error != nil {
                        print("Error uploading the image. Exact error \(error.debugDescription)")
                    } else {
                        if let meta = metadata {
                            if let imgLink = meta.downloadURL()?.absoluteString {
                                print("Image uploaded successfully. \(imgLink)")
                                self.postToFirebase(imgUrl: imgLink)
                        
                            }
                        }
                    }
                })
            } else {
                self.postToFirebase(imgUrl: nil)
            }
        }
    }
    
    func postToFirebase(imgUrl: String?) {
        var post: Dictionary<String, AnyObject> = [
            "description" : postField.text! as AnyObject,
            "likes": 0 as AnyObject
        ]
        
        if imgUrl != nil {
             post["imageURL"] = imgUrl! as AnyObject?
        }
            let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
            firebasePost.setValue(post)
        
        postField.text = ""
        selectedImageView.image = UIImage(named: "camera")
        imageSelected = false
        
        tableView.reloadData()
    }
    
}






