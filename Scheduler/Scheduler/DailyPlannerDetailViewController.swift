//
//  DailyPlannerDetailViewController.swift
//  DailyPlanner4
//
//  Created by Hanxing Zhang on 2018/11/19.
//  Copyright © 2018 Hanxing Zhang. All rights reserved.
//

import UIKit

protocol NoteViewDelegate {
    
    /*
     update when the start time and end time change
     */
    func didUpdateNoteWithTimeInterval(newTime : String, andBody newBody :
        String)
    
}


class DailyPlannerDetailViewController: UIViewController, UITextViewDelegate {
    
    private var datePickerStart: UIDatePicker?
    private var datePickerEnd: UIDatePicker?
    @IBOutlet weak var notesDetails: UITextView!
    @IBOutlet weak var timeLabel: UIBarButtonItem!
    var dataInDetailView:[String] = ["", ""]
    var startTimeString = ""
    var finishTimeString = ""
    var notesWritten = ""
    var edit = false
    var editIdx = -1
    var timeInterval = ""
    var notes = ""
    var models = model()
    var delegate : NoteViewDelegate?
 
    override func viewDidLoad() {
        super.viewDidLoad()
        if(timeInterval == "" ) {
            timeInterval = "00:00 to 23:59"
        }

        timeLabel.title = timeInterval
        var fullNameArr = timeInterval.components(separatedBy: " to ")
        if (fullNameArr.count == 2) {  self.startTimeString = fullNameArr[0]
            self.finishTimeString = fullNameArr[1]
        }

        notesDetails.text = notes

        // Do any additional setup after loading the view.
    }
    
    

    /*
     Receiving data from other view controllers using call back function
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // if users want to edit start time or end time
        if let destinationVC = segue.destination as? ChooseTimeViewController {
            destinationVC.callback = { timeInterval in
                var fullNameArr = timeInterval.components(separatedBy: " to ")
                if(fullNameArr.count == 2) {
                    self.startTimeString = fullNameArr[0]
                    self.finishTimeString = fullNameArr[1]
                    self.timeLabel.title = timeInterval
                } else { //make sure default is set
                    self.startTimeString = "00:00"
                    self.finishTimeString = "23:59"
                    self.timeInterval = self.startTimeString + " to " + self.finishTimeString
                    self.timeLabel.title = timeInterval
                }
            }
        }
    }
    
    
    /*
     if user doesn't want to save the task, return to daily planner main view
     */
    @IBAction func CancelView(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    /*
     save task in daily planner
     */
    @IBAction func saveDailyPlannerTask(_ sender: UIBarButtonItem) {
        let myPhone = Storage()
        let models = myPhone.getDailyTasks(key: "dailyTasks") ?? model()
        notesWritten = notesDetails?.text ?? ""
        
        let newDailyTask = dailyTask(interval: startTimeString+" to "+finishTimeString, note: notesWritten)
        if edit == false {
            models.append(task: newDailyTask)
            myPhone.setDailyTasks(key: "dailyTasks", value: models)
        } else {
            models.dailyTasks[editIdx] = newDailyTask
            myPhone.setDailyTasks(key: "dailyTasks", value: models)
        }
        if self.delegate != nil {
            dataInDetailView = [startTimeString+" to "+finishTimeString, notesWritten]
            
            self.delegate!.didUpdateNoteWithTimeInterval(
                newTime: startTimeString+" to "+finishTimeString, andBody: notesWritten)
            
        }
        self.dismiss(animated: true, completion: nil)
    }
}

/*
 * This class handles the picker view to select time interval VC in daily planner
 */
class ChooseTimeViewController: UIViewController{
    
    private var datePickerStart: UIDatePicker?
    private var datePickerEnd: UIDatePicker?
    @IBOutlet weak var startTimeTextfield: UITextField!
    @IBOutlet weak var endTimeTextfield: UITextField!
    
