//  TimerSceneViewController
//  Handle VC classes associated with the timer scene
//  Created by Yanxi Li
//  Copyright © 2018 Yanxi Li. All rights reserved.


import UIKit
import UserNotifications

/*
 * This controller handles the timer view
 */
class TimerViewController: UIViewController {

    var min = 0
    var seconds = 0
    var timer = Timer()
    var startPressed = false
    var terminatePressed = false
    var duration = 0 //user selected time interval
    var timeexiting = 0 //record time when user enters backgroungd
    var timeBack = 0 //record time when user enters foreground
    var currentTime = 0 //current time, being updated every second
    var stopTime = 0 //real time when timer should stop (hour minute second)
    var startTime = 0 //the time when timer started
    var myPhone = Storage()
    var Records = TimerRecords()
    var startTimeString: String = "" //When user starts a timer
    var stopTimeString: String  = "" //When user stops a timer
    var taskTitle :String = "" //user defined title
    var dateString = "" //currentDate in string
    var islockScreen = false //only determined by when protected data becomes available, not accurate but tried my best
    var timerEnd = false //if timer has end
    var hideMessage = false //if user hit 'don't show again' to sheetAlert
   
   
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var timerScroller: UISlider!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var startButton: UIBarButtonItem!
    @IBOutlet weak var progressImage: UIImageView!
    @IBOutlet weak var InfoButton: UIBarButtonItem!
     
    /*
     * Update image based on timer progress
     */
    func updateImage(){
        let interval = Int(duration / 4)
        let Image: UIImage = UIImage(named: "1.png")!
        progressImage.image = Image
     
        if (seconds <= 1)
        {
            let Image: UIImage = UIImage(named: "6.png")!

            progressImage.image = Image
        }
        else if(seconds <= duration - 3 * interval)
        {
            let Image: UIImage = UIImage(named: "5.png")!
            progressImage.image = Image
        }

        else if (seconds <= duration - 2 * interval)
        {
            let Image: UIImage = UIImage(named: "3.png")!
            progressImage.image = Image
        }
            
        else if (seconds <= duration - interval)
        {
            let Image: UIImage = UIImage(named: "2.png")!
            progressImage.image = Image
        }
            
        else
        {
            let Image: UIImage = UIImage(named: "1.png")!
            progressImage.image = Image
        }
        
    } // call this function where you want to set image.
   
    
    
    func updateSlider()
    {
       let fractialTime =  Float(seconds) / Float(duration) //scale to 1
       progressBar.setProgress(fractialTime, animated: true)
       self.view.layoutIfNeeded()
    }
    
    /*
     * handles slider scrolling events
     */
    @IBAction func timeSliderAction(_ sender: UISlider) {
            if (startPressed == false){
                sender.isUserInteractionEnabled = true //enable slider
                min = Int(sender.value) //read scroll bar value
                seconds = min * 60
                duration = seconds
                //reflect selected value on time label
                timeLabel.text = timeString(time: TimeInterval(seconds))
                //animation smooth on ios8 but not after ios10
                UIView.animate(withDuration: 0.2, animations: {
                    self.timerScroller.setValue(sender.value, animated:true)
                    self.view.layoutIfNeeded()
            })
        }
        
    }
    
    /*
     * This alert lets people to give a tag to the record before the timer ends
     */
    func AddTitleAlert(){
        let alertController = UIAlertController(title: "What's the task?", message: "You can enter an optional tag for your timer record", preferredStyle: UIAlertController.Style.alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            if(self.taskTitle != ""){
                textField.placeholder = self.taskTitle
            }
            else{
                textField.placeholder = "Please enter"
            }
        }
        
        //save textfield content
        let saveAction = UIAlertAction(title: "Done", style: UIAlertAction.Style.default, handler: {alert -> Void in
            let UserTextField = alertController.textFields![0] as UITextField
            self.taskTitle = UserTextField.text?.capitalized ?? ""
            print("1 \(self.taskTitle)")
            //only save if textfield is not empty

        })
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: {
            (action : UIAlertAction!) -> Void in })
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    /*
     * When add tag button pressed, show alert
     */
    @IBAction func addTag(_ sender: UIBarButtonItem) {
        AddTitleAlert()
    }
    
