//
//  SettingsViewController.swift
//  team5project
//
//  Created by Nicole Estabrook on 11/27/22.
//

import UIKit
import CoreData

let defaults = UserDefaults.standard

class SettingsViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var themeCtrl: UISegmentedControl!
    @IBOutlet weak var freqField: UITextField!
    @IBOutlet weak var durationField: UITextField!
    @IBOutlet weak var hapticsToggle: UISwitch!
    @IBOutlet weak var doneButton: UIButton!
    
    
    
    var userName = ""
    var userFreq = 14
    var userDuration = 20
    var userTheme = 2
    var userBackgroundColor = UIColor.init(red: 245/255, green: 230/255, blue: 203/255, alpha: 1)
    var userTextColor = UIColor.init(red: 82/255, green: 67/255, blue: 40/255, alpha: 1)
    var userBarColor = UIColor.init(red: 82/255, green: 67/255, blue: 40/255, alpha: 1)
    var userFont = UIFont.init(name: "Times New Roman", size: 17.0)
    
    let modes = ["Bright", "Calm", "Neutral", "Dark"]
    
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var label4: UILabel!
    
    var hapticsStatus = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        else {
            themeCtrl.selectedSegmentIndex = defaults.integer(forKey: "Default Theme")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setColorTheme()
        userName = defaults.string(forKey: "Name")!
        userFreq = defaults.integer(forKey: "Default Frequency")
        userDuration = defaults.integer(forKey: "Default Duration")
        nameField.text = userName
        freqField.text = "\(userFreq)"
        durationField.text = "\(userDuration)"
        hapticsStatus = defaults.bool(forKey: "Default Haptics")
        hapticsToggle.setOn(hapticsStatus, animated: false)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return modes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return modes[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        userTheme = row
    }
    
    @IBAction func onDoneButtonPressed(_ sender: Any) {
        let nametext = nameField.text!
        if nametext != "" {
            if let durationtext = durationField.text,!durationtext.isEmpty {
                let durationInt = changeToInt(num: durationtext)
                if let freqtext = freqField.text,!freqtext.isEmpty {
                    var freqDouble = changeToInt(num: freqtext)
                    if freqDouble != -999 {
                        if durationInt != -999 {
                            userName = nameField.text!
                            userFreq = freqDouble
                            userDuration = durationInt
                            hapticsStatus = hapticsToggle.isOn
                            defaults.set(userName, forKey:"Name")
                            defaults.set(userFreq, forKey: "Default Frequency")
                            defaults.set(userDuration, forKey: "Default Duration")
                            defaults.set(hapticsStatus, forKey: "Default Haptics")
                            defaults.set(userTheme, forKey: "Default Theme")

                            let controller = UIAlertController(
                                title: "Settings Status",
                                message: "Your settings have been saved.",
                                preferredStyle: .alert)
                            let doneButton = UIAlertAction(
                                title: "Done",
                                style: .cancel,
                                handler: { action in self.navigationController?.popViewController(animated: true) })
                            controller.addAction(doneButton)
                            present(controller, animated: true)
                        } else {
                            let controller = UIAlertController(
                                title: "Invalid Input",
                                message: "Please enter a valid integer instead of \(durationtext) for the duration.",
                                preferredStyle: .alert)
                            let okButton = UIAlertAction(
                                title: "OK",
                                style: .default)
                            controller.addAction(okButton)
                            present(controller, animated: true)
                        }
                    } else {
                        let controller = UIAlertController(
                            title: "Invalid Input",
                            message: "Please enter a valid integer instead of \(freqtext) for the frequency.",
                            preferredStyle: .alert)
                        let okButton = UIAlertAction(
                            title: "OK",
                            style: .default)
                        controller.addAction(okButton)
                        present(controller, animated: true)
                    }
                } else {
                        let controller = UIAlertController(
                            title: "Missing Frequency",
                            message: "Please enter a valid frequency as an integer.",
                            preferredStyle: .alert)
                        let okButton = UIAlertAction(
                            title: "OK",
                            style: .default)
                        controller.addAction(okButton)
                        present(controller, animated: true)
                }
            } else {
                let controller = UIAlertController(
                    title: "Missing Duration",
                    message: "Please enter a valid duration in minutes.",
                    preferredStyle: .alert)
                let okButton = UIAlertAction(
                    title: "OK",
                    style: .default)
                controller.addAction(okButton)
                present(controller, animated: true)
            }
        } else {
            let controller = UIAlertController(
                title: "Missing Username",
                message: "Please enter a valid username.",
                preferredStyle: .alert)
            let okButton = UIAlertAction(
                title: "OK",
                style: .default)
            controller.addAction(okButton)
            present(controller, animated: true)
        }
    }
    
    func changeToInt(num:String) -> Int{
        if let converted = Int (num) {
            return converted
        } else {
            return -999
        }
    }
    
    func textFieldShouldReturn(_ textField:UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func onColorThemeChanged() {
        switch themeCtrl.selectedSegmentIndex {
        case 0:
            userTheme = 0
            previewColorTheme()
        case 1:
            userTheme = 1
            previewColorTheme()
        case 2:
            userTheme = 2
            previewColorTheme()
        case 3:
            userTheme = 3
            previewColorTheme()
        default:
            print("Error picking color theme")
        }
    }

    func previewColorTheme () {
        let themeChoice = userTheme
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
        doneButton.backgroundColor = .clear
        doneButton.layer.cornerRadius = 5
        doneButton.layer.borderWidth = 1
        doneButton.layer.borderColor = UIColor.black.cgColor
        doneButton.tintColor = userTextColor
        doneButton.titleLabel?.font = userFont
        label1.textColor = userTextColor
        label1.font = userFont
        label2.textColor = userTextColor
        label2.font = userFont
        label3.textColor = userTextColor
        label3.font = userFont
        label4.textColor = userTextColor
        label4.font = userFont
        themeCtrl.tintColor = userBackgroundColor
        themeCtrl.selectedSegmentTintColor = userBackgroundColor
        themeCtrl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: userTextColor], for: UIControl.State.selected)
        themeCtrl.setTitleTextAttributes([NSAttributedString.Key.font: userFont], for: .normal)
        themeCtrl.setTitleTextAttributes([.foregroundColor: userTextColor], for: .normal)
    }
    
    func setColorTheme () {
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
        doneButton.backgroundColor = .clear
        doneButton.layer.cornerRadius = 5
        doneButton.layer.borderWidth = 1
        doneButton.layer.borderColor = UIColor.black.cgColor
        doneButton.tintColor = userTextColor
        doneButton.titleLabel?.font = userFont
        label1.textColor = userTextColor
        label1.font = userFont
        label2.textColor = userTextColor
        label2.font = userFont
        label3.textColor = userTextColor
        label3.font = userFont
        label4.textColor = userTextColor
        label4.font = userFont
        themeCtrl.tintColor = userBackgroundColor
        themeCtrl.selectedSegmentTintColor = userBackgroundColor
        themeCtrl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: userTextColor], for: UIControl.State.selected)
        themeCtrl.setTitleTextAttributes([NSAttributedString.Key.font: userFont], for: .normal)
        themeCtrl.setTitleTextAttributes([.foregroundColor: userTextColor], for: .normal)
    }
}
