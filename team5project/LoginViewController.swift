//
//  LoginViewController.swift
//  team5project
//
//  Created by Nicole Estabrook on 10/14/22.
//

import UIKit
import FirebaseAuth
import CoreData

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var pwField: UITextField!
    @IBOutlet weak var signinButton: UIButton!
    @IBOutlet weak var signupLabel: UILabel!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var logoLabel: UILabel!
    
    var userBackgroundColor = UIColor.init(red: 245/255, green: 230/255, blue: 203/255, alpha: 1)
    var userTextColor = UIColor.init(red: 82/255, green: 67/255, blue: 40/255, alpha: 1)
    var userFont = UIFont.init(name: "Times New Roman", size: 17.0)

    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailField.delegate = self
        pwField.delegate = self
        pwField.isSecureTextEntry = true
        
        Auth.auth().addStateDidChangeListener() {
            auth, user in
            if user != nil {
                self.performSegue(withIdentifier: "LoginSegue", sender: nil)
                self.emailField.text = nil
                self.pwField.text = nil
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setTheme()
    }

    
    @IBAction func onSigninButtonPressed(_ sender: Any) {
        let userEmail = emailField.text
        let userPW = pwField.text
        
        Auth.auth().signIn(withEmail: userEmail!, password: userPW!) {
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
                print("Logged in")
            }
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
        signupLabel.textColor = userTextColor
        signupLabel.font = userFont
        signinButton.tintColor = userTextColor
        signinButton.backgroundColor = .clear
        signinButton.layer.cornerRadius = 5
        signinButton.layer.borderWidth = 1
        signinButton.layer.borderColor = UIColor.black.cgColor
        signinButton.titleLabel?.font = userFont
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
