//
//  addTask.swift
//
//  Created by Sunil Ramakrishnan on 11/25/18.
//  Copyright © 2018 Sunil Ramakrishnan. All rights reserved.
//

import UIKit

/*
 from
 https://stackoverflow.com/questions/24092884/get-nth-character-of-a-string-in-swift-programming-language/38215613#38215613
 allows me to do c style access to string
 */
extension StringProtocol {
    
    var string: String { return String(self) }
    
    subscript(offset: Int) -> Element {
        return self[index(startIndex, offsetBy: offset)]
    }
    
    subscript(_ range: CountableRange<Int>) -> SubSequence {
        return prefix(range.lowerBound + range.count)
            .suffix(range.count)
    }
    subscript(range: CountableClosedRange<Int>) -> SubSequence {
        return prefix(range.lowerBound + range.count)
            .suffix(range.count)
    }
    
    subscript(range: PartialRangeThrough<Int>) -> SubSequence {
        return prefix(range.upperBound.advanced(by: 1))
    }
    subscript(range: PartialRangeUpTo<Int>) -> SubSequence {
        return prefix(range.upperBound)
    }
    subscript(range: PartialRangeFrom<Int>) -> SubSequence {
        return suffix(Swift.max(0, count - range.lowerBound))
    }
}
extension Substring {
    var string: String { return String(self) }
}

