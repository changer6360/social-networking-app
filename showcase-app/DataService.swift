//
//  DataService.swift
//  showcase-app
//
//  Created by Tihomir Videnov on 7/11/16.
//  Copyright © 2016 Tihomir Videnov. All rights reserved.
//

import Foundation
import Firebase

let URL_BASE = FIRDatabase.database().reference()
let URL_STORAGE = FIRStorage.storage().reference()

class DataService {
    
    static let ds = DataService()
    
    private var _REF_BASE = URL_BASE
    private var _REF_POSTS = URL_BASE.child("posts")
    private var _REF_USERS = URL_BASE.child("users")
    private var _REF_IMAGES = URL_STORAGE.child("images")

    
    
    var REF_BASE: FIRDatabaseReference {
        return _REF_BASE
    }
    
    var REF_POSTS: FIRDatabaseReference {
        return _REF_POSTS
    }
    
    var REF_USERS: FIRDatabaseReference {
        return _REF_USERS
    }
    
    var REF_IMAGES: FIRStorageReference {
        return _REF_IMAGES
    }
    
    var REF_USER_CURRENT: FIRDatabaseReference {
        let uid = UserDefaults.standard.value(forKey: KEY_UID) as! String
        let user = URL_BASE.child("users").child(uid)
        return user
    }
    
    func createFirebaseUser(_ uid: String,user: Dictionary<String,String>) {
        REF_USERS.child(uid).updateChildValues(user)
    }

}
