//
//  MainViewController.swift
//  Scheduler
//
//  Created by JIAJUN LIANG on 11/17/18.
//  Copyright © 2018 JIAJUN LIANG. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation
import UserNotifications


class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,  CLLocationManagerDelegate {
    
    /**** Properties ****/
    
    var schedule = Schedule()
    var myPhone = Storage()
    let locationManager = CLLocationManager() // Used to start getting the users location
    
    var locationLat = 0.0
    var locationLong = 0.0
    var selectedRow = -1
    var TDLeditOnCell = 0 // To Do List Edit On Cell
    var daysLeftString = ""
    var inEditMode = false
    var blurEffect:UIVisualEffect! // blur effect when tapping on cell
    
    
    @IBOutlet var directionView: UIView! // Directs to detail or manager
    @IBOutlet weak var listOfTasks: UITableView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    
    /**** Main View init and set up function ****/
    
    override func viewDidLoad() {
        super.viewDidLoad()

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: {didAllow, error in
        })
        blurEffect = blurView.effect
        blurView.effect = nil
        blurView.isHidden = true
        directionView.layer.cornerRadius = 5
        
        // For use when the app is open & in the background
        locationManager.requestAlwaysAuthorization()
        // If location services is enabled get the users location
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            // You can change the locaiton accuary here.
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // init storage
        self.myPhone = Storage.init()
        listOfTasks.dataSource = self
        listOfTasks.delegate = self
        viewInit()
    }
    
    /* Get the latest data on local storage before view is loaded */
    func viewInit() {
        self.schedule = myPhone.get(key: "allTasks") ?? Schedule.init()
        self.listOfTasks.reloadData()
    }
    
    
    /**** Schedule TableView set up ****/
    
    /* Number of cells in the tableview */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.schedule.tasks.count
    }
    
    /* Set each cell */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! MainTableViewCell
        
        // current task
        let currentKey = self.schedule.tasks[indexPath.row]
        cell.taskTitleLabel.text = "\(currentKey.title)"
        cell.dueDayLabel.text = "Due on \(currentKey.due_date.month) / \(currentKey.due_date.day) / \(currentKey.due_date.year)"
        
        // countdown, accurate to days
        let daysleft = getdaysleft(cur_task: currentKey)
        if daysleft > 0 {
            if (daysleft > 1){
                cell.daysLeftLabel.text = "\(daysleft) Days Left"
            } else {
                cell.daysLeftLabel.text = "\(daysleft) Day Left"
            }
            daysLeftString = cell.daysLeftLabel.text ?? ""
        } else if daysleft == 0 {
            cell.daysLeftLabel.text = "Due Today"
        } else {
            cell.daysLeftLabel.text = "Pass Due"
        }
        
        return cell
    }
    
    
    /**** Action ****/
    
    /* Cell is selected -> show direction view */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        TDLeditOnCell = indexPath.row
        addBlurAnimation()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    /* hide direction view when click on button */
    @IBAction func dismissMenu(_ sender: UIButton) {
        removeBlurAnimation()
    }
    
    /* Swipe left to delete a cell; alert confirm before actually delete */
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            let alertController = UIAlertController(title: "Alert", message: "Are you sure to delete this task?", preferredStyle: .alert)
            
            let closure = { (action: UIAlertAction!) -> Void in
                if action.title == "Delete" {
                    self.schedule.tasks.remove(at: indexPath.row)
                    self.myPhone.setSchedule(key: "allTasks", value: self.schedule)
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
    
    /* The cell calls this method when the user taps the edit button */
    @IBAction func AddAction(_ sender: Any) {
        inEditMode = false
        print("called")
        performSegue(withIdentifier: "editTask", sender: nil)
        
    }
    
    @IBAction func editTask(_ sender: UIButton) {
        inEditMode = true
    }
    
    /***************************************************************
     Prof Challenge: improve user experience
     Inject tasks automatically based on classroom location, class time and canvas
     so that user doesn't have to type in all tasks
     Current Version: Hard Code Tasks, but live time and location
     ****************************************************************/
    
    /* Button to load tasks based on location and time */
    @IBAction func loadNearbyTasks(_ sender: UIBarButtonItem) {
        
        // Get current time for display
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .medium
        let currentDateTime = formatter.string(from: Date())
        
        // Hard code some ecs 189e tasks
        let dueDateInfo_A = Mydate.init(month: "12", day: "7", year: "2018", hour: "23", minute : "59")
        let dueDateInfo_B = Mydate.init(month: "12", day: "15", year: "2018",hour: "23", minute : "59" )
        let dueDateInfo_C = Mydate.init(month: "1", day: "7", year: "2019",hour: "23", minute : "59" )
        let dueDateInfo_D = Mydate.init(month: "12", day: "14", year: "2018", hour: "23", minute : "59")
        
        let newTask1 = Task.init(title : "Project Demos", dueDate : dueDateInfo_A, details : "")
        let newTask2 = Task.init(title : "Final project", dueDate : dueDateInfo_D, details : "")
        let newTask3 = Task.init(title : "Peer grading", dueDate : dueDateInfo_D, details : "")
        let newTask4 = Task.init(title : "Party Time Go Go GO!", dueDate : dueDateInfo_B, details : "")
        let newTask5 = Task.init(title : "Winter quarter begins", dueDate : dueDateInfo_C, details : "")
        
        let ecs189e_tasks = [newTask1, newTask2, newTask3, newTask4, newTask5]
        
        // ecs189e reminders
        let display_location = "Art 204, UC Davis"
        let myclass = "ECS 189e"
        let my_message = "Current Location: \(display_location) \n Time: \(currentDateTime) \n Ongoing Class: \(myclass) \n \(ecs189e_tasks.count) tasks found for this class \n Do you want to load tasks from this class?"
        
        // load ecs189e tasks
        let alertController = UIAlertController(title: "Reminder", message: "\(my_message)", preferredStyle: .alert)
        let closure = { (action: UIAlertAction!) -> Void in
            if action.title == "Load"{
                let existingSchedule = self.myPhone.get(key: "allTasks") ?? Schedule.init()
                for task in ecs189e_tasks{
                    if(self.notInSchedule(schedule: existingSchedule,task)){
                        self.schedule.append(task: task)
                    }
                }
                self.schedule.sort()
                self.myPhone.setSchedule(key: "allTasks", value: self.schedule)
                self.listOfTasks.reloadData()
            }
        }
        
        // no tasks at this time or location
        let alertControllerNoTasksFound = UIAlertController(title: "Reminder", message: "No tasks found around you at this time", preferredStyle: .alert)
        
        
        // change here to preferred time and location
        if (checkTime_for_loadingTasks() && checkLocation_for_loadingTasks()) {
            
            let action1 = UIAlertAction(title: "Load", style: .default, handler: closure)
            alertController.addAction(action1)
            let action2 = UIAlertAction(title: "Cancel", style: .cancel, handler: {(_) in })
            alertController.addAction(action2)
            self.present(alertController, animated: true, completion: nil)
            self.listOfTasks.reloadData()
            
        } else {
            let action3 = UIAlertAction(title: "Cancel", style: .cancel, handler: {(_) in })
            alertControllerNoTasksFound.addAction(action3)
            self.present(alertControllerNoTasksFound, animated: true, completion: nil)
            self.listOfTasks.reloadData()
        }
    }
    
    /* clear button should delete all tasks in schedule */
    @IBAction func clearOnTap(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Alert", message: "Are you sure to delete all tasks?", preferredStyle: .alert)
        
        let closure = { (action: UIAlertAction!) -> Void in
            if action.title == "Delete" {
                self.schedule = Schedule.init()
                self.myPhone.setSchedule(key: "allTasks", value: self.schedule)
                self.listOfTasks.reloadData()
            }
        }
        
        let action1 = UIAlertAction(title: "Delete", style: .default, handler: closure)
        let action2 = UIAlertAction(title: "Cancel", style: .cancel, handler: {(_) in })
        alertController.addAction(action1)
        alertController.addAction(action2)
        self.present(alertController, animated: true, completion: nil)
        self.listOfTasks.reloadData()
    }
    
    /* Unwind segue way from To-do list to scheduler */
    @IBAction func unwindToVC1(segue:UIStoryboardSegue) {
        self.directionView.removeFromSuperview()
        self.blurView.isHidden = true
    }
    
    
    /**** Helper functions ****/
    
    /* Add blur animation when tapping on a cell */
    func addBlurAnimation() {
        blurView.isHidden = false
        self.view.addSubview(directionView) //push subview
        directionView.center = self.view.center //adjust subview position to center
        
        directionView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3) //transform is animation
        directionView.alpha = 0
        
        UIView.animate(withDuration: 0.4) {
            self.blurView.effect = self.blurEffect
            self.directionView.alpha = 1
            self.directionView.transform = CGAffineTransform.identity
        }
    }
    
    func removeBlurAnimation() {
        //do animation
        UIView.animate(withDuration: 0.3, animations: {
            self.directionView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.directionView.alpha = 0
            
            self.blurView.effect = nil //remove effect
            
        }) { (success:Bool) in
            self.directionView.removeFromSuperview()
            self.blurView.isHidden = true
        } //if animation is done properly, pop subview and hide blurview
    }
    
    /* Print out the location to the console */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            locationLat = location.coordinate.latitude
            locationLong = location.coordinate.longitude
        }
    }
    
    /* If we have been deined access give the user the option to change it */
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if(status == CLAuthorizationStatus.denied) {
            showLocationDisabledPopUp()
        }
    }
    
    /* Show the popup view to the user if we have been deined access */
    func showLocationDisabledPopUp() {
        let alertController = UIAlertController(title: "Background Location Access Disabled", message: "In order to load nearby tasks we need your location", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let openAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        alertController.addAction(openAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    /*
     Get how many days left based on task's due date
     how many days left = dueDay - today's date
    */
    func getdaysleft(cur_task : Task) -> Int {
        let daysleft: Int
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy HH:mm"
        //Sameple format: let dueDate = formatter.date(from: "12/27/2018 22:38")
        let dueDate = formatter.date(from: "\(String(cur_task.due_date.month))/\(String(cur_task.due_date.day))/\(String(cur_task.due_date.year)) \(String(cur_task.due_date.hour)):\(String(cur_task.due_date.minute))")
        
        // The time interval between the date value and the current date and time in seconds
        // If the date is earlier than the current date and time, this property’s value is negative.
        let interval = Double(dueDate?.timeIntervalSinceNow ?? 0.0)
        
        // 1 day = 864000 sec
        let daysleftInDouble = interval / 86400
        
        if (daysleftInDouble < 0) {
            // due to the truncation when converting negative daysleftInDouble to Int
            daysleft = Int(daysleftInDouble) - 1
        } else {
            // we actually need the truncation when converting positive daysleftInDouble to Int
            daysleft = Int(daysleftInDouble)
        }
        
        return daysleft
    }
    
    /*
     Check whether there are any identical tasks in schedule.
     It only loads the non-duplicate tasks.
    */
    func notInSchedule( schedule : Schedule, _ newTask : Task) ->Bool{
        let existingTasks = schedule.tasks
        for task in existingTasks{
            if(task == newTask){
                return false
            }
        }
        return true
    }
    
    /*
     Comparing today's date to some time period
     in order to determine whether ecs 189e tasks should be loaded
     For example, here we check whether current time is inside Fall 2018 period
     It could be extened in many ways
    */
    func checkTime_for_loadingTasks() -> Bool {
        
        let fall2018_startDate = "9/24/2018 7:30"
        let fall2018_endDate = "1/6/2019 23:59"
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy HH:mm"
        //Sameple format: let dueDate = formatter.date(from: "12/27/2018 22:38")
        let startDate = formatter.date(from: fall2018_startDate)
        let endDate = formatter.date(from: fall2018_endDate)
        
        // should be negative if today is inside Fall 2018 period
        let startInterval = Int(startDate?.timeIntervalSinceNow ?? 0)
        // should be positive if today is inside Fall 2018 period
        let endInterval = Int(endDate?.timeIntervalSinceNow ?? 0)
        
        if (startInterval <= 0 && endInterval >= 0) {
            // today is inside Fall 2018 period
            // should load esc189e tasks
            return true
        } else {
            return false
        }
    }
    
    /*
     Comparing geolocation to Art Building, UC Davis
     If user is at Art 204, then return true for loading ecs 189e tasks
     It could be extened in many ways.
    */
    func checkLocation_for_loadingTasks() -> Bool {
        struct Art_location {
            var latitude = 38.5389354
            var longitude = -121.74838650000001
        }
        
        let Art204 = Art_location()
        // *** NOTE: accuracy shouldn't be that large ***
        // But it is easier for Prof to test our program even in Kemper office
        let accuracy = 1.0
        
        if ((abs(Art204.latitude - locationLat) < accuracy && abs(Art204.longitude - locationLong) < accuracy)) {
            // User is at Art 204
            // should load esc189e tasks
            return true
        } else {
            return false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editTask"{
            let editTasks = segue.destination as! addTask
            editTasks.edit = inEditMode
            editTasks.editIdx = TDLeditOnCell
        }
        else{
        let vc = segue.destination as? ToDoListViewController
        vc?.editingTaskIndex = TDLeditOnCell
        }
    }
    
    
    
    
}

