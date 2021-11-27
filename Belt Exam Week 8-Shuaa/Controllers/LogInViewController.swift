//
//  LogInViewController.swift
//  Belt Exam Week 8-Shuaa
//
//  Created by administrator on 11/11/2021.
//

import UIKit
import JGProgressHUD

class LogInViewController: UIViewController {
    //Variables
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var emailTxtField: UITextField!
    
    @IBOutlet weak var passWordTxtField: UITextField!
    private let spinner = JGProgressHUD(style: .dark)

    override func viewDidLoad() {
        super.viewDidLoad()
        //change borde of buttons

        loginButton.layer.cornerRadius = 6
        loginButton.layer.borderWidth = 2
      loginButton.layer.borderColor = UIColor.black.cgColor
       signUpButton.layer.cornerRadius = 6
        signUpButton.layer.borderWidth = 2
      signUpButton.layer.borderColor = UIColor.black.cgColor
        // Do any additional setup after loading the view.
    }
   
  

    // log in section
    @IBAction func loginButton(_ sender: Any) {
        spinner.show(in: view)
        let loginManager = FirebaseAuthManager()
            guard let email = emailTxtField.text, let password = passWordTxtField.text else { return }
            loginManager.signin(email: email, pass: password) {[weak self] (success) in
                guard let `self` = self else { return }
                DispatchQueue.main.async {
                    self.spinner.dismiss()
                }
                var message: String = ""
                if (success) {
                   print(" sucessfully logged in.")
                  
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let vc = storyboard.instantiateViewController(withIdentifier: "GroceryListTableVC")
               
                    (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(vc)

                } else {
                    message = "Incorrect email or password. Try again"
                    let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Done", style: .cancel, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                    self.passWordTxtField.text = nil
                }
               
            }
    }
    // log up section
    @IBAction func registerButton(_ sender: Any) {
        spinner.show(in: view)

        let signUpManager = FirebaseAuthManager()
            if let email = emailTxtField.text, let password = passWordTxtField.text {
                signUpManager.createUser(email: email, password: password) {[weak self] (success) in
                    guard let `self` = self else { return }
                    self.spinner.dismiss()

                    if (success) {
                       print(" sucessfully create user")
                          let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                  let vc = storyboard.instantiateViewController(withIdentifier: "GroceryListTableVC")
                     
                          (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(vc)
                    } else {
                        var message: String = ""
                        message = "Something went wrong. User Register failed."
                       // that means the email exists already!
                        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "Done", style: .cancel, handler: nil))
                        self.present(alertController, animated: true, completion: nil)
                        self.passWordTxtField.text = nil
                    }
              
                }
            }
    }
    
    

}