    /*
     * This handles when user press start to start timer
     */
    @IBAction func StartButtonAction(_ sender: UIBarButtonItem){
        
        //Add sheet to remind user how timer works
        let sheet = UIAlertController(title: "Friendly reminder", message: "Timer will be interrupted once you have left Scheduler for more than 10 seconds", preferredStyle: UIAlertController.Style.actionSheet
        )
        let ActionCancel = UIAlertAction(title: "OK", style: .cancel){(_) in
        }
        let ActionHide = UIAlertAction(title: "Don't show again", style: .destructive){ (alert) -> Void in
            self.hideMessage = true
            }
        
        sheet.addAction(ActionCancel)
        sheet.addAction(ActionHide)
       
        //if scroll bar is set to 0, do nothing
        if (duration == 0)
        {
            return
        }
        
        //If timer ends naturally, reset image to initial state
        if(startButton.title == "continue")
        {
            let Image: UIImage = UIImage(named: "1.png")!
            progressImage.image = Image
            
        }
       
        //When tart is pressed
        if(startPressed == false)
        {
            timerEnd = false
            if(hideMessage == false){
                self.present(sheet, animated: true, completion: nil)
            }
            
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: Date())
            let minutes = calendar.component(.minute, from: Date())
            let second = calendar.component(.second, from: Date())
            startTime = 3600*hour + 60*minutes + second //record start time
            let date = Date() // return current time and date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "h:mm a" //format hour:minute am/pm.
            let timeString = dateFormatter.string(from: date)
            dateFormatter.dateStyle = .medium //Show Month in words
            dateString = dateFormatter.string(from: date)
            startTimeString = dateString + " " + timeString
            timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(TimerViewController.updateTimer)), userInfo: nil, repeats: true) //Start timer
            
            //change scroll bar to progress bar
            timerScroller.isHidden = true
            progressBar.isHidden = false
            
            //toggle start/terminate state
            startPressed = true
            terminatePressed = true
            return
            
        }
        
        //When terminate is pressed, this function is depricated in final project
        //After adding self-control, terminating timer after it starts it partially prohibited
        //However leave the code here for testing
        if(terminatePressed == true)
        {
            timer.invalidate()
            progressBar.isHidden = true
            startButton.title = "start"
            startPressed = false
            terminatePressed = false
            seconds = 0
            duration = 0
            timeLabel.text = timeString(time: TimeInterval(seconds))
            timerScroller.setValue(0, animated: true)
            timerScroller.isHidden = false
            return
            
        }
    
    
    }
    /*
     * Format time to string
     */
    func timeString(time:TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
    
    /*
     * Method to update the timer when it starts
     * Using current time and timer started time difference to compare
     * More reliable than decrementing a integer and can reflect true time interval in when inactive in background
     */
    @objc func updateTimer()
    {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: Date())
        let minutes = calendar.component(.minute, from: Date())
        let second = calendar.component(.second, from: Date())
        currentTime = hour * 3600 + minutes * 60 + second
        seconds = duration - (currentTime - startTime)
        //seconds is from user selected time to 0
        
        //if timer is still running
        if (seconds != 0)
        {
            //Allow user to cancel timer in the first 10 seconds so it won't record as interrupt
            if((currentTime - startTime) < 10)
            {
                startButton.title = "Cancel (\(10 - (currentTime - startTime)))"
            }
            
            //Hide the cancel button
            else{
                //timerEnd = true
                startButton.title = ""
                startButton.isEnabled = false
            }
            
            
            //Update scroller and image based on current timer progress
            let currentTimeInMinuite = Int(seconds / 60)
            
            timerScroller.setValue(Float(currentTimeInMinuite), animated: true)
            updateImage()
            updateSlider()
            timerScroller.isHidden = true
            progressBar.isHidden = false
            timeLabel.text = timeString(time: TimeInterval(seconds))
        }
        
        //Timer should be end by now
        if(seconds <= 0)
        {
            //timerScroller.isHidden = false
            progressBar.isHidden = true
            timer.invalidate()
            seconds = 0
            timeLabel.text = timeString(time: TimeInterval(seconds))
            
            //User did not leave app for the whole time interval
            if(duration != 0)
            {
                SuccessSheet() //Present Success Message
                //Configure the scene to its initial states
                //Save the record to timer records
                startButton.isEnabled = true
                startButton.title = "Continue"
                timerEnd = true
                let date = Date() // return current time and date
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "h:mm a" // for specifying the change to format hour:minute am/pm.
                stopTimeString = dateFormatter.string(from: date)
                let startToEnd = startTimeString + " - " + stopTimeString
                let aTimerRecord = ATimerRecord.init(status: true, startToEnd: startToEnd, title: taskTitle)
                self.myPhone = Storage.init()
                self.Records =  myPhone.getTimerRecords(key: "records") ?? TimerRecords.init()
                Records.appendRecord(record: aTimerRecord)
                myPhone.setTimerRecords(key: "records", value: Records)
                taskTitle = ""
                
            }//if
            
        }//if
        
    }//end of function
    
  
    /*
     * Defining the sucess sheet
     */
    func SuccessSheet(){
            let sheet = UIAlertController(title: "Time's up", message: "You have been focused for \(duration/60) minute(s). You can check your new record in Records", preferredStyle: UIAlertController.Style.actionSheet
            )
            
            let ActionCancel = UIAlertAction(title: "OK", style: .cancel){(_) in
                
            }
        
            sheet.addAction(ActionCancel)
            self.present(sheet, animated: true, completion: nil)
    }
    
    /*
     *If app enters background, remind user the timer might be killed by notification.
     *However, detecting lock screen only works if user use password, faceID,
     *fingerprints to protect data. There is no good way to detect lock screen
     *accurately without using private API which apple prohibits.
     *Users can by pass interruption in some situations even when
     *they leave the app for longer than 10s (for example, leave the screen for longer time and then lock the screen since the protectedwillbecomeunavailable sometimes are not called even when screen locks.
     */
    func sendNotificationWhenInterrupted()
    {
        let content = UNMutableNotificationContent()
        content.title = "Timer might interrupt"
        content.body = "Go back soon to avoid interuption. Don't worry if you just lock the screen."
        content.badge = 0
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "timerDone", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    

    /*
     * Notification when app goes to foreground
     */
    @objc func appMoveToForeground(){
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: Date())
        let minutes = calendar.component(.minute, from: Date())
        let second = calendar.component(.second, from: Date())
        timeBack = 3600*hour + 60*minutes + second //record when app is active again
        //print(islockScreen)
        if(islockScreen == true)
        {
            //if screen just unlocked, reset the timeexiting to current so timer will be not killed
            timeexiting = timeBack
            islockScreen = false
        }
       
        //Be sure timer is in ongoing state
        if(startPressed == true){
        
        //Timer is killed because user leaves screen for more than 10s
        if(timeBack - timeexiting > 10){
            
            //save record to records and mark as interrupted
            let date = Date() // return current time and date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "h:mm a"
            stopTimeString = dateFormatter.string(from: date)
            let startToEnd = startTimeString + " - " + stopTimeString
            
            let aTimerRecord = ATimerRecord.init(status: false, startToEnd: startToEnd, title: taskTitle)
            self.myPhone = Storage.init()
            self.Records =  myPhone.getTimerRecords(key: "records") ?? TimerRecords.init()

            Records.appendRecord(record: aTimerRecord)
            myPhone.setTimerRecords(key: "records", value: Records) //update storage
            
            //Configue the scene to go back to initial state
            startButton.isEnabled = true
            startButton.title = "Start"
            timer.invalidate()
            seconds = 0
            progressBar.isHidden = true
            startPressed = false
            terminatePressed = false
            duration = 0
            timeLabel.text = timeString(time: TimeInterval(seconds))
            timerScroller.setValue(0, animated: true)
            timerScroller.isHidden = false
            taskTitle = ""
 
            }
            
        }
        
    }
    
    /*Listen to when user protected data become available to infer a
     *possible unlock screen event, reliable when user has set some
     *passcode.
     */
    @objc func UserUnlockScreen(){
        islockScreen = true
        //print("unlock")
    }
    
    /*
     *Listen to when user protected data will become unavailable to infer a possible lock screen
     *event, unreliable even user set passcode, notification is not sent everytime screen is
     *locked
     */
    @objc func UserHitLockScreen()
    {
       islockScreen = true
       //print("lock screen hit")
 
    }
    
    /*
     *When app resign active, record when that happens, and send user notifications to remind
     *them when time will be killed
     */
    @objc func appMovedToBackground() {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: Date())
        let minutes = calendar.component(.minute, from: Date())
        let second = calendar.component(.second, from: Date())
        timeexiting = 3600*hour + 60*minutes + second
        if(startPressed == true && islockScreen == false && timerEnd == false)
        {
            sendNotificationWhenInterrupted()
        }
        
    }
        
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.myPhone = Storage.init()
        self.Records =  myPhone.getTimerRecords(key: "records") ?? TimerRecords.init()
        
        progressBar.isHidden = true
        //Add notificationCenter observers to listen to events.
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appMoveToForeground), name: UIApplication.didBecomeActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(UserHitLockScreen), name: UIApplication.protectedDataWillBecomeUnavailableNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(UserUnlockScreen), name: UIApplication.protectedDataDidBecomeAvailableNotification, object: nil)
    }



}

