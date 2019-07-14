//
//  classes.swift
//  This class defines all the data structures for this app
//


import UIKit
import Foundation

/*
 Logic for sorting scheduled events
 conditional is as follows:
 year1 less
 years same, month1 less
 years and months same day1 less
 years,months amnd days same hour1 less
 years,months,dats,hour same minute1 less
 thus 1 should go before 2
 */

/* sort function for date */
func eventPriority(task1 : Task?, task2 : Task?) -> Bool{
    guard let task1Unwrap = task1, let task2Unwrap = task2 else{
        return true
    }
    let date1 = task1Unwrap.due_date, date2 = task2Unwrap.due_date
    let date1Yr = date1.year, date2Yr = date2.year
    let date1Mon = date1.month, date2Mon = date2.month
    let date1Day = date1.day, date2Day = date2.day
    let date1Hour = date1.hour, date2Hour = date2.hour
    let date1Minute = date1.minute, date2Minute = date2.minute
    if (date2Yr > date1Yr ||
        date2Yr == date1Yr && date2Mon > date1Mon ||
        date2Yr == date1Yr && date2Mon == date1Mon && date2Day > date1Day ||
        date2Yr == date1Yr && date2Mon == date1Mon && date2Day == date1Day && date2Hour > date1Hour ||
        date2Yr == date1Yr && date2Mon == date1Mon && date2Day == date1Day && date2Hour == date1Hour && date2Minute >= date1Minute){
        return true
    }
    return false
}

/* define our own date class */
class Mydate : Codable {
    var month: Int
    var day: Int
    var year: Int
    var hour : Int
    var minute : Int
    
    // default set to current date
    init() {
        let cur_date = Date()
        let calendar = Calendar.current
        self.month = calendar.component(.month, from: cur_date)
        self.day = calendar.component(.day, from: cur_date)
        self.year = calendar.component(.year, from: cur_date)
        self.hour = calendar.component(.hour, from: cur_date)
        self.minute = calendar.component(.minute, from: cur_date)
    }
    
    // init with date in string
    init(month: String, day: String, year: String, hour: String, minute: String) {
        self.month = Int(month) ?? 1
        self.day = Int(day) ?? 1
        self.year = Int(year) ?? 2018
        self.hour = Int(hour) ?? 23
        self.minute = Int(minute) ?? 59
    }
    
    // convert the mydate object to a string
    func toString() -> String{
        let monthStr = String(self.month), dayStr = String(self.day), yearStr = String(self.year), hrStr = String(self.hour), minuteStr = String(self.minute)
        return monthStr + "-" + dayStr + "-" + yearStr + "-" + hrStr + "-" + minuteStr
    }
    static func ==(lhs : Mydate, rhs: Mydate) ->Bool{
        if(lhs.month == rhs.month && lhs.day == rhs.day &&
            lhs.year == rhs.year && lhs.hour == rhs.hour &&
            lhs.minute == rhs.minute){
            return true
        }
        return false
    }
}

/* define each task */
class Task : Codable {
    var title: String
    var due_date: Mydate
    var details: String
    var subtasks: [SubTask]
    var note: String
    
    init() {
        self.title = "Task title"
        self.due_date = Mydate()
        self.details = "Task details"
        self.subtasks = [SubTask]()
        self.note = "Quick note"
    }
    init(title : String, dueDate : Mydate, details : String){
        self.title = title
        self.due_date = dueDate
        self.details = details
        self.subtasks = [SubTask]()
        self.note = "Quick note"
    }
    static func ==(lhs : Task, rhs: Task) ->Bool{
        if(lhs.details == rhs.details && lhs.title == rhs.title &&
            lhs.due_date == rhs.due_date){
            return true
        }
        return false
    }
}

/* Defines the tasks in to do list, each to do list inherits from
   a scheduler task
 */
class SubTask: Codable{
    var taskName: String
    var isDone: Bool
    func SetTaskIsDone()
    {
        self.isDone = true
    }
    
    func SetTaskIsNotDone()
    {
        self.isDone = false
        
    }
    
