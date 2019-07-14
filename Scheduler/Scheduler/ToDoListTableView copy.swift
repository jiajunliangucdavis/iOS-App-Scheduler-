//
//  ToDoListView.swift
//  This file contains VC classes for scenes associated with the to do list
//  Created by Yanxi Li
//  Copyright © 2018年 Yanxi Li. All rights reserved.
//


import Foundation
import UIKit

/*Add a protocol to handle the checkbox check and uncheck*/
protocol ToggleCheckBox{
    
    func ToggleCheckBox(state: Bool, index: Int?)
    
}

/* Customized Cells */
class ToDoListCell: UITableViewCell,UITextFieldDelegate{
    var indexPath: Int?
    var SubTasks: [SubTask]?
    var CBdelegate: ToggleCheckBox?
  

    @IBOutlet weak var UserTaskName: UILabel!
    @IBOutlet weak var CheckBoxImage: UIButton!
    
    
    //Set Check, UnCheck state
    @IBAction func ClickOnCheckBox(_ sender: UIButton) {
       
        let task = SubTasks?[indexPath ?? 0] ?? nil
        if(task == nil){
            print("isNil")
            return
            
        }//if
        
        else{
            if(task?.TaskState() == true)
            {
                //print("toggleToFalse")
                CBdelegate?.ToggleCheckBox(state: true, index: indexPath)
            }//if
            
            else{
                //print("toggleToTrue")
                CBdelegate?.ToggleCheckBox(state: false, index: indexPath)
            }//else
        }//else
    }//func
}//class


/* To do list View Controller*/
class ToDoListViewController: UIViewController,UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, ToggleCheckBox{
    
    var schedule = Schedule()
    var myPhone = Storage()
    var editingTaskIndex = 0 //current editing cell
    var selectedIndexPath: IndexPath? = nil
    var SubTasks: [SubTask] = []
    
    @IBOutlet weak var addNewCellButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var CellToolBar: UIToolbar!
    @IBOutlet weak var DeleteCellButton: UIBarButtonItem!
    
    
    