/* This controller handles the help button view */
class PopUpHelpViewController: UIViewController{
    
    
    @IBOutlet weak var dismissButton: UIBarButtonItem!
    
    @IBAction func dismissButtonAction(_ sender: UIBarButtonItem) {
       
        self.dismiss(animated: true, completion: nil)
        //dismiss when back is hit
    }
    
    
    
}

/* This controller handles the help button view for to do list, should be moved
 * under todolist file
 */
class PlannerPopUpHelpViewController: UIViewController{
    
    
    @IBOutlet weak var dismissButton: UIBarButtonItem!
    
    @IBAction func dismissButtonAction(_ sender: UIBarButtonItem) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
}


/*
 * This view handles the view controller that displays timer records using table view
 */
class TableViewToDisplayRecordsVC: UIViewController,UITableViewDataSource, UITableViewDelegate{
    
    var myPhone = Storage()
    var Records = TimerRecords()
    
    
    @IBAction func clearRecords(_ sender: UIBarButtonItem) {
        infoAlert()
        //show alert when clear is hit
    }
    
    /* Alert to clear all records */
    func infoAlert(){
        if (Records.records.count != 0){
            let sheet = UIAlertController(title: "Clear your list", message: "This will delete all your records.", preferredStyle: UIAlertController.Style.actionSheet
            )
            let ActionYes =  UIAlertAction(title: "Clear", style: .default){ (action) in
                self.Records.records = []
                self.myPhone.setTimerRecords(key: "records", value: self.Records)
                self.tableView.reloadData()
            }
            
            let ActionCancel = UIAlertAction(title: "Cancel", style: .cancel){(_) in
                
            }
            
            sheet.addAction(ActionYes)
            sheet.addAction(ActionCancel)
            self.present(sheet, animated: true, completion: nil)
            
        }
            
        else{
            
            let sheet = UIAlertController(title: "Reminder", message: "Your record is already empty.", preferredStyle: UIAlertController.Style.actionSheet
            )
            
            let ActionCancel = UIAlertAction(title: "Ok", style: .cancel){(_) in
                
            }
            
            sheet.addAction(ActionCancel)
            self.present(sheet, animated: true, completion: nil)
            
        }
    }
    
  
    /*Tableview delegates*/
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(Records.records.count == 0 )
        {
            return 0 //guard
        }
        return Records.records.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        if (Records.records.count == 0)
        {
            //No Cell Guard
            return UITableViewCell()
        }
        
        //Assign value to cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "recordCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "recordCell")
        let record = Records.records[indexPath.row]
       
        cell.textLabel?.text = record.title
        cell.detailTextLabel?.text = record.startToEnd
        
        //Add record status to string
        if(record.status == true)
        {
            cell.detailTextLabel?.text = record.startToEnd + ", complete"
        }
        
        else{
               cell.detailTextLabel?.text = record.startToEnd + ", interrupted"
        }
        
        return cell
        
    }
    
   
    @IBOutlet weak var tableView: UITableView!
    
    /*Dismiss current view, go back to timer*/
    @IBAction func backtoTimer(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.myPhone = Storage.init()
        self.Records =  myPhone.getTimerRecords(key: "records") ?? TimerRecords.init()
        tableView.dataSource = self
        tableView.delegate = self
    }
}
