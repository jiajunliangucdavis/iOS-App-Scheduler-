//
//  DailyPalnnerViewController.swift
//  DailyPlanner4
//
//  Created by Hanxing Zhang on 2018/11/19.
//  Copyright © 2018 Hanxing Zhang. All rights reserved.
//

import UIKit
import UserNotifications


class DailyPalnnerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,NoteViewDelegate {
   
    @IBOutlet weak var dailyTasks: UITableView!
    var models = model()
    var myPhone = Storage()
    var rowChosen = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dailyTasks.delegate = self
        dailyTasks.dataSource = self
        dailyTasks.reloadData()

        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.myPhone = Storage.init()
        viewInit()
    }
    
    /*
     Get the latest data on local storage before view is loaded
     */
    func viewInit() {
        self.models = myPhone.getDailyTasks(key: "dailyTasks") ?? model.init()
        self.dailyTasks.reloadData()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return models.dailyTasks.count
    }
    
 
    /*
     add a row
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dailyPlannerCell", for: indexPath as IndexPath)
        // Configure the cell
        let currentKey = self.models.dailyTasks[indexPath.row]
        cell.textLabel?.text = currentKey.interval
        cell.detailTextLabel?.text = currentKey.note
        if(currentKey.note == "")
        {
            cell.detailTextLabel?.textColor = UIColor.darkGray
            cell.detailTextLabel?.text = "..."
        }

        return cell
    }

    /*
     delete a row
     */
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            let alertController = UIAlertController(title: "Alert", message: "Are you sure you want to delete this task?", preferredStyle: .alert)
            let closure = { (action: UIAlertAction!) -> Void in
                if action.title == "Delete" {
                    // update the daily tasks in storage as well
                    self.models.dailyTasks.remove(at: indexPath.row)
                    self.myPhone.setDailyTasks(key: "dailyTasks", value:self.models)
                    tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
                }
            }

            let action1 = UIAlertAction(title: "Delete", style: .default, handler: closure)

            let action2 = UIAlertAction(title: "Cancel", style: .cancel, handler: {(_) in })

            alertController.addAction(action1)
            alertController.addAction(action2)
            self.present(alertController, animated: true, completion: nil)

        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        rowChosen = indexPath.row
        performSegue(withIdentifier: "EditDetail", sender: self)

    }
    
    @IBAction func deleteAllPressed(_ sender: Any) {
        let alertController = UIAlertController(title: "Alert", message: "Are you sure you want to delete all tasks?", preferredStyle: .alert)
        let closure = { (action: UIAlertAction!) -> Void in
            if action.title == "Delete all" {
                // delete all data and set the storage as empty
                self.models = model.init()
                self.myPhone.setDailyTasks(key: "dailyTasks", value: self.models)
                self.dailyTasks.reloadData()
            }
        }

        let action1 = UIAlertAction(title: "Delete all", style: .default, handler: closure)

        let action2 = UIAlertAction(title: "Cancel", style: .cancel, handler: {(_) in })

        alertController.addAction(action1)
        alertController.addAction(action2)
        self.present(alertController, animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // for adding new daily planner task
        if segue.identifier == "newDetail" {
            rowChosen = -1
            if let destinationVC = segue.destination as? DailyPlannerDetailViewController {
                destinationVC.delegate = self
            }
        } // for edit existing daily planner task
        else if segue.identifier == "EditDetail" {
            if let destinationVC = segue.destination as? DailyPlannerDetailViewController {
                let dest = segue.destination as! DailyPlannerDetailViewController
                dest.edit = true
                dest.editIdx = rowChosen
                dest.timeInterval = models.dailyTasks[rowChosen].interval
                dest.notes = models.dailyTasks[rowChosen].note
                destinationVC.delegate = self
            }
        }
    }
    
    func didUpdateNoteWithTimeInterval(newTime: String, andBody newBody: String) {
        //update the respective values
        if rowChosen == -1 {
            let ind1 = newTime.firstIndex(of: ":")!
            let hour = newTime[..<ind1]
            let ind2 = newTime.firstIndex(of: " ")!
            let range = newTime.index(after: ind1)..<ind2
            
            let minute = newTime[range]
            var minuteInt = 0
            if (minute == "00") {
                minuteInt = 0
            } else if (minute[0] == "0")
            {
                minuteInt = Int(minute[1...]) ?? 0
            } else {
                minuteInt = Int(minute) ?? 0
            }
           
            let hourInt = Int(hour) ?? 23
           
            
            let newDailyTask = dailyTask(interval: newTime, note: newBody)
            models.append(task: newDailyTask)
            let lastRowInd = models.dailyTasks.count
            dailyTasks.beginUpdates()
        
            dailyTasks.insertRows(at: [
                NSIndexPath(row: models.dailyTasks.count-1, section: 0) as IndexPath], with: .automatic)
        
            dailyTasks.endUpdates()
            
            
            // now, after add each task, add a notification 15 minutes before a task
            let content = UNMutableNotificationContent()
            content.title = "Reminder for your task"
            content.body = "15 minutes left to start your task: " + newBody
            content.sound = UNNotificationSound.default
            
            var dateComponents = DateComponents()
            dateComponents.weekday = Calendar.current.component(.weekday, from: Date())
            if minuteInt >= 15 {
                dateComponents.hour = hourInt
                dateComponents.minute = minuteInt - 15
            } else {
                dateComponents.hour = hourInt - 1
                dateComponents.minute = 60 - (15 - minuteInt)
            }
            
            let notificationTrigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            
            // assign a unique identifier for each row
            let request = UNNotificationRequest(identifier: "notification"+String(lastRowInd), content: content, trigger: notificationTrigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
        else {
            let newDailyTask = dailyTask(interval: newTime, note: newBody)
            models.dailyTasks[rowChosen] = newDailyTask
            dailyTasks.beginUpdates()
            dailyTasks.endUpdates()
        }
        
        //refresh the view
        dailyTasks.reloadData()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }

    
}
