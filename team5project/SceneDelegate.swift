//
//  SceneDelegate.swift
//  team5project
//
//  Created by Nicole Estabrook on 10/14/22.
//

import UIKit
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
        
        //when app exited, checks for overdue tasks and calls overdue alert if there are any
        if checkOverdueTasks() {overdueAlert()}
    }
    
    var overdueTasks = 0
    
    //creates and triggers local notif for overdue assingments
    func overdueAlert() {
        let overdueNotif = UNMutableNotificationContent()
        overdueNotif.title = "Task Tiger Reminder"
        overdueNotif.subtitle = "Overdue Tasks Alert"
        overdueNotif.body = "You have \(overdueTasks) overdue tasks!"
        
        let overdueNotifTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let overdueNotifReq = UNNotificationRequest(identifier: "myNotif", content: overdueNotif, trigger: overdueNotifTrigger)
        
        UNUserNotificationCenter.current().add(overdueNotifReq)
    }
    
    //checks for overdue assignments and updates the count
    func checkOverdueTasks() -> Bool {
        overdueTasks = 0
        let recurringTaskList = retrieveRecurringTasks()
        let oneTimeTaskList = retrieveOneTimeTasks()
        
        for task in recurringTaskList {
            let freq = task.value(forKey: "frequency") as! Int
            let lastDone = task.value(forKey: "lastDone") as! Date
            let today = Date()
            let daysSinceLast = Int(((today.timeIntervalSince1970 - lastDone.timeIntervalSince1970) / 86400))
            let priority = Double(daysSinceLast - freq) / Double(freq)
            
            if priority > 1 {overdueTasks += 1}
        }
        
        for task in oneTimeTaskList {
            let duedate = task.value(forKey: "dueDate") as! Date
            let currentdate = Date(timeIntervalSinceNow: 0)
            let daystildue = (duedate.timeIntervalSince1970 - currentdate.timeIntervalSince1970) / 86400
            
            if daystildue < 0 {overdueTasks += 1}
        }
        
        if overdueTasks > 0 {return true}
        else {return false}
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


}

