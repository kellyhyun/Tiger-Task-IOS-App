//
//  SignupViewController.swift
//  team5project
//
//  Created by Nicole Estabrook on 11/1/22.
//

import UIKit
import FirebaseAuth
import CoreData

class SignupViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var pwField: UITextField!
    @IBOutlet weak var confirmField: UITextField!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var logoLabel: UILabel!
    
    var userBackgroundColor = UIColor.init(red: 245/255, green: 230/255, blue: 203/255, alpha: 1)
    var userTextColor = UIColor.init(red: 82/255, green: 67/255, blue: 40/255, alpha: 1)
    var userFont = UIFont.init(name: "Times New Roman", size: 17.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailField.delegate = self
        pwField.delegate = self
        confirmField.delegate = self
        pwField.isSecureTextEntry = true
        confirmField.isSecureTextEntry = true
 
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        setTheme()
    }

    
    @IBAction func onSignupButtonPressed(_ sender: Any) {
        let userEmail = emailField.text
        let userPW = pwField.text
        let userConfirm = confirmField.text
        if userPW == userConfirm {
            Auth.auth().createUser(withEmail: userEmail!, password: userPW!) {
                authResult, error in
                if let error = error as NSError? {
                    let controller = UIAlertController(
                        title: "Login Error",
                        message: "\(error.localizedDescription)",
                        preferredStyle: .alert)
                    let okButton = UIAlertAction(
                        title: "OK",
                        style: .default)
                    controller.addAction(okButton)
                    self.present(controller, animated: true)
                } else {
                    print("Signed up")
                    self.navigationController?.popViewController(animated: true)
                }
            }
//            Auth.auth().signIn(withEmail: userEmail!, password: userPW!) {
//                authResult, error in
//                if let error = error as NSError? {
//                    print("\(error.localizedDescription)")
//                } else {
//                    print("Logged in")
//                }
//            }
        } else {
            let pwError = UIAlertController(
                title: "Sign up error",
                message: "Passwords do not match",
                preferredStyle: .alert)
            pwError.addAction(UIAlertAction(title: "OK", style: .default))
            present(pwError, animated: true)
        }
    }
    
    func textFieldShouldReturn(_ textField:UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    
    func setTheme() {
        let themeChoice = defaults.integer(forKey: "Default Theme")
        
        if themeChoice == 0 {
            userBackgroundColor = UIColor.init(red: 11/255, green: 223/255, blue: 227/255, alpha: 1)
            userTextColor = UIColor.init(red: 135/255, green: 13/255, blue: 4/255, alpha: 1)
            userFont = UIFont.init(name: "Chalkboard SE", size: 17.0)
        }
        else if themeChoice == 1 {
            userBackgroundColor = UIColor.init(red: 201/255, green: 254/255, blue: 255/255, alpha: 1)
            userTextColor = UIColor.init(red: 72/255, green: 0/255, blue: 255/255, alpha: 1)
            userFont = UIFont.init(name: "Arial", size: 17.0)
        }
        else if themeChoice == 2 {
            userBackgroundColor = UIColor.init(red: 245/255, green: 230/255, blue: 203/255, alpha: 1)
            userTextColor = UIColor.init(red: 82/255, green: 67/255, blue: 40/255, alpha: 1)
            userFont = UIFont.init(name: "Times New Roman", size: 17.0)
        }
        else if themeChoice == 3 {
            userBackgroundColor = UIColor.init(red: 9/255, green: 48/255, blue: 122/255, alpha: 1)
            userTextColor = UIColor.init(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
            userFont = UIFont.init(name: "Futura", size: 17.0)
        }
        
        self.view.backgroundColor = userBackgroundColor
        signupButton.tintColor = userTextColor
        signupButton.backgroundColor = .clear
        signupButton.layer.cornerRadius = 5
        signupButton.layer.borderWidth = 1
        signupButton.layer.borderColor = UIColor.black.cgColor
        signupButton.titleLabel?.font = userFont
        logoLabel.font = userFont
        logoLabel.textColor = userTextColor
    }
    
}
