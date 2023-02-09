//
//  MainViewController.swift
//  team5project
//
//  Created by Nicole Estabrook on 10/15/22.
//

import UIKit
import FirebaseAuth
import CoreData

class MainViewController: UIViewController {

        
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var taskButton: UIButton!
    @IBOutlet weak var addNewButton: UIButton!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var tigerText: UILabel!
    var userName = ""
    var userFreq = 14
    var userDuration = 20
    var userTheme = 2
    var hapticsStatus = true
    
    var userBackgroundColor = UIColor.init(red: 245/255, green: 230/255, blue: 203/255, alpha: 1)
    var userTextColor = UIColor.init(red: 82/255, green: 67/255, blue: 40/255, alpha: 1)
    var userBarColor = UIColor.init(red: 82/255, green: 67/255, blue: 40/255, alpha: 1)
    var userFont = UIFont.init(name: "Times New Roman", size: 17.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) {
            granted, error in
            if granted {
                print("All set")
            }
            else if let error = error {
                print(error.localizedDescription)
            }
        }
        
        if defaults.object(forKey: "Name") == nil {
            defaults.set(userName, forKey:"Name")
        }
        if defaults.object(forKey: "Default Frequency") == nil {
            defaults.set(userFreq, forKey: "Default Frequency")
        }
        if defaults.object(forKey: "Default Duration") == nil {
            defaults.set(userDuration, forKey: "Default Duration")
        }
        if defaults.object(forKey: "Default Theme") == nil {
            defaults.set(userTheme, forKey: "Default Theme")
        }
        if defaults.object(forKey: "Default Haptics") == nil {
            defaults.set(hapticsStatus, forKey: "Default Haptics")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        setTheme()
    }

    @IBAction func onLogoutButtonPressed(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            self.dismiss(animated: true)
        } catch {
            print("Sign out error")
        }
    }

    
    func setTheme() {
        let themeChoice = defaults.integer(forKey: "Default Theme")
        
        if themeChoice == 0 {
            userBackgroundColor = UIColor.init(red: 11/255, green: 223/255, blue: 227/255, alpha: 1)
            userTextColor = UIColor.init(red: 135/255, green: 13/255, blue: 4/255, alpha: 1)
            userBarColor = UIColor.init(red: 135/255, green: 13/255, blue: 4/255, alpha: 1)
            userFont = UIFont.init(name: "Chalkboard SE", size: 17.0)
        }
        else if themeChoice == 1 {
            userBackgroundColor = UIColor.init(red: 201/255, green: 254/255, blue: 255/255, alpha: 1)
            userTextColor = UIColor.init(red: 72/255, green: 0/255, blue: 255/255, alpha: 1)
            userBarColor = UIColor.init(red: 72/255, green: 0/255, blue: 255/255, alpha: 1)
            userFont = UIFont.init(name: "Arial", size: 17.0)
        }
        else if themeChoice == 2 {
            userBackgroundColor = UIColor.init(red: 245/255, green: 230/255, blue: 203/255, alpha: 1)
            userTextColor = UIColor.init(red: 82/255, green: 67/255, blue: 40/255, alpha: 1)
            userBarColor = UIColor.init(red: 82/255, green: 67/255, blue: 40/255, alpha: 1)
            userFont = UIFont.init(name: "Times New Roman", size: 17.0)
        }
        else if themeChoice == 3 {
            userBackgroundColor = UIColor.init(red: 9/255, green: 48/255, blue: 122/255, alpha: 1)
            userTextColor = UIColor.init(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
            userBarColor = UIColor.init(red: 9/255, green: 48/255, blue: 122/255, alpha: 1)
            userFont = UIFont.init(name: "Futura", size: 17.0)
        }
        
        self.view.backgroundColor = userBackgroundColor
        toolbar.barTintColor = userBackgroundColor
        logoutButton.tintColor = userTextColor
        infoButton.tintColor = userTextColor
        settingsButton.tintColor = userBarColor
        taskButton.tintColor = userBarColor
        addNewButton.tintColor = userBarColor
        tigerText.font = userFont
        tigerText.textColor = userTextColor
        logoutButton.tintColor = userTextColor
        logoutButton.titleLabel?.font = userFont
        infoButton.titleLabel?.font = userFont
    }
    

}
