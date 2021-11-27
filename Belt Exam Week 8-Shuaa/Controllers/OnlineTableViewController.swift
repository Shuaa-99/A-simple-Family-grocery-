//
//  OnlineTableViewController.swift
//  Belt Exam Week 8-Shuaa
//
//  Created by administrator on 11/11/2021.
//

import UIKit
import Firebase
import FirebaseAuth
class OnlineTableViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tableview: UITableView!
    let userCell = "myCell"
    var currentUsers: [String] = []
    let usersRef = Database.database().reference(withPath: "online")
    var usersRefObservers: [DatabaseHandle] = []
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidDisappear(_ animated: Bool) {
      super.viewDidDisappear(true)
      usersRefObservers.forEach(usersRef.removeObserver(withHandle:))
      usersRefObservers = []
    }
    @IBAction func goToGrosery(_ sender: Any) {
        // go back to Grosery view
        dismiss(animated: true, completion: nil)

    }
    @IBAction func LogOutPress(_ sender: Any) {
        guard let user = Auth.auth().currentUser else { return }

          let onlineRef = Database.database().reference(withPath: "online/\(user.uid)")
          onlineRef.removeValue { error, _ in
            if let error = error {
              print("log out from real time failed: \(error)")
              return
            }
            do {
              try Auth.auth().signOut()
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let vc = storyboard.instantiateViewController(withIdentifier: "LogInViewController")
           
                (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(vc)
            } catch let error {
              print(" sign out failed: \(error)")
            }
          }

    }
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(true)

      let childAdded = usersRef
        .observe(.childAdded) { [weak self] snap in
          guard
            let email = snap.value as? String,
            let self = self
          else { return }
          self.currentUsers.append(email)
          let row = self.currentUsers.count - 1
          let indexPath = IndexPath(row: row, section: 0)
          self.tableview.insertRows(at: [indexPath], with: .top)
        }
      usersRefObservers.append(childAdded)

      let childRemoved = usersRef
        .observe(.childRemoved) {[weak self] snap in
          guard
            let emailToFind = snap.value as? String,
            let self = self
          else { return }

          for (index, email) in self.currentUsers.enumerated()
          where email == emailToFind {
            let indexPath = IndexPath(row: index, section: 0)
            self.currentUsers.remove(at: index)
            self.tableview.deleteRows(at: [indexPath], with: .fade)
          }
     }
     usersRefObservers.append(childRemoved)
    }
    
    // MARK: - Table view data source

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return currentUsers.count
    }

     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: userCell, for: indexPath)
      let onlineEmail = currentUsers[indexPath.row]
      cell.textLabel?.text = onlineEmail
      return cell
    }
  

}
