# Sprint Planning 3

## Trello:
https://trello.com/b/SuBG7jG6/scheduler-app


## Summary:
This week, we have been working on our owns views as well as combining all the pieces together. We finished professor’s challenge: provide users with the ability to load certain tasks if the geo location is near the hard coded place and the current time is close to hard coded time. For the rest of the week, we are going do some testing by asking friends to use our app and give feedbacks, improve UI and user experience, unify coding style, and fix bugs. 

### Hanxing Zhang:
This week, I added notifications to each task in daily planner view when we add a new task (set as 15 minutes before each task). I also added functionality of requesting to access user’s location while using the app, as well as comparing current geo location with hard coded location (UC Davis campus) and comparing current time with hard coded time interval (for professor’s challenge). For the rest of the week, we are going do some testing by asking friends to use our app and give feedbacks, improve UI and user experience, unify coding style, and fix bugs.  

Commits:  
https://github.com/ECS189E/Scheduler/commit/bb7e037c71dffc47681e9691a96f24b840c4a58a#diff-8c9b0951bef12e64385c8849c27db2dc
https://github.com/ECS189E/Scheduler/commit/0401e901fedcfef7fc21b191f75acd8eb7e7f178
https://github.com/ECS189E/Scheduler/blob/master/Scheduler/Scheduler/DailyPlannerDetailViewController.swift




### Jiajun Liang:
I initiated the professor’s challenge to improve user experience. User could inject tasks automatically based on classroom location and class time so that user doesn't have to type in all tasks. And then I built on top of Hanxing’s work by adding two functions checkTime_for_loadingTasks() and checkLocation_for_loadingTasks() which check whether current time is inside Fall 2018 period and compare geolocation to Art Building, UC Davis. In addition, I fixed sorting bugs and data structure bugs, add a “clear all” action and change some UI things.  
Commits:  
https://github.com/ECS189E/Scheduler/commit/d9258ead8a10f51fa6a3ba89c1376d764687af5f
https://github.com/ECS189E/Scheduler/commit/921b872ac77e03545012b238cda4cd25b375270c
https://github.com/ECS189E/Scheduler/commit/940b1e443dca7952f68fd36038b2fb38ff365f13
https://github.com/ECS189E/Scheduler/commit/469c008bf6cc9fc4ad0ac07cd7cd90ab2efdd798

For the rest of the week I am planning to add an app icon, animate launch screen using a GIF (and find a good gif), and also add a load button.



### Sunil Ramakrishnan:
I consolidated the views for adding title, details and data into one VC I also added functionality to edit existing tasks (allow user to press edit on cell which goes into local storage and lets them modify the fields of that task). I fixed some bugs in the existing classes we had, extended our date class to work with the context of UI date picker. I fixed a bug in the data entry field where if a user used autocomplete it appended the entire word to the prefix. I also need to migrate this view into a scroll view. In addition to fixing these bugs I plan on cleaning up the source code and continuing testing.  

Commits:
https://github.com/ECS189E/Scheduler/blob/master/Scheduler/Scheduler/MainViewController.swift
https://github.com/ECS189E/Scheduler/blob/master/Scheduler/Scheduler/classes.swift
https://github.com/ECS189E/Scheduler/blob/master/Scheduler/Scheduler/addTask.swift




### Yanxi Li:
I combined my storyboards with others VCs, added storage to to-do list, quick memo, and fixed bugs(select + delete crash). Now everything works properly.
I also improved the overall UI of all view controllers in this project.
New pod installed to solve the keyboard covering textfields and textviews problem.
This week: main focus is the timer logic, how to detect if  user has left a view or not, etc.
If we have time I wish we could use a calendar pod to replace the date pickers and continue improving our UI.
Also, can’t merge to master due to .DS_Store conflicts, tried everything on stackoverflow but nothing worked. So I committed to a new folder.  
Commits:
https://github.com/ECS189E/Scheduler/commit/bd36dedbe57fc8a78d0186f912e48e38ef2f2ea8