class addTask: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    var editIdx : Int?
    var edit = false
    let dateFormatter = DateFormatter()
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var outputMessage: UILabel!
    @IBOutlet weak var dateField: UIDatePicker!
    @IBOutlet weak var detailViewField: UITextView!
    
    @IBAction func goToDetails(_ sender: UIBarButtonItem) {
        guard let textColor = titleField.textColor, let title = titleField.text else{
            return
        }
        if(textColor == .lightGray || title.count == 0){
            outputMessage.text = "Please Enter a Title"
            return
        }else{
            dateFormatter.dateFormat = "MM-dd-yyyy-HH-mm"
            let date = dateFormatter.string(from: dateField.date)
            //UPDATE: let time = dateFormatter.string(from: dateTimeField.date)
            let month = String(date[0..<2])
            let day = String(date[3..<5])
            let year = String(date[6..<10])
            let hour =  "23"//String(time[11..<13])
            let minute = "59"//String(time[14..<16])
            let dateInfo = Mydate.init(month: month, day: day, year: year, hour: hour, minute: minute)
            guard let taskTitle = titleField.text, var taskDetails = detailViewField.text else{
                return
            }
            guard let taskDetailColor = detailViewField.textColor else{
                return
            }
            // don't want placeholder val
            if(taskDetailColor == .lightGray){
                taskDetails = ""
            }
            updateStorage(taskTitle: taskTitle, taskDetails: taskDetails, taskDueDate: dateInfo)
        }
    }
    // manually set border colors and width and create placeholder for enter details
    override func viewDidLoad() {
        super.viewDidLoad()
        titleField.delegate = self
        detailViewField.delegate = self
        detailViewField.textColor = .lightGray
        detailViewField.text = "Please enter (optional) details"
        outputMessage.text = "Scroll to select due date"
        titleField.textColor = .lightGray
        titleField.text = "Please enter a Title"
        
        let myPhone = Storage.init()
        if(edit){
            guard let idx = editIdx else{
                return
            }
            guard let existingTasks = myPhone.get(key: "allTasks") else{
                return
            }
            let title = existingTasks.tasks[idx].title
            titleField.text = title
            let details = existingTasks.tasks[idx].details
            detailViewField.text = details
            let dateStr = existingTasks.tasks[idx].due_date.toString()
            dateFormatter.dateFormat = "MM-dd-yyyy-HH-mm"
            guard let formattedDate = dateFormatter.date(from: dateStr) else{
                return
            }
            dateField.setDate(formattedDate,animated: false)
            //UPDATE: dateTimeField.setDate(formattedDate, animated: false)
            if(details.count > 0){
                detailViewField.textColor = .black
            }else{
                detailViewField.textColor = .lightGray
                detailViewField.text = "Please enter (optional) details"
            }
            if(title.count > 0){
                titleField.textColor = .black
            }else{
                titleField.textColor = .lightGray
                titleField.text = "Please enter a Title"
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func inSchedule( existingTask : Task, _ newTask : Task) ->Bool{
        if(newTask == existingTask){
            return true
        }
        return false
    }
    
    func notInSchedule( existingTasks : [Task], _ newTask : Task) ->Bool{
        for oldTask in existingTasks{
            if(oldTask == newTask){
                return false
            }
        }
        return true
    }
    
    func updateStorage(taskTitle : String, taskDetails : String, taskDueDate : Mydate){
        let myPhone = Storage.init()
        var existingTasks : Schedule
        if let newTasks = myPhone.get(key : "allTasks"){
            existingTasks = newTasks
        }else{
            existingTasks = Schedule.init()
        }
        if(edit){
            guard let idx = editIdx else{
                return
            }
            let newTask = Task.init(title : taskTitle, dueDate : taskDueDate, details : taskDetails)
            for(index,existingTask) in existingTasks.tasks.enumerated(){
                if(idx != index && inSchedule(existingTask: existingTask, newTask)){
                    outputMessage.text = "Task already exist"
                    return
                }
            }
            existingTasks.tasks[idx].title = taskTitle
            existingTasks.tasks[idx].due_date = taskDueDate
            existingTasks.tasks[idx].details = taskDetails
            existingTasks.sort()
            myPhone.setSchedule(key: "allTasks", value: existingTasks)
            //outputMessage.text = "Task is updated"
            outputMessage.text = "Task is updated, tap back to exit"
        }else{
            let newTask = Task.init(title : taskTitle, dueDate : taskDueDate, details : taskDetails)
            if(notInSchedule(existingTasks: existingTasks.tasks,newTask)){
                existingTasks.append(task: newTask)
                existingTasks.sort()
                myPhone.setSchedule(key: "allTasks", value: existingTasks)
                outputMessage.text = "Task is created, tap back to exit"
                self.dismiss(animated: true, completion: nil)
            }else{
                outputMessage.text = "Task already exist"
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
        guard var currText = titleField.text else{
            return false
        }
        if(string.count == 0 && currText.count > 0){
            currText.removeLast()
        }else if(string.count == 1){
            currText += string
        }else{
            while(currText.count > 0 && currText[currText.count - 1] != " "){
                currText.removeLast()
            }
            currText += string
        }
        titleField.text = currText
        return false
    }
    
    func textView(_ texView: UITextView, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
        guard var currText = detailViewField.text else{
            return false
        }
        if(string.count == 0 && currText.count > 0){
            currText.removeLast()
        }else if(string.count == 1){
            currText += string
        }else{
            while(currText.count > 0 && currText[currText.count - 1] != " "){
                currText.removeLast()
            }
            currText += string
        }
        detailViewField.text = currText
        return false
    }
    func textViewDidBeginEditing(_ textView: UITextView){
        if (textView.text == "Please enter (optional) details" && textView.textColor == .lightGray){
            textView.text = ""
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView){
        if (textView.text == ""){
            textView.text = "Please enter (optional) details"
            textView.textColor = .lightGray
            outputMessage.text = "Scroll to pick due date"
        }else{
            textView.textColor = .black
        }
    }
    func textFieldDidBeginEditing(_ textField: UITextField){
        if (textField.text == "Please enter a Title" && textField.textColor == .lightGray){
            textField.text = ""
            textField.textColor = .black
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField){
        if (textField.text == ""){
            textField.text = "Please enter a Title"
            textField.textColor = .lightGray
            outputMessage.text = "Scroll to select due date"
        }else{
            textField.textColor = .black
        }
    }
}
