//
//  TaskViewController.swift
//  tasktester
//
//  Created by Aneesa Bhakta on 11/19/22.
//

import UIKit
import CoreData

class TaskViewController: UIViewController, UITextFieldDelegate {
    
    var timeAvailable = 0
    var timeGiven = false
    @IBOutlet weak var timeField: UITextField!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var minutesLabel: UILabel!
    @IBOutlet weak var taskButton: UIButton!
    @IBOutlet weak var refreshLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
   
    
    var gesRec: UIView!
    var sendTask: NSManagedObject!
    
    var userBackgroundColor = UIColor.init(red: 245/255, green: 230/255, blue: 203/255, alpha: 1)
    var userTextColor = UIColor.init(red: 82/255, green: 67/255, blue: 40/255, alpha: 1)
    var userBarColor = UIColor.init(red: 82/255, green: 67/255, blue: 40/255, alpha: 1)
    var userFont = UIFont.init(name: "Times New Roman", size: 17.0)

    
    override func viewDidLoad() {
        super.viewDidLoad()
        timeField.delegate = self
        gesRec = UIView(frame: CoreGraphics.CGRect(x:0, y:88, width:414, height:774))
        gesRec.translatesAutoresizingMaskIntoConstraints = true
        gesRec.isUserInteractionEnabled = true
        view.addSubview(gesRec)
        view.sendSubviewToBack(gesRec)
        
        
        let upSwipeRecognizer = UISwipeGestureRecognizer(target:self, action:#selector(recognizeUpSwipe(recognizer:)))
        upSwipeRecognizer.direction = UISwipeGestureRecognizer.Direction.up
        self.view.addGestureRecognizer(upSwipeRecognizer)
        
        taskLabel.text = ""
        refreshLabel.text = ""
        startButton.isHidden = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        setTheme()
    }

    
    @IBAction func giveTaskPressed(_ sender: Any) {
        timeAvailable = Int(timeField.text!) ?? 0
        timeGiven = true
        getTask()
    }
    
    @objc func recognizeUpSwipe(recognizer: UISwipeGestureRecognizer) {
        if recognizer.state == .ended {
            if timeGiven {
                getTask()
            }
        }
    }
    
    func getTask() {
        let recurringTaskList = retrieveRecurringTasks()
        let oneTimeTaskList = retrieveOneTimeTasks()
        var weightedTaskList:[NSManagedObject] = []
        
        if (recurringTaskList.count + oneTimeTaskList.count == 0) {
            taskLabel.text = "No tasks available"
            refreshLabel.text = ""
            startButton.isHidden = true
        }
        else {
            for task in recurringTaskList {
                let taskdur = task.value(forKey: "duration") as! Int
                if (taskdur <= timeAvailable) {
                    let freq = task.value(forKey: "frequency") as! Int
                    let lastDone = task.value(forKey: "lastDone") as! Date
                    let today = Date()
                    let daysSinceLast = Int(((today.timeIntervalSince1970 - lastDone.timeIntervalSince1970) / 86400))
                    
                    let priority = Double(daysSinceLast - freq) / Double(freq)
                    
                    var weight = 0
                    if priority <= -1 {weight = 0}
                    else if priority < -0.5 {weight = 1}
                    else if priority < -0.25 {weight = 2}
                    else if priority < 0 {weight = 3}
                    else if priority < 0.2 {weight = 4}
                    else if priority < 0.4 {weight = 5}
                    else if priority < 0.6  {weight = 6}
                    else if priority < 0.8 {weight = 7}
                    else if priority < 1 {weight = 8}
                    else if priority < 1.2 {weight = 9}
                    else if priority < 1.5 {weight = 10}
                    else {weight = 20}
                                        
                    var i = 0
                    while i < weight {
                        weightedTaskList.append(task)
                        i += 1
                    }
                }
            }
            
            for task in oneTimeTaskList {
                let taskdur = task.value(forKey: "duration") as! Int
                if (taskdur <= timeAvailable) {
                    let duedate = task.value(forKey: "dueDate") as! Date
                    let currentdate = Date(timeIntervalSinceNow: 0)
                    let timetildue = duedate.timeIntervalSince1970 - currentdate.timeIntervalSince1970
                    let daystildue = timetildue / 86400
                    
                    var weight = 0
                    if daystildue < 0 {weight = 20}
                    else if daystildue <= 1 {weight = 10}
                    else if daystildue <= 2 {weight = 9}
                    else if daystildue <= 3 {weight = 8}
                    else if daystildue <= 4 {weight = 7}
                    else if daystildue <= 5 {weight = 6}
                    else if daystildue <= 6 {weight = 5}
                    else if daystildue <= 7 {weight = 4}
                    else if daystildue <= 10 {weight = 3}
                    else if daystildue <= 14 {weight = 2}
                    else {weight = 1}
                                                        
                    var i = 0
                    while i < weight {
                        weightedTaskList.append(task)
                        i += 1
                    }
                }
            }
            
            if weightedTaskList.count == 0 {
                taskLabel.text = "No tasks available for that duration"
                refreshLabel.text = ""
                startButton.isHidden = true
            }
            else {
                let n = Int.random(in: 1...weightedTaskList.count)
                let chosenTask = weightedTaskList[n-1]
                taskLabel.text = "Your randomly assigned task is:\n \(chosenTask.value(forKey: "title") ?? "error")"
                refreshLabel.text = "Swipe up to choose a new task"
                sendTask = chosenTask
                startButton.isHidden = false
            }
        }
    }
    
    func retrieveRecurringTasks() -> [NSManagedObject] {
        let request1 = NSFetchRequest<NSFetchRequestResult>(entityName: "RecurringTask")
        var fetchedResults1:[NSManagedObject]? = nil
        
        do {
            try fetchedResults1 = context.fetch(request1) as? [NSManagedObject]
        } catch {
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        return(fetchedResults1)!
    }
    
    func retrieveOneTimeTasks() -> [NSManagedObject] {
        let request2 = NSFetchRequest<NSFetchRequestResult>(entityName: "OneTimeTask")
        var fetchedResults2:[NSManagedObject]? = nil
        
        do {
            try fetchedResults2 = context.fetch(request2) as? [NSManagedObject]
        } catch {
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        return(fetchedResults2)!
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "timerSegue",
            let timerVC = segue.destination as? TimerViewController {
                timerVC.delegate = self
                timerVC.chosenTask = sendTask
                self.taskLabel.text = ""
                self.refreshLabel.text = ""
                self.startButton.isHidden = true
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
        timeLabel.textColor = userTextColor
        timeLabel.font = userFont
        taskLabel.textColor = userTextColor
        taskLabel.font = userFont
        minutesLabel.textColor = userTextColor
        minutesLabel.font = userFont
        taskButton.tintColor = userTextColor
        refreshLabel.textColor = userTextColor
        refreshLabel.font = userFont
        startButton.tintColor = userTextColor
        taskButton.backgroundColor = .clear
        taskButton.layer.cornerRadius = 5
        taskButton.layer.borderWidth = 1
        taskButton.layer.borderColor = UIColor.black.cgColor
        taskButton.titleLabel?.font = userFont
        startButton.backgroundColor = .clear
        startButton.layer.cornerRadius = 5
        startButton.layer.borderWidth = 1
        startButton.layer.borderColor = UIColor.black.cgColor
        startButton.titleLabel?.font = userFont
    }
    
    func textFieldShouldReturn(_ textField:UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