    /* textfield delegate*/
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    /* Remind user if they want to clear a list or is already empty*/
    func infoAlert(){
        if (SubTasks.count != 0){
            let sheet = UIAlertController(title: "Clear your list", message: "This will delete all your tasks.", preferredStyle: UIAlertController.Style.actionSheet
            )
            
            //Erase stored to-do list tasks
            let ActionYes =  UIAlertAction(title: "Clear", style: .default){ (action) in
                self.SubTasks = []
                self.CellToolBar.isHidden = true
                self.schedule.tasks[self.editingTaskIndex].subtasks = self.SubTasks
                self.myPhone.setSchedule(key: "allTasks", value: self.schedule)
                self.tableView.reloadData()
            }
            
            let ActionCancel = UIAlertAction(title: "Cancel", style: .cancel){(_) in
                
            }
            
            sheet.addAction(ActionYes)
            sheet.addAction(ActionCancel)
            self.present(sheet, animated: true, completion: nil)
        
        }
        
        else{
       
            let sheet = UIAlertController(title: "Reminder", message: "Your list is already empty.", preferredStyle: UIAlertController.Style.actionSheet
            )
          
            let ActionCancel = UIAlertAction(title: "Ok", style: .cancel){(_) in
                
            }
        
            sheet.addAction(ActionCancel)
            self.present(sheet, animated: true, completion: nil)
        
        }
    }
    
  
    /*
     *Use alert to provide ask field and edit
     *Use textfield in alert to edit cell name
     */
    @IBAction func EditCellName(_ sender: UIBarButtonItem) {
        if(selectedIndexPath == nil){
            return
        }
        let task  = SubTasks[(selectedIndexPath?.row) ?? 0]
        let alertController = UIAlertController(title: "Edit Task", message: "", preferredStyle: UIAlertController.Style.alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            if(task.getTaskName() == "untitled"){
            textField.placeholder = "Enter task name"
            }
            else{
                textField.placeholder = task.getTaskName() //Provide a placeholder of current task name
            }
        }
        let saveAction = UIAlertAction(title: "Done", style: UIAlertAction.Style.default, handler: {
            alert -> Void in
            let UserTextField = alertController.textFields![0] as UITextField
            task.setTaskName(name: UserTextField.text ?? "untitled")
            //only save if textfield is not empty
            if(task.getTaskName() != "")
            {
        
                self.SubTasks[self.selectedIndexPath?.row ?? 0] = task
            self.CellToolBar.isHidden = true
            self.selectedIndexPath = nil
            self.schedule.tasks[self.editingTaskIndex].subtasks = self.SubTasks
            self.myPhone.setSchedule(key: "allTasks", value: self.schedule)
            
            self.tableView.reloadData() //reload tableview since data changed
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: {
            (action : UIAlertAction!) -> Void in })
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
        

    
        
    }
    
    /*
     * Similar to the edit cell, add new cell use textfield and ui alert to ask for inputs
     * When user did not enter anything, cell won't be added
     */
    @IBAction func addNewCell(_ sender: UIBarButtonItem) {
        let task = SubTask()
        let alertController = UIAlertController(title: "Add Task", message: "", preferredStyle: UIAlertController.Style.alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter task name:"
            
        }
        let saveAction = UIAlertAction(title: "Done", style: UIAlertAction.Style.default, handler: { alert -> Void in
            let UserTextField = alertController.textFields![0] as UITextField
            task.setTaskName(name: UserTextField.text ?? "untitled")
            if(task.getTaskName() != "")
            {
                
            
            self.SubTasks.append(task)
            self.CellToolBar.isHidden = true
            self.selectedIndexPath = nil
            self.schedule.tasks[self.editingTaskIndex].subtasks = self.SubTasks
            self.myPhone.setSchedule(key: "allTasks", value: self.schedule)
            self.tableView.reloadData()
            }
            
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: {
            (action : UIAlertAction!) -> Void in })
       
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
        
        
      
        
    }
    
    
    /*
     * Allow swipte to delete and remind user using alert
     */
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let alertController = UIAlertController(title: "Delete task", message: "Are you sure you wish to delete this task?", preferredStyle: UIAlertController.Style.alert)
        let deleteAction = UIAlertAction(title: "Delete", style: UIAlertAction.Style.default, handler: {
            (action : UIAlertAction!) -> Void in
            if (editingStyle == UITableViewCell.EditingStyle.delete)
            {
                //Update TableView, Remove corresponding cell
                tableView.deselectRow(at: indexPath, animated: true)
                self.selectedIndexPath = nil
                self.SubTasks.remove(at: indexPath.row)
                
                self.CellToolBar.isHidden = true
            }
            
            if(self.SubTasks.count == 0)
            {
                //Hide cell tool bar when no cell is presented
                self.CellToolBar.isHidden = true
            }
            self.schedule.tasks[self.editingTaskIndex].subtasks = self.SubTasks
            self.myPhone.setSchedule(key: "allTasks", value: self.schedule)
            tableView.reloadData()
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: {
            (action : UIAlertAction!) -> Void in })
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
       
    }
    
    /* Trash button to delete all cells */
    @IBAction func DeleteAllCells(_ sender: UIBarButtonItem){
         infoAlert()
    
    }
    
    /* Num of table view cell */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SubTasks.count
    }
    
    /*
     * Allow select and deselect effect for table view cell (actually not necessary but experimenting if it can be
     * acheived.
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedIndexPath == indexPath {
            // cell was already selected
            //print("deselect")
            CellToolBar.isHidden = true
            selectedIndexPath = nil
            tableView.deselectRow(at: indexPath, animated: false)
        } else {
            //print("select")
            // first time cell was selected, save index
            selectedIndexPath = indexPath
            CellToolBar.isHidden = false
        }
     
    }
    
    /*
     * Write the delegate of toggleCheckBox
     */
    func ToggleCheckBox(state: Bool, index: Int?) {
        if (index == nil)
        {
            //print("IndexNil")
            return
        }
    
        if (SubTasks.count != 0){
        
            selectedIndexPath = nil //do not select cell when toggling the checkBox
            self.CellToolBar.isHidden = true //edit not allowd
            //print("current\(state)")
            state ? SubTasks[index!].SetTaskIsNotDone() : SubTasks[index!].SetTaskIsDone() //set state based on state value
            //print("after:\(SubTasks[index!].TaskState())")
            self.schedule.tasks[self.editingTaskIndex].subtasks = self.SubTasks
            self.myPhone.setSchedule(key: "allTasks", value: self.schedule) //store
            tableView.reloadRows(at: [IndexPath(row: index!, section: 0)], with: UITableView.RowAnimation.none)
        }
    }
    
    
     /* dequeue cells at row */
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoListCell", for: indexPath) as! ToDoListCell
        let OneSubTask = SubTasks[indexPath.row]
        print("OneSubTaskState \(OneSubTask.TaskState())")
        cell.UserTaskName.text = OneSubTask.getTaskName()
        
        if OneSubTask.TaskState() == true {
            let checkImg = UIImage(named: "checked.PNG") as UIImage? //set check image
            
        cell.CheckBoxImage.setBackgroundImage(checkImg, for: UIControl.State.normal)
        }
        
        else {
            let uncheckImg = UIImage(named: "unchecked.PNG") as UIImage? //set uncheck image
            
            cell.CheckBoxImage.setBackgroundImage(uncheckImg, for: UIControl.State.normal)
        }
       
        cell.UserTaskName.text = OneSubTask.getTaskName()
        cell.CBdelegate = self
        cell.SubTasks =  SubTasks
        cell.indexPath = indexPath.row
       // cell.UserTaskNameTextfield.delegate = self
        
        
        return cell
    }
    
    /* Pass data to the notepad textview scene*/
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            let vc = segue.destination as? PopUpViewController
            vc?.editingTaskIndex = editingTaskIndex
    }
    
