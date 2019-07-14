# Scheduler
## Motivation
Although there are many similar apps available on the App Store now, based on our experience, these apps are sometimes too ‘powerful’ that are not very user friendly or they are dedicated to a monotonous functionality (although they are very good) that we have to install multiple apps in order to acquire all the functions we are looking for. Therefore, we wish to build one app that balance complexity and functionality, including the best features that can promote productivity. After refining and improving our app by refining the key features, improving our user interface and the overall flow, we have finally created an app that has some compelling features compared with other similar management and productivity apps. 

## Key features of our app
The Scheduler app integrates the functionality of self-control, simple event scheduling, daily activity planning and reminders to give users a simple yet efficient way to manage their schedule. To be brief, we have a scheduler view to schedule important events and present in sorted order, a to do list associated with each planned task in the scheduler, a daily planner to manage daily plans and scheduler, and a timer that help user to stay away from their phone and stay focus to a task.

## Further improvement 
We need to collect as much feedback as we can to continue refining our app. Meanwhile, we will also be checking app’s performance and keep optimizing it. Loading a pre-upload events by fetching and comparing geo-location is also a cool feature that we wish to continue working on, and we wish to turn what we hardcoded now into a true functionality of our app.

## Team Member:
| NAME: | Hanxing Zhang | Jiajun Liang | Yanxi Li | Sunil Ramakrishnan |
|-------|--------|--------|--------|--------|
| Github: | [681starflower](https://github.com/681starflower)|[jiajunliangucdavis](https://github.com/jiajunliangucdavis)|[pennyroyalttea](https://github.com/pennyroyalttea)| [daplaia](https://github.com/daplaia) |

## Trello Board
https://trello.com/b/SuBG7jG6/scheduler-app

## Team Contribution 
### Hanxing Zhang 
For this Scheduler app, I created two views for the daily planner part and connected them to the main view. The purpose of the daily planner is to provide users notes-like experience with reminders sent 15 minutes before each task starts. It has two views, the table view with all added tasks for that day, and a separate view to create a new task or edit an existing task. In the detailed view, user can set start time, finish time, and notes of each task. In the table view of daily planner, users can delete all tasks when they come to this view the next day. Yanxi made modifications to the detailed view of daily planner in the version we submitted. She moved the two time pickers to a third view in case users wants to use default time interval or don’t want to modify start time and end time.  I also worked on other parts of the app, for example, adding alerts before delete one or all tasks asking for confirmation from the users, adding notifications for each task as reminders (15 minutes before each task’s start time), adding functions requesting to access user’s location, getting user’s location, and comparing user’s locations with UC Davis location and user’s current time with hard coded time (for loading hard coded tasks), making unique refresh button and adding refresh button to the main view so users can search for tasks nearby and load them to Scheduler if they choose to.   
Commits include :  
https://github.com/ECS189E/Scheduler/blob/master/Scheduler/Scheduler/DailyPlannerViewController.swift
DailyPlannerDetailViewController in 
https://github.com/ECS189E/Scheduler/blob/master/Scheduler/Scheduler/DailyPlannerDetailViewController.swift  
Some code MainViewController.swift and classes.swift.
https://github.com/ECS189E/Scheduler/blob/master/Scheduler/Scheduler/MainViewController.swift
https://github.com/ECS189E/Scheduler/blob/master/Scheduler/Scheduler/classes.swift

### Jiajun Liang
I am responsible for the main scheduler view controller, basic data structures (schedule, task, myDate, tableview cell) shared for all views, unifying view controllers together, and fixing little bugs everywhere. In particular, I modified different views to fit in the main logic, set up the delete alert confirmation in main, removed some duplicate buttons, fixed add tasks bugs, sorting bugs, delete bugs, segue bugs, data structure’s typo, local storage bugs, modified data structure based on teammates’ work, implemented the days countdown logic.   
After milestone 2 meeting, I initialized the professor’s challenge to improve user experience inject tasks automatically based on classroom location and class time so that user doesn't have to type in all tasks. And then I built on top of Hanxing’s work by adding two functions checkTime_for_loadingTasks() and checkLocation_for_loadingTasks() which check whether current time is inside Fall 2018 period and compare geolocation to Art Building, UC Davis. (*** Please note: for Sam and Zhiyi’s convenience, I intended to set a quite large deviation of location such that Sam and Zhiyi could load tasks even on Kemper office...)
Finally, I found a open-source gif and implemented the launching gif animation. Then drew the app icon and optimizes my icon design into all pixel formats needed for xcode.  
Several big commits:  
https://github.com/ECS189E/Scheduler/commit/517be7cefe0325e1c05000d98cb48725598719cd
https://github.com/ECS189E/Scheduler/commit/72b7f16738842831ec5494d84ea5819654950f2f
https://github.com/ECS189E/Scheduler/commit/3daf30b495fe37082d97d90fc8c692c59a069e02
https://github.com/ECS189E/Scheduler/commit/469c008bf6cc9fc4ad0ac07cd7cd90ab2efdd798
https://github.com/ECS189E/Scheduler/commit/85f05af6ef3d61a010f9ca58be19c187ffba6d62
https://github.com/ECS189E/Scheduler/commit/1e5e77ac86f6e7c73f1d53e427bc9a640f00ce8b
https://github.com/ECS189E/Scheduler/commit/d9258ead8a10f51fa6a3ba89c1376d764687af5f

### Sunil Ramakrishnan
For my part in the scheduler app I created the views for add new task and edit existing task. (The add task and edit tasks have the same UI style just different logic). The user can enter in the date of their task (time due, month due, year due, etc.) using the UI datepicker. The user can then enter the title and details of their task which I set up in a clear and intuitive way by creating my own placeholder and manipulating the output message according the the user’s actions i.e. forgot to add title, or default; add due date. Once the user successfully enters the task a success output message is generated.  
The difference in the edit view is that I preload the task title, details and date from storage and put them in the respective fields. Once they are done the task is updated and the tasks are resorted and a successful edit message is outputted. I also enabled the use of autocomplete in the text fields.  
I also refactored code in the main view controller, set up the local storage to handle custom data types, defined the sort function for tasks, set up the myDate class, handled segues from main VC to my view and defined the schedule class.  
I also worked on the feature of the app where we load tasks based on location (Professors Challenge). I detected and fixed a bug where the same entry got loaded into the phone more than once creating extraneous entries.  
I also helped set up the task detail VC namly connecting the info from our existing tasks to it.  
Commits:  
addTask.swift (did everything here so no list of select commits) also UI for add/edit task  
https://github.com/ECS189E/Scheduler/blob/master/Scheduler/Scheduler/addTask.swift  
MainViewController.swift commits:  
https://github.com/ECS189E/Scheduler/commit/f0eab7a28d443b115eaf46bc07b8a766931b7f1a  
https://github.com/ECS189E/Scheduler/commit/ae4675bc1decb448b15515c2c85d6bf52288ff94  
Classes.swift commits:  
https://github.com/ECS189E/Scheduler/commit/9404c3aa6f3097fba3479064996b394475a19a13  
https://github.com/ECS189E/Scheduler/commit/69eee190267d1a15e5b6b711ec058cd3e8106a32  
https://github.com/ECS189E/Scheduler/commit/f0eab7a28d443b115eaf46bc07b8a766931b7f1a  

### Yanxi Li
For this app, I planned out  the basic structure of this app including what each view controller does, and discussed with group member before our proposal. I am responsible for all view controllers associated with the To-do list scene, Timer scene, the daily planner ‘edit time” view controller, as well as the overall flow and improving user-interface of our app. Since our intention was to create a powerful yet user-friendly app, I did found the flow of the app was a bit hard to follow when we were trying to put everything together. Since we wish to integrate many good planning and self-control functions in one app, in the end I tried different ways to simplify the flow of our app while making sure we are preserving the key features, and our final product is by far the one that has the smoothest flow.   

Selected commits reflecting the major changes of our app during our final stage:  
https://github.com/ECS189E/Scheduler/commit/1b7a80fe85ad44a08b6665b952ab4c5aeb08aac0
https://github.com/ECS189E/Scheduler/commit/56ef277214b16c7bbda60eff442b589030183491
https://github.com/ECS189E/Scheduler/commit/8b029739a40cc5f8ab93f5ff3f583943a4fd2f23
https://github.com/ECS189E/Scheduler/commit/21af83e2e3a07ac1cb7fe1a7345d00322bc3264e
https://github.com/ECS189E/Scheduler/commit/6d1c2deda41612014d13cd0c83bd4fc449d8a839






## Pod use
https://cocoapods.org/pods/MGSwipeTableCell  
https://cocoapods.org/pods/SwiftyGif  
https://cocoapods.org/pods/IQKeyboardManagerSwift  

## Resource Cited
Launching gif: https://media.giphy.com/media/8HTixoSC6z2lxO27PX/giphy.gif  
Requestion location: https://www.hackingwithswift.com/read/22/2/requesting-location-core-location  
Animated class: https://medium.com/@hukicamer/animated-launch-screen-using-a-gif-in-ios-cd759ae9130d  
String Extension:  https://stackoverflow.com/questions/24092884/get-nth-character-of-a-string-in-swift-programming-language/38215613#38215613  
Get index of selected cell: https://forums.developer.apple.com/thread/67265  
Store custom class in local storage: https://stackoverflow.com/questions/44876420/save-struct-to-userdefaults  
Get current time and calculate time interval: https://stackoverflow.com/questions/24070450/how-to-get-the-current-time-as-datetime  
indexpath row: https://forums.developer.apple.com/thread/67265  
hide keyboard: https://stackoverflow.com/questions/29882775/resignfirstresponder-vs-endediting-for-keyboard-dismissal



