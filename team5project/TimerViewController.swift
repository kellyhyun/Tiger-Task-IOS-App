//
//  TimerViewController.swift
//  team5project
//
//  Created by Kelly Hyun on 11/19/22.
//

import UIKit
import CoreData
import CoreMotion

class TimerViewController: UIViewController, UITableViewDelegate {
    let motionManager = CMMotionManager()
    var xPosDirection = 0.0
    var xNegDirection = 0.0
    var shakeCount = 0
    var shaken = false
    var chosenTask: NSManagedObject!
    var delegate: UIViewController!
    let queue = DispatchQueue(label: "queue", qos: .default)
    var timerCounting = true
    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var finishedImage: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    var timerDuration: Int = 0
    var timerDurationSec: Int = 0
    
    var userBackgroundColor = UIColor.init(red: 245/255, green: 230/255, blue: 203/255, alpha: 1)
    var userTextColor = UIColor.init(red: 82/255, green: 67/255, blue: 40/255, alpha: 1)
    var userFont = UIFont.init(name: "Times New Roman", size: 30.0)
    var taskTitle = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pauseButton.isHidden = true
        self.finishedImage.setImage(UIImage(named:"transparent"), for:.normal)
        DispatchQueue.global(qos: .background).async {
            self.startDelay()
            self.startTimer()
        }
        taskTitle = self.chosenTask.value(forKey: "title") as! String
        taskLabel.text = "Task: \(taskTitle)"
        checkShake()
        timerDuration = chosenTask.value(forKey: "duration") as! Int
        timerDurationSec = timerDuration*60
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setTheme()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        timerCounting = false
    }
    
    @IBAction func pausePlay(_ sender: Any) {
        if timerCounting == true {
            timerCounting = false
            pauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        } else {
            timerCounting = true
            pauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            DispatchQueue.global(qos: .background).async {
                self.startTimer()
            }
        }
    }
    
    func startDelay() {
        var delay = 3
        while (delay ?? 0 > 0) {
            DispatchQueue.main.async {
                self.pauseButton.isHidden = true
                self.timerLabel.text = "Starting in \(delay)"
                self.view.setNeedsDisplay()
                self.timerLabel.setNeedsDisplay()
                delay-=1
            }
            sleep(1)
        }
    }
    
    func startTimer() {
        while ((self.timerDurationSec ?? 0 > 0) && (self.timerCounting)) {
            DispatchQueue.main.async {
                self.pauseButton.isHidden = false
                var timerMin = self.timerDurationSec/60
                var timerSec = self.timerDurationSec - timerMin*60
                if (timerSec > 9) && (timerMin > 9) {
                    self.timerLabel.text = "\(timerMin):\(timerSec)"
                }else if (timerSec < 10) && (timerMin > 9) {
                    self.timerLabel.text = "\(timerMin):0\(timerSec)"
                }else if (timerSec > 9) && (timerMin < 10) {
                    self.timerLabel.text = "0\(timerMin):\(timerSec)"
                } else if (timerSec < 10) && (timerMin < 10) {
                    self.timerLabel.text = "0\(timerMin):0\(timerSec)"
                }
                self.view.setNeedsDisplay()
                self.timerLabel.setNeedsDisplay()
                self.timerDurationSec-=1
            }
            sleep(1)
            
            if self.timerDurationSec == 0 {
                self.taskDone()
            }
            
            if self.shaken == true {
                self.taskDone()
            }
        }
    }
    
    func taskDone() {
        let controller = UIAlertController(
            title: "Task is done!",
            message: "Press \"OK\" to go back.",
            preferredStyle: .alert)
        let okButton = UIAlertAction(
            title: "OK",
            style: .default,
            handler: { _ in
                self.navigationController?.popViewController(animated: true)
                })
        controller.addAction(okButton)
        UNUserNotificationCenter.current().requestAuthorization(options:[.alert,.badge,.sound]) {
            granted, error in
            if granted {
                print("All set!")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
        // create content
        let content = UNMutableNotificationContent()
        content.title = "Task Completion"
        content.subtitle = "Notification for Taskgetter App"
        content.body = "Great job for finishing your \(taskTitle) task!"
        content.sound = UNNotificationSound.default
        
        // create trigger
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        // combine it all into a request
        let request = UNNotificationRequest(identifier: "myNotification", content: content, trigger: trigger)
        
        DispatchQueue.main.async {
            self.pauseButton.isHidden = true
            let recurringTaskList = self.retrieveRecurringTasks()
            let oneTimeTaskList = self.retrieveOneTimeTasks()
            
            //deletes if one time task
            if oneTimeTaskList.contains(self.chosenTask){
                context.delete(self.chosenTask)
                self.saveContext()
            }
            //updates lastDone if recurring task
            else if recurringTaskList.contains(self.chosenTask) {
                let tasktitle = self.chosenTask.value(forKey: "title") as! String
                let taskfreq = self.chosenTask.value(forKey: "frequency") as! Int
                let taskduration = self.chosenTask.value(forKey: "duration") as! Int
                context.delete(self.chosenTask)
                self.storeRecurringTask(title:tasktitle, frequency:taskfreq, duration:taskduration)
                self.saveContext()
            }
            UIView.animate(withDuration: 0.0, delay: 0.0, options: .curveEaseOut,
                animations: { self.finishedImage.alpha = 0.0 },
                completion: {(finished) in
                //change image
                self.finishedImage.setImage(UIImage(named:"finished"), for:.normal)
                UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseIn,
                               animations: { self.finishedImage.alpha = 1.0},
                               completion: nil)
            })
        }
        sleep(2)
        DispatchQueue.main.async {
            self.simpleVibrate()
            sleep(1)
            self.simpleVibrate()
            sleep(1)
            self.simpleVibrate()
            self.present(controller, animated: true)
            UNUserNotificationCenter.current().add(request)
            // generator.impactOccurred()
        }
    }
    
    func simpleVibrate() {
        print("VIBRATE")
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
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
    
    func storeRecurringTask(title:String, frequency:Int, duration:Int) {
        let lastdone = Date()
        
        let recurringTask = NSEntityDescription.insertNewObject(forEntityName: "RecurringTask", into: context)
        recurringTask.setValue(title, forKey: "title")
        recurringTask.setValue(frequency, forKey: "frequency")
        recurringTask.setValue(duration, forKey: "duration")
        recurringTask.setValue(lastdone, forKey: "lastDone")
        saveContext()
    }
    
    func saveContext () {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func checkShake() {
        motionManager.deviceMotionUpdateInterval = 0.1
        motionManager.startDeviceMotionUpdates(to: (OperationQueue.current!)) {
            (deviceMotion, error) -> Void in
            if (error == nil) {
                let acceleration = deviceMotion!.userAcceleration
                let xAcc = acceleration.x
                
                if xAcc > 1.0 {
                    self.xPosDirection = xAcc
                }
                
                if xAcc < -1.0 {
                    self.xNegDirection = xAcc
                }
                
                if self.xPosDirection != 0.0 && self.xNegDirection != 0.0 {
                    self.shakeCount += 1
                    self.xPosDirection = 0.0
                    self.xNegDirection = 0.0
                }
                
                if self.shakeCount > 3 {
                    self.shaken = true
                }
            } else {
                print("Error occurred")
            }
        }
    }
    
    func setTheme() {
        let themeChoice = defaults.integer(forKey: "Default Theme")
        
        if themeChoice == 0 {
            userBackgroundColor = UIColor.init(red: 11/255, green: 223/255, blue: 227/255, alpha: 1)
            userTextColor = UIColor.init(red: 135/255, green: 13/255, blue: 4/255, alpha: 1)
            userFont = UIFont.init(name: "Chalkboard SE", size: 30.0)
        }
        else if themeChoice == 1 {
            userBackgroundColor = UIColor.init(red: 201/255, green: 254/255, blue: 255/255, alpha: 1)
            userTextColor = UIColor.init(red: 72/255, green: 0/255, blue: 255/255, alpha: 1)
            userFont = UIFont.init(name: "Arial", size: 30.0)
        }
        else if themeChoice == 2 {
            userBackgroundColor = UIColor.init(red: 245/255, green: 230/255, blue: 203/255, alpha: 1)
            userTextColor = UIColor.init(red: 82/255, green: 67/255, blue: 40/255, alpha: 1)
            userFont = UIFont.init(name: "Times New Roman", size: 30.0)
        }
        else if themeChoice == 3 {
            userBackgroundColor = UIColor.init(red: 9/255, green: 48/255, blue: 122/255, alpha: 1)
            userTextColor = UIColor.init(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
            userFont = UIFont.init(name: "Futura", size: 30.0)
        }
        
        self.view.backgroundColor = userBackgroundColor
        taskLabel.textColor = userTextColor
        taskLabel.font = userFont
        timerLabel.textColor = userTextColor
        timerLabel.font = userFont
    }
}