    /* Init View*/
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        CellToolBar.isHidden = true
        self.myPhone = Storage.init()
        self.schedule =  myPhone.get(key: "allTasks") ?? Schedule.init()
        if(self.schedule.tasks.count != 0)
        {
           let currentTask = self.schedule.tasks[self.editingTaskIndex]
           self.SubTasks = currentTask.subtasks
           tableView.reloadData()
        }
        //navigationItem.title = self.schedule.tasks[self.editingTaskIndex].title
        
    }
    
}

/* Notepad to write anything user feels like for a to-do list as a pop up view in to do list view*/
class PopUpViewController: UIViewController{
    
    var notes = ""
    var schedule = Schedule()
    var myPhone = Storage()
    var editingTaskIndex = 0
    
    /*textfield delegate*/
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    
    @IBOutlet weak var NotePad: UITextView!
    @IBOutlet weak var dismissButton: UIBarButtonItem!
    
    /* Hit back and return*/
    @IBAction func dismissButtonAction(_ sender:
        UIBarButtonItem) {
        if(self.schedule.tasks.count != 0){
            self.schedule.tasks[self.editingTaskIndex].note = NotePad.text
            self.myPhone.setSchedule(key: "allTasks", value: self.schedule)
        }
       
        self.dismiss(animated: true, completion: nil)
       
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.myPhone = Storage.init()
        self.schedule =  myPhone.get(key: "allTasks") ?? Schedule.init()
        //Get data from storage
        //Set notpad contents
        if(self.schedule.tasks.count != 0)
        {
            notes =  self.schedule.tasks[self.editingTaskIndex].note
            NotePad.text = notes
        }
        
    }
}

    

