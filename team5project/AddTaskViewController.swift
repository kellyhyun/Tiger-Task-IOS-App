//
//  AddTaskViewController.swift
//  team5project
//
//  Created by Nicole Estabrook on 10/15/22.
//
 
import UIKit
import CoreData
 
class AddTaskViewController: UIViewController, UITextFieldDelegate {
 
    @IBOutlet weak var taskTitle: UITextField!
    @IBOutlet weak var recurringToggle: UISwitch!
    @IBOutlet weak var recurLabel: UILabel!
    @IBOutlet weak var timedLabel: UILabel!
    @IBOutlet weak var recurring: UILabel!
    @IBOutlet weak var timed: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var freqDateTextField: UITextField!
    @IBOutlet weak var durationTextField: UITextField!
    @IBOutlet weak var daysLabel: UILabel!
    @IBOutlet weak var minLabel: UILabel!
    
    
    var defaultDuration: Int = defaults.value(forKey: "Default Duration") as! Int
    var defaultFrequency: Int = defaults.value(forKey: "Default Frequency") as! Int
    let datePicker = UIDatePicker()
    var thisDate = Date()
    let toolBar = UIToolbar()
    
    var userBackgroundColor = UIColor.init(red: 245/255, green: 230/255, blue: 203/255, alpha: 1)
    var userTextColor = UIColor.init(red: 82/255, green: 67/255, blue: 40/255, alpha: 1)
    var userBarColor = UIColor.init(red: 82/255, green: 67/255, blue: 40/255, alpha: 1)
    var userFont = UIFont.init(name: "Times New Roman", size: 17.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        taskTitle.delegate = self
        freqDateTextField.delegate = self
        durationTextField.delegate = self
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(dateChange(datePicker:)), for: UIControl.Event.valueChanged)
        datePicker.frame.size = CGSize(width: 0, height: 300)
        datePicker.preferredDatePickerStyle = .wheels
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(onClickDoneButton))
        toolBar.setItems([space, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setTheme()
        freqDateTextField.text = "\(defaultFrequency)"
        durationTextField.text = "\(defaultDuration)"
    }
 
 
    @objc func onClickDoneButton() {
        self.view.endEditing(true)
    }
    
    @objc func dateChange(datePicker: UIDatePicker) {
        freqDateTextField.text = formatDate(date: datePicker.date)
        thisDate = datePicker.date
    }
    
    func formatDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.string(from: date)
    }
    
    @IBAction func recurToggleSwitch(_ sender: Any) {
        if recurringToggle.isOn {
            freqDateTextField.text = ""
            self.recurLabel.text = "Frequency"
            freqDateTextField.text = "\(defaultFrequency)"
            freqDateTextField.inputView = UITextField()
            daysLabel.textColor = userTextColor
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            thisDate = Date()
            let dateText = dateFormatter.string(from:thisDate)
            freqDateTextField.text = dateText
            self.recurLabel.text = "Due Date"
            freqDateTextField.inputView = datePicker
            freqDateTextField.inputAccessoryView = toolBar
            daysLabel.textColor = userBackgroundColor
        }
    }
    
    
    
    @IBAction func saveButton(_ sender: Any) {
        if let text = taskTitle.text, !text.isEmpty {
            let taskName = taskTitle.text
            if let durationtext = durationTextField.text,!durationtext.isEmpty {
                let durationInt = changeToInt(num: durationtext)
                if recurringToggle.isOn {
                    if let freqdatetext = freqDateTextField.text,!freqdatetext.isEmpty {
                        var freqDouble = changeToInt(num: freqdatetext)
                        if freqDouble != -999 {
                            if durationInt != -999 {
                                storeRecurringTask(title:taskName!, frequency:freqDouble, duration:durationInt)
                                let controller = UIAlertController(
                                    title: "Done adding tasks?",
                                    message: "Press \"Continue\" to add more tasks, \"Done\" to return to main screen",
                                    preferredStyle: .alert)
                                let continueButton = UIAlertAction(
                                    title: "Continue",
                                    style: .default,
                                    handler: { action in self.taskTitle.text = ""; self.freqDateTextField.text = String(self.defaultFrequency); self.durationTextField.text = String(self.defaultDuration) } )
                                let doneButton = UIAlertAction(
                                    title: "Done",
                                    style: .cancel,
                                    handler: { action in self.navigationController?.popViewController(animated: true) })
                                controller.addAction(continueButton)
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
                                message: "Please enter a valid integer instead of \(freqdatetext) for the frequency.",
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
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MM/dd/yyyy"
                    if let dateText = dateFormatter.date(from:freqDateTextField.text!) {
                        if durationInt != -999 {
                            storeOneTimeTask(title:taskName!, dueDate:thisDate, duration:durationInt)
                            let controller = UIAlertController(
                                title: "Done adding tasks?",
                                message: "Press \"Continue\" to add more tasks, \"Done\" to return to main screen",
                                preferredStyle: .alert)
                            let continueButton = UIAlertAction(
                                title: "Continue",
                                style: .default,
                                handler: { action in self.taskTitle.text = ""; let dateFormatter = DateFormatter(); dateFormatter.dateFormat = "MM/dd/yyyy"; self.freqDateTextField.text = "\(dateFormatter.string(from:self.thisDate))"; self.durationTextField.text = String(self.defaultDuration) } )
                            let doneButton = UIAlertAction(
                                title: "Done",
                                style: .cancel,
                                handler: { action in self.navigationController?.popViewController(animated: true) })
                            controller.addAction(continueButton)
                            controller.addAction(doneButton)
                            present(controller, animated: true)
                        } else {
                            let controller = UIAlertController(
                                title: "Invalid Input",
                                message: "Please enter a valid number instead of \(durationtext) for the duration.",
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
                            message: "Please enter a valid date instead of \(freqDateTextField.text) for the due date.",
                            preferredStyle: .alert)
                        let okButton = UIAlertAction(
                            title: "OK",
                            style: .default)
                        controller.addAction(okButton)
                        present(controller, animated: true)
                    }
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
                title: "Missing Title",
                message: "Please enter a valid title.",
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
    
    func storeRecurringTask(title:String, frequency:Int, duration:Int) {
        let todaysDate = Date()
        let lastdone = Date(timeInterval: Double(-86400 * frequency), since: todaysDate)
        
        let recurringTask = NSEntityDescription.insertNewObject(forEntityName: "RecurringTask", into: context)
        recurringTask.setValue(title, forKey: "title")
        recurringTask.setValue(frequency, forKey: "frequency")
        recurringTask.setValue(duration, forKey: "duration")
        recurringTask.setValue(lastdone, forKey: "lastDone")
        saveContext()
    }
    
    func storeOneTimeTask(title:String, dueDate:Date, duration:Int) {
        let oneTimeTask = NSEntityDescription.insertNewObject(forEntityName: "OneTimeTask", into: context)
        oneTimeTask.setValue(title, forKey: "title")
        oneTimeTask.setValue(dueDate, forKey: "dueDate")
        oneTimeTask.setValue(duration, forKey: "duration")
        saveContext()
    }
 
    func saveContext () {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
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
        recurLabel.textColor = userTextColor
        recurLabel.font = userFont
        timedLabel.textColor = userTextColor
        timedLabel.font = userFont
        recurring.textColor = userTextColor
        recurring.font = userFont
        timed.textColor = userTextColor
        timed.font = userFont
        daysLabel.textColor = userTextColor
        daysLabel.font = userFont
        minLabel.textColor = userTextColor
        minLabel.font = userFont
        doneButton.backgroundColor = .clear
        doneButton.layer.cornerRadius = 5
        doneButton.layer.borderWidth = 1
        doneButton.layer.borderColor = UIColor.black.cgColor
        doneButton.tintColor = userTextColor
        doneButton.titleLabel?.font = userFont
    }
}