    /*
     *dismiss current view
     */
    @IBAction func dismissView(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
     *submit user selected time interval
     */
    @IBAction func submitView(_ sender: UIBarButtonItem) {
        if(startTimeString == "") {
            startTimeString = "00:00"
        }
        
        if(finishTimeString == "") {
            finishTimeString = "23:59"
        }
        
        let numStart = Int(startTimeString.replacingOccurrences(of: ":", with: "")) ?? 0
        let numEnd = Int(finishTimeString.replacingOccurrences(of: ":", with: "")) ?? 0
        
        if((numStart - numEnd) > 0) {
            let temp = startTimeString
            startTimeString = finishTimeString
            finishTimeString = temp
        } //Order interval so first is earlier than second
        
        timeInterval = startTimeString + " to " + finishTimeString
        callback?(timeInterval)
        self.dismiss(animated: true, completion: nil) //dismiss current VC
    }
    
    //callback function to pass data between two controllers
    var callback : ((String) -> Void)?
    var startTimeString = ""
    var finishTimeString = ""
    var timeInterval = ""
   
    

    /*
     *Add gestureRecognizer for tapping on textfield
     */
    @objc func viewTapped(gestureRecognizer: UITapGestureRecognizer){
        view.endEditing(true)
    }
    
    /*
     * This will be called when user changed the value of the first picker
     */
    @objc func dateChangedStart(datePicker: UIDatePicker){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        let strDate = dateFormatter.string(from: datePicker.date)
        startTimeTextfield.text  = strDate //reflect time in textfield
       
        // 24 hour format
        dateFormatter.dateFormat = "HH:mm"
        let date24 = dateFormatter.string(from: datePicker.date)
        startTimeString = date24
    }
    
    /*
     * This will be called when user changed the value of the second picker
     */
    @objc func dateChangedEnd(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        let strDate = dateFormatter.string(from: datePicker.date)
        endTimeTextfield.text  = strDate
        
        // 24 hour format
        dateFormatter.dateFormat = "HH:mm"
        let date24 = dateFormatter.string(from: datePicker.date)
        finishTimeString = date24
    }
    
    /*
     * Initialize first textfield value so even user did not do any change on date picker, some value will be reflected in textfield.
     */
    func timetextfieldInitStart() {
        // return current time and date
        let date = Date()
        let dateFormatter = DateFormatter()
        // for specifying the change to format hour:minute am/pm.
        dateFormatter.dateFormat = "h:mm a"
        startTimeTextfield.text = dateFormatter.string(from: date)
        dateFormatter.dateFormat = "HH:mm"
        let date24 = dateFormatter.string(from: date)
        startTimeString = date24
    }
    
    /*
     * Same as above, for second textfield
     */
    func timetextfieldInitEnd() {
        // return current time and date
        let date = Date()
        let dateFormatter = DateFormatter()
        // for specifying the change to format hour:minute am/pm.
        dateFormatter.dateFormat = "h:mm a"
        endTimeTextfield.text = dateFormatter.string(from: date)
        dateFormatter.dateFormat = "HH:mm"
        let date24 = dateFormatter.string(from: date)
        finishTimeString = date24
    }


    
    override func viewDidLoad() {
        super.viewDidLoad()
        timetextfieldInitStart()
        timetextfieldInitEnd() //Initialize textfields
        
        //Parse the timeInterval spring to get first and second time
        var fullNameArr = timeInterval.components(separatedBy: " to ")
        if(fullNameArr.count == 2) {
            if(fullNameArr[0] != "") {
                startTimeTextfield.text = fullNameArr[0]
            }
            if(fullNameArr[0] == "") {
                endTimeTextfield.text = fullNameArr[1]
            }

        }
        
        //Add inputView on textfields
        datePickerStart  = UIDatePicker()
        datePickerStart?.datePickerMode = UIDatePicker.Mode.time
        datePickerStart?.addTarget(self, action: #selector(ChooseTimeViewController.dateChangedStart(datePicker:)), for: .valueChanged)
        
        datePickerEnd  = UIDatePicker()
        datePickerEnd?.datePickerMode = UIDatePicker.Mode.time
        datePickerEnd?.addTarget(self, action: #selector(ChooseTimeViewController.dateChangedEnd(datePicker:)), for: .valueChanged)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ChooseTimeViewController.viewTapped(gestureRecognizer: )))
        
        view.addGestureRecognizer(tapGesture)
        startTimeTextfield.inputView = datePickerStart
        endTimeTextfield.inputView = datePickerEnd
        timeInterval = startTimeString + " to " + finishTimeString

        // Do any additional setup after loading the view.
    }
    

}
