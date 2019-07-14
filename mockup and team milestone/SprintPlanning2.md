# Sprint Planning 2

## Trello:
https://trello.com/b/SuBG7jG6/scheduler-app


## Summary:
We made a great progress on unifying data structures and setting up navigation view controllers. The main task for next week will be combining each person’s work, fixing bugs, improving UI designs, and finishing professor’s challenge on downloading tasks based on classroom location and current date.

### Hanxing Zhang:
According to the suggestions from the teammates, I rewrote the daily planner and its detailed view and integrate my code with the main scheduler view in the past week. Users will be presented an empty table when directed to this view for the first time. User can add new tasks in the detailed view. User can delete one task by swiping a row or click the button “delete all” to delete all tasks in this table. Before deleting, an alert will be shown to confirm with user about deletion. Notification is set as 5 seconds after the daily planner view is launched for now. This week, I plan to set the notification time as 5 minutes before each task in the daily planner. I also plan to work on storage for the tasks and professor’s challenge “automatically add tasks to user’s app when the geo location and time matches” with other teammates. If time allows, I will spend some more time on UI. Commit to Github:
https://github.com/ECS189E/Scheduler/commits/master/Scheduler/Scheduler/DailyPalnnerViewController.swift
https://github.com/ECS189E/Scheduler/commits/master/Scheduler/Scheduler/DailyPlannerDetailViewController.swift
https://github.com/ECS189E/Scheduler/tree/hanxing/daily_planner/Scheduler/Scheduler



### Jiajun Liang:
Combining everyone’s work is a pain. I modified different views, set up the delete alert confirmation, removed some duplicate buttons, fixed add tasks bugs, delete bugs, segue bugs and local storage bugs, modified data structure based on teammates’ work, and did the countdown label. Now I am still getting in stuck in unifying all viewcontrollers and data structures. Combining each person’s work is much much harder than what I expected before… Github Commit: 
https://github.com/ECS189E/Scheduler/commit/1d071a4faf89cf08cd2785561373aee3d38ebdc3
https://github.com/ECS189E/Scheduler/commit/3e53abba3a4868ced211489c28630b65d42c8eea
https://github.com/ECS189E/Scheduler/commit/72b7f16738842831ec5494d84ea5819654950f2f
https://github.com/ECS189E/Scheduler/commit/6fe02dd8ce2d994005f8bf1f098e7d7a4c7701e5

Just finished the days left countdown label:
https://github.com/ECS189E/Scheduler/commit/1e5e77ac86f6e7c73f1d53e427bc9a640f00ce8b


### Sunil Ramakrishnan:
I created 3 view controllers for adding a task (add title, add due date, add task details). I set up persistent storage on local devices created storage class to work with all data types. I integrated this with the existing code. I am working on modifying the existing add task functionality to support granularity down to hours and minutes. I am also working on the edit functionality where a user can go in and edit an already existing task (title, due date and task details). I will also help with the geolocation based task download. I also plan on learning how to use firebase so that we can set up a database for the geolocation based download
Github Commit:
https://github.com/ECS189E/Scheduler/blob/master/Scheduler/Scheduler/classes.swift
https://github.com/ECS189E/Scheduler/blob/master/Scheduler/Scheduler/MainViewController.swift
https://github.com/ECS189E/Scheduler/blob/master/Scheduler/Scheduler/addDetails.swift
https://github.com/ECS189E/Scheduler/blob/master/Scheduler/Scheduler/addDueDate.swift
https://github.com/ECS189E/Scheduler/blob/master/Scheduler/Scheduler/addTitle.swift



### Yanxi Li:
Last week I finished the the sub-task view controller. Specifically I implemented a to do list that can add/delete/edit/check/uncheck tasks, delete all tasks at once with UIalert and sheet, a convenient notepad as a separate pop up view, and a pop up ‘help’ view that navigates the user. I also improved the timer view, improved the UI, as well as fixed some bugs. Next week we will unify our storyboards, and then I will add storage to my existing files. After that I will finish the displaying-timer-records-associated-with-a-to-do-list-task view. As a group we will also work on the professor’s challenge.
Github:
https://github.com/ECS189E/Scheduler/commit/cd1961438ab05e6077e1ef4f9df481ad028daae9