    func TaskState() -> Bool
    {
        let state = self.isDone
        return state
    }
    
    func setTaskName(name: String)
    {
        self.taskName = name
    }
    
    func getTaskName() -> String
    {
        let name = self.taskName
        return name
    }
    
    init() {
        self.taskName = "Task"
        self.isDone = false
    }
    init(taskName: String, isDone: Bool) {
        self.taskName = "Task"
        self.isDone = false
    }
    
}


/* Schedule is a list of tasks */
class Schedule : Codable {
    var tasks: [Task]
    
    init() {
        self.tasks = [Task]()
    }
    init (ifGenerateTasks: Bool) {
        self.tasks = [Task]()
        if ifGenerateTasks {
            for _ in 0 ..< Int.random(in: 8 ..< 16) {
                self.tasks.append(Task())
            }
        }
    }
    func append(task : Task){
        self.tasks.append(task)
    }
    func sort(){
        self.tasks.sort(by: eventPriority)
    }
}

/* define each task for "TODAY" */
class dailyTask : Codable {
    var interval: String
    var note: String
    
    init() {
        self.interval = "10-12"
        self.note = "write App"
    }
    init(interval : String, note : String){
        self.interval = interval
        self.note = note
    }
}

/*Class that stores timer activity history*/
class TimerRecords: Codable{
    var records: [ATimerRecord]
    
    init(){
        self.records = []
    }
    func appendRecord(record: ATimerRecord){
        self.records.insert(record, at: 0) //insert at front
    }
    func clearRecords(){
        records = []
    }
}

/* Record the timer activity including date, time interval
   and whether timer is terminated or ends naturally
 */
class ATimerRecord: Codable{
    var status: Bool
    var startToEnd: String
    var title: String
    
    init(){
        self.status = false
        self.startToEnd = ""
        self.title = ""
    }
    init(status: Bool, startToEnd: String, title: String)
    {
        self.status = status
        self.startToEnd = startToEnd
        self.title = title
    }
}

/* Dailyplanner tasks */
class model: Codable {
    
    var dailyTasks:[dailyTask]
    func append(task: dailyTask){
        self.dailyTasks.append(task)
    }
    init() {
        self.dailyTasks = [dailyTask]()
    }
}

/*
 The whole schedule is stored locally on the phone.
 
 To get task:
 let myPhone = Storage.init()
 let allTasks = myPhone.get("allTasks")
 
 To set task:
 self.myPhone.setSchedule(key: "allTasks", value: self.schedule)
*/
class Storage {
    init(){
        
    }
    
    // for main schedule's storage
    func get(key : String) -> Schedule? {
        guard let data = UserDefaults.standard.value(forKey: key) as? Data else {
            return nil
        }
        guard let storedSchedule = try? PropertyListDecoder().decode(Schedule.self, from: data) else{
            return nil
        }
        return storedSchedule
    }
    func setSchedule(key : String, value : Schedule){
        UserDefaults.standard.set(try? PropertyListEncoder().encode(value), forKey: key)
    }
    
    // for daily planner's storage
    func getDailyTasks(key : String) -> model? {
        guard let data = UserDefaults.standard.value(forKey: key) as? Data else {
            return nil
        }
        guard let storedDailyTasks = try? PropertyListDecoder().decode(model.self, from: data) else{
            return nil
        }
        return storedDailyTasks
    }
    func setDailyTasks(key : String, value : model){
        UserDefaults.standard.set(try? PropertyListEncoder().encode(value), forKey: key)
    }
    
    // for timer's storage
    func getTimerRecords(key: String) -> TimerRecords? {
        guard let data = UserDefaults.standard.value(forKey: key) as? Data else {
            return nil
        }
        guard let storedTimerRecords = try? PropertyListDecoder().decode(TimerRecords.self, from: data) else{
            return nil
        }
       
        return storedTimerRecords
        
    }
    func setTimerRecords(key: String, value: TimerRecords){
        UserDefaults.standard.set(try? PropertyListEncoder().encode(value), forKey: key)
    }
}
