//
//  ViewController.swift
//  Belt Exam Week 8-Shuaa
//
//  Created by administrator on 11/11/2021.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
class GroceryListTableVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    let listToUsers = "ListToUsers"
    let ref = Database.database().reference(withPath: "grocery-items")
    var refObservers: [DatabaseHandle] = []
    let usersRef = Database.database().reference(withPath: "online")
    var usersRefObservers: [DatabaseHandle] = []

    // Properties
    var items: [GroceryItem] = []
    var user: User?
   
    @IBOutlet weak var tableview: UITableView!
    var handle: AuthStateDidChangeListenerHandle?
    private func validateAuth(){
                   // current user is set automatically when you log a user in
               if Auth.auth().currentUser == nil {
                   // present login view controller if user not logged in
                   let vc = storyboard?.instantiateViewController(withIdentifier: "LogInViewController") as! LogInViewController
                   
                   let nav = UINavigationController(rootViewController: vc)
                   nav.modalPresentationStyle = .fullScreen
                   present(nav, animated: false)
               }
               }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.delegate = self
        tableview.dataSource = self
        navigationItem.hidesBackButton = true

        tableview.allowsMultipleSelectionDuringEditing = false
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
          super.viewDidAppear(animated)
         
          validateAuth()
      }
    @IBAction func addItemPress(_ sender: Any) {
        let alert = UIAlertController(
          title: "Grocery Item",
          message: "Add an Item",
          preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
          guard
            let firstTxtField = alert.textFields?.first,
            var txt = firstTxtField.text,
            let user = self.user
           
                
          else { return }
            var saveTxt = txt.replacingOccurrences(of: ".", with: "-")
            print("without dot\(saveTxt)")
                  saveTxt = saveTxt.replacingOccurrences(of: ",", with: "-")
                  saveTxt = saveTxt.replacingOccurrences(of: "[", with: "-")
                  saveTxt = saveTxt.replacingOccurrences(of: "]", with: "-")
                  saveTxt = saveTxt.replacingOccurrences(of: "#", with: "-")
                  saveTxt = saveTxt.replacingOccurrences(of: "$", with: "-")
            saveTxt = saveTxt.replacingOccurrences(of: " ", with: "-")
           


          let ItemGrocery = GroceryItem(
           // print("without dotlast\(saveTxt)")
            name: saveTxt,
            addedByUser: user.email,
            completed: false)
            let groceryItemRef = self.ref.child(saveTxt.lowercased())
            
          groceryItemRef.setValue(ItemGrocery.convertToAny())
        }
        let cancelAction = UIAlertAction(
          title: "Cancel",
          style: .cancel)

        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let completed = ref
          .queryOrdered(byChild: "completed")
          .observe(.value) { snapshot in
            var newItems: [GroceryItem] = []
            for child in snapshot.children {
              if
                let snapshot = child as? DataSnapshot,
                let groceryItem = GroceryItem(snapshot: snapshot) {
                newItems.append(groceryItem)
              }
            }
            self.items = newItems
            self.tableview.reloadData()
          }
        refObservers.append(completed)

        handle = Auth.auth().addStateDidChangeListener { _, user in
          guard let user = user else { return }
          self.user = User(authData: user)

          let currentUserRef = self.usersRef.child(user.uid)
          currentUserRef.setValue(user.email)
          currentUserRef.onDisconnectRemoveValue()
        }

    }
 
          
    override func viewDidDisappear(_ animated: Bool) {
      super.viewDidDisappear(true)
      refObservers.forEach(ref.removeObserver(withHandle:))
      refObservers = []
      usersRefObservers.forEach(usersRef.removeObserver(withHandle:))
      usersRefObservers = []
      guard let handle = handle else { return }
      Auth.auth().removeStateDidChangeListener(handle)
    }
    
    // MARK: - Table view data source

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return items.count
    }

     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
      let groceryItem = items[indexPath.row]

      cell.textLabel?.text = groceryItem.name
      cell.detailTextLabel?.text = groceryItem.addedByUser

      cellCheckPress(cell, isCompleted: groceryItem.completed)

      return cell
    }

     func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
      return true
    }
     func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
         // delete item from table view and Realtime Database

      if editingStyle == .delete {
          //
          let alert = UIAlertController(
            title: nil, message: "Are you sure you want delete item ?",
            preferredStyle: .alert)
          let saveAction = UIAlertAction(title: "yes", style: .default) { _ in
                let groceryItem = self.items[indexPath.row]
                groceryItem.ref?.removeValue()
          }
          let cancelAction = UIAlertAction(
            title: "No",
            style: .cancel)

          alert.addAction(saveAction)
          alert.addAction(cancelAction)

          present(alert, animated: true, completion: nil)
      }
      }
      
    
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      guard let cell = tableView.cellForRow(at: indexPath) else { return }
      let groceryItem = items[indexPath.row]
      let cellChecked = !groceryItem.completed
      cellCheckPress(cell, isCompleted: cellChecked)
      groceryItem.ref?.updateChildValues(["completed": cellChecked])
    }

    func cellCheckPress(_ cell: UITableViewCell, isCompleted: Bool) {
      if !isCompleted {
        cell.accessoryType = .none
      } else {
        cell.accessoryType = .checkmark
      }
    }
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let edit = UIContextualAction(style: .normal, title: "Edit") { (contextualAction, view, actionPerformed: (Bool) -> ()) in
            
            //alert action to Edit to table view
            let Editalert = UIAlertController(
                title: "Grocery Item",
                message: "Edit Item",
                preferredStyle: .alert)
            
            //save button
            let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
                guard
                    let textField = Editalert.textFields?.first,
                    let text = textField.text,
                    let user = self.user
                else { return }
                
                //deleting the before editing name
                let oldGroceryItem = self.items[indexPath.row]
                oldGroceryItem.ref?.removeValue()
                var saveTxt = text.replacingOccurrences(of: ".", with: "-")
                print("without dot\(saveTxt)")
                      saveTxt = saveTxt.replacingOccurrences(of: ",", with: "-")
                      saveTxt = saveTxt.replacingOccurrences(of: "[", with: "-")
                      saveTxt = saveTxt.replacingOccurrences(of: "]", with: "-")
                      saveTxt = saveTxt.replacingOccurrences(of: "#", with: "-")
                      saveTxt = saveTxt.replacingOccurrences(of: "$", with: "-")
                saveTxt = saveTxt.replacingOccurrences(of: " ", with: "-")
                //Edit item details to database
                let groceryItem = GroceryItem(
                    name: text,
                    addedByUser: user.email,
                    completed: false)
                
                
                let groceryItemRef = self.ref.child(saveTxt.lowercased())
                groceryItemRef.setValue(groceryItem.convertToAny())
                
                
            }
            //cancel button
            let cancelAction = UIAlertAction(
                title: "Cancel",
                style: .cancel)
            
            Editalert.addTextField()
            Editalert.addAction(saveAction)
            Editalert.addAction(cancelAction)
            
            self.present(Editalert, animated: true, completion: nil)
            
        }
        
        //edit button color
        edit.backgroundColor = .gray
        
        return UISwipeActionsConfiguration(actions: [edit])
    }
    

}


