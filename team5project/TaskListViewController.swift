//
//  TaskListViewController.swift
//  team5project
//
//  Created by Nicole Estabrook on 10/15/22.
//

import UIKit
import CoreData

let appDelegate = UIApplication.shared.delegate as! AppDelegate
let context = appDelegate.persistentContainer.viewContext

class TaskCell: UITableViewCell {
    @IBOutlet weak var taskTitle: UILabel!
    @IBOutlet weak var taskDetail: UILabel!
    
    
}

class TaskListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var segmentedCont: UISegmentedControl!
    @IBOutlet weak var TaskTable: UITableView!
    
    var editSegueIdentifier = "EditSegueIdentifier"
    var cellBackgroundColor = UIColor(named: "white")
    var cellTextColor = UIColor(named: "white")
    var cellFont = UIFont.init(name: "Times New Roman", size: 15.0)
    
    var userBackgroundColor = UIColor.init(red: 245/255, green: 230/255, blue: 203/255, alpha: 1)
    var userTextColor = UIColor.init(red: 82/255, green: 67/255, blue: 40/255, alpha: 1)
    var userBarColor = UIColor.init(red: 82/255, green: 67/255, blue: 40/255, alpha: 1)
    var userFont = UIFont.init(name: "Times New Roman", size: 15.0)
    
    var segment = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TaskTable.delegate = self
        TaskTable.dataSource = self
        segment = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setTheme()
        TaskTable.reloadData()
    }
    
    @IBAction func segmentChange(_ sender: Any) {
        switch segmentedCont.selectedSegmentIndex {
        case 0:
            segment = 0
            TaskTable.reloadData()
        case 1:
            segment = 1
            TaskTable.reloadData()
        default:
            print("Error picking table")
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Tasks"
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let view = view as? UITableViewHeaderFooterView {
            view.textLabel?.textColor = userTextColor
            view.textLabel?.font = userFont
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rowCount  = 0
        if segment == 0 {
            let tasks = retrieveRecurringTasks()
            rowCount = tasks.count
        }
        if segment == 1 {
            let tasks = retrieveOneTimeTasks()
            rowCount = tasks.count
        }
        return rowCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell") as! TaskCell
        cell.backgroundColor = cellBackgroundColor
        cell.taskTitle.textColor = cellTextColor
        cell.taskTitle.font = cellFont
        cell.taskDetail.textColor = cellTextColor
        cell.taskDetail.font = cellFont
        if segment == 0 {
            let tasks = retrieveRecurringTasks()
            let taskAtRow = tasks[indexPath.row]
            cell.taskTitle.text! = taskAtRow.value(forKey: "title") as! String
            cell.taskDetail.text! = String(taskAtRow.value(forKey: "frequency") as! Int) // error showing - change as! String to as! Double and added String()
        }
        if segment == 1 {
            let tasks = retrieveOneTimeTasks()
            let taskAtRow = tasks[indexPath.row]
            cell.taskTitle.text! = taskAtRow.value(forKey: "title") as! String
            cell.taskDetail.text! = formatDate(date: taskAtRow.value(forKey: "dueDate") as! Date)// error showing - change as! String to as! Date and add function to format Date
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        var tasks = retrieveRecurringTasks()
        if segment == 0 {
            tasks = retrieveRecurringTasks()
        }
        if segment == 1 {
            tasks = retrieveOneTimeTasks()
        }
        if editingStyle == .delete {
            let commit = tasks[indexPath.row]
            context.delete(commit)
            tasks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            saveContext()
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
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
    
    func formatDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.string(from: date)
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

        if segue.identifier == editSegueIdentifier,
           let destination = segue.destination as? EditTaskViewController,
           let task = TaskTable.indexPathForSelectedRow
        {
            destination.delegate = self
            destination.editedTaskSection = self.segment
            destination.editedTaskIndex = task.row
        }
    }
    
    func checkCoreData() {
        let oneTimeList = retrieveOneTimeTasks()
        let recurrList = retrieveRecurringTasks()
        
        print(oneTimeList.count, recurrList.count)
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
            userFont = UIFont.init(name: "Arial", size: 15.0)
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
        TaskTable.backgroundColor = userBackgroundColor
        TaskTable.sectionIndexBackgroundColor = userTextColor
        cellBackgroundColor = userBackgroundColor
        cellTextColor = userTextColor
        cellFont = userFont
        segmentedCont.tintColor = userBackgroundColor
        segmentedCont.selectedSegmentTintColor = userBackgroundColor
        segmentedCont.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: userTextColor], for: UIControl.State.selected)
        segmentedCont.setTitleTextAttributes([NSAttributedString.Key.font: userFont], for: .normal)
        segmentedCont.setTitleTextAttributes([.foregroundColor: userTextColor], for: .normal)
    }
}
