//
//  DataManager.swift
//  Belt Exam Week 8-Shuaa
//
//  Created by administrator on 11/11/2021.
//

import Foundation
import Firebase
class FirebaseAuthManager {
  
    // Insert new user to database
    func createUser(email: String, password: String, completionBlock: @escaping (_ success: Bool) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) {(authResult, error) in
            if let user = authResult?.user {
                print(user)
                completionBlock(true)
            } else {
                completionBlock(false)
            }
        }
    }

func signin(email: String, pass: String, completionBlock: @escaping (_ success: Bool) -> Void) {
    Auth.auth().signIn(withEmail: email, password: pass) { (result, error) in
        if let error = error, let _ = AuthErrorCode(rawValue: error._code) {
            completionBlock(false)
        } else {
            completionBlock(true)
        }
    }
}
}
// Firebase (Root)
/*{
  // grocery-list-items
  "grocery-list-items": {
    // grocery-list-items/bread
    "bread": {
      // grocery-list-items/bread/name
      "name": "bread",
      // grocery-list-items/bread/addedByUser
      "addedByUser": "James"
    },
    "banana": {
      "name": "banana",
      "addedByUser": "Matthew"
    },
  }
}*/
struct GroceryItem {
  let ref: DatabaseReference?
  let key: String
  let name: String
  let addedByUser: String
  var completed: Bool

  init(name: String, addedByUser: String, completed: Bool, key: String = "") {
    self.ref = nil
    self.key = key
    self.name = name
    self.addedByUser = addedByUser
    self.completed = completed
  }

  init?(snapshot: DataSnapshot) {
    guard
      let value = snapshot.value as? [String: AnyObject],
      let name = value["name"] as? String,
      let addedByUser = value["addedByUser"] as? String,
      let completed = value["completed"] as? Bool
    else {
      return nil
    }

    self.ref = snapshot.ref
    self.key = snapshot.key
    self.name = name
    self.addedByUser = addedByUser
    self.completed = completed
  }

  func convertToAny() -> Any {
    return [
      "name": name,
      "addedByUser": addedByUser,
      "completed": completed
    ]
  }
  
   
}

struct User {
  let uid: String
  let email: String

  init(authData: Firebase.User) {
    uid = authData.uid
    email = authData.email ?? ""
  }

  init(uid: String, email: String) {
    self.uid = uid
    self.email = email
  }
}
