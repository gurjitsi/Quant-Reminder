//
//  ContentView.swift
//  MyReminders
//
//  Created by Gurjit Singh on 20/03/20.
//  Copyright © 2020 Gurjit Singh. All rights reserved.
//

import SwiftUI
import CoreData
import UserNotifications

struct ContentView: View {
    var body: some View {
        NavigationView {
            //set initial view with default folder id
            RemindersView(getFolderId: "4D7BC347-E708-453E-9C58-EBDF48FDB263")
        }.accentColor(Color.red)
    }
}

struct FoldersView: View{
    
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: Lists.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Lists.displayOrder, ascending: false)]) var lists: FetchedResults<Lists>
    //create variable for new list
    @State var newList = ""
    //create variable to handle alert if empty
    @State var showingEmptyListAlert = false
    
    var body: some View{
        List{
            Section(header: Text("New List")) {
                HStack {
                    //set text field for new list
                    TextField("Title", text: $newList)
                    Button(action: {
                        
                    }) {
                        Image(systemName: "plus.circle.fill").imageScale(.large).foregroundColor(Color.red)
                    } .alert(isPresented: $showingEmptyListAlert) {
                        //display alert if textfield is empty
                        Alert(title: Text("Alert"), message: Text("Please enter new list title."), dismissButton: .default(Text("OK")))
                    } .onTapGesture {
                        if (self.newList.isEmpty) {
                            //change value to display alert view
                            self.showingEmptyListAlert.toggle()
                        } else {
                            //get current date
                            let getDate = getCurrentDate()
                            let formatter = DateFormatter()
                            formatter.dateFormat = "d MMM y"
                            //change string to date
                            let changedDate = formatter.date(from: getDate)
                            //insert values into entity
                            let listContext = Lists(context: self.moc)
                            listContext.id = UUID()
                            listContext.title = "\(self.newList)"
                            listContext.displayOrder = Int16(self.lists.endIndex)
                            listContext.date = changedDate
                            try? self.moc.save()
                            self.newList = ""
                        }
                    }
                }
            }
            Section(header: Text("My Lists")) {
                //navigation to list view
                NavigationLink(destination: RemindersView(getFolderId: "4D7BC347-E708-453E-9C58-EBDF48FDB263")) {
                    Text("Default").font(.headline).foregroundColor(Color.gray)
                }
                ForEach(lists, id: \.self) { list in
                    //diplay data into list view
                    NavigationLink(destination: RemindersView(getFolderId: String("\(list.id!)"))) {
                    Text("\(list.title!)").font(.headline)
                        
                }
            } .onDelete { (indexSet) in
                for offset in indexSet {
                    //delete row from list
                    let list = self.lists[offset]
                    self.moc.delete(list)
                }
                try? self.moc.save()
            }
        }
        }.navigationBarBackButtonHidden(true)
        .navigationBarTitle("Lists")
        .navigationBarItems(trailing: EditButton()).font(Font.headline.weight(.semibold))
    }
}

//get current date
func getCurrentDate() -> String {
    let today = Date()
    let formatter = DateFormatter()
    formatter.dateFormat = "d MMM y"
    let date = formatter.string(from: today)
    return date
}

//reminder view
struct RemindersView: View{
    
    @State var newReminder = ""
    @State var isReminderDetailShowing = false
    var getFolderId:String
    @State var showingEmptyReminderAlert = false
    var alarmReminder = Date()
    
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: Reminders.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Reminders.displayOrder, ascending: false)]) var reminders: FetchedResults<Reminders>
    
    var body: some View {
        
        List{
            Section(header: Text("New Reminder").foregroundColor(Color.black)) {
                HStack {
                    TextField("Title", text: $newReminder).foregroundColor(Color.black)
                    Button(action: {
                        
                    }) {
                        Image(systemName: "plus.circle.fill").imageScale(.large).foregroundColor(Color.red)
                    } .alert(isPresented: $showingEmptyReminderAlert) {
                        Alert(title: Text("Alert"), message: Text("Please enter new reminder title."), dismissButton: .default(Text("OK")))
                    } .onTapGesture {
                        if (self.newReminder.isEmpty) {
                            self.showingEmptyReminderAlert.toggle()
                        } else {
                            let getDate = getCurrentDate()
                            let formatter = DateFormatter()
                            formatter.dateFormat = "d MMM y"
                            let changedDate = formatter.date(from: getDate)
                            let reminderContext = Reminders(context: self.moc)
                            reminderContext.id = UUID()
                            reminderContext.title = "\(self.newReminder)"
                            reminderContext.displayOrder = Int16(self.reminders.endIndex)
                            reminderContext.createdDate = changedDate
                            reminderContext.status = false
                            reminderContext.priority = 0
                            reminderContext.folderId = UUID(uuidString: self.getFolderId)
                            reminderContext.descrip = ""
                            reminderContext.reminder = self.alarmReminder
                            reminderContext.reminderStatus = false
                            try? self.moc.save()
                            self.newReminder = ""
                        }
                    }
                }
            }
            Section(header: Text("My Reminders").foregroundColor(Color.black)) {
                ForEach(reminders.filter { return $0.folderId! == stringToUUID(input: self.getFolderId) }, id:\.self) { reminder in
                HStack {
                    Button(action: {
                        
                    }) {
                        if(reminder.status == true) {
                            Image(systemName: "checkmark.circle.fill").imageScale(.large).foregroundColor(Color.gray)
                        } else {
                            Image(systemName: "circle").imageScale(.large)
                        }
                    } .onTapGesture {
                        var changeStatus: Bool
                        if reminder.status == true {
                            changeStatus = false
                        } else {
                            changeStatus = true
                        }
                        reminderCompleted(taskId: reminder.id!, astatus: changeStatus)
                    }
                    if reminder.status == true {
                        Text("\(reminder.title!)").font(.headline).foregroundColor(Color.gray).strikethrough()
                    } else {
                        Text("\(reminder.title!)").font(.headline).foregroundColor(Color.black)
                    }
                    
                    Spacer()
                    Button(action: {
                        
                    }) {
                        Image(systemName: "info.circle").imageScale(.large)
                    } .onTapGesture {
                        self.isReminderDetailShowing.toggle()
                    } .sheet(isPresented: self.$isReminderDetailShowing) {
                        ReminderDetailView(remId: reminder.id!,isReminderDetailShowing: self.$isReminderDetailShowing, remTitle: reminder.title!, remDesc: reminder.descrip!, remPriority: reminder.priority, remAlarm: reminder.reminder!,showReminderDetail: reminder.reminderStatus)
                    }
                }
            } .onDelete { (indexSet) in
                for offset in indexSet {
                    let reminder = self.reminders[offset]
                    self.moc.delete(reminder)
                }
                try? self.moc.save()
            }
            }
        }
        .navigationBarTitle("Reminders").foregroundColor(Color.red)
        .navigationBarItems(leading:NavigationButtonItem(),trailing: EditButton().font(Font.headline.weight(.semibold)))
    }
}

//change date to string
func changeDateToString(adate: Date) -> String {
        let adate =  adate
        //let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM y"
        let result = formatter.string(from: adate)
        return result
}

//change string to UUID
func stringToUUID(input: String) -> UUID {
    let getInput = UUID(uuidString: input)!
    return getInput
}

//call this function when reminder completed
func reminderCompleted(taskId: UUID, astatus: Bool) {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
    let managedContext = appDelegate.persistentContainer.viewContext
    
    let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Reminders")
    fetchRequest.predicate = NSPredicate(format: "id = %@", "\(taskId)")
    do {
        let test = try managedContext.fetch(fetchRequest)
        let objectUpdate = test[0] as! NSManagedObject
        objectUpdate.setValue(astatus, forKey: "status")
        do {
            try managedContext.save()
        } catch {
            print(error)
        }
    } catch {
        print(error)
    }
}

//custom navigation button to lists view
struct NavigationButtonItem: View {
    var body: some View {

           Button(action: {
            
           }){
            NavigationLink(destination: FoldersView()) {
                HStack {
                    Image(systemName: "chevron.left").imageScale(.medium).font(Font.title.weight(.semibold))
                    Text("Lists").font(.headline).fontWeight(.semibold)
                    }
            }
        }
    }
}

//sheet to display detail of reminder
struct ReminderDetailView: View{
    
    var remId: UUID
    @Binding var isReminderDetailShowing: Bool
    @State var remTitle: String
    @State var remDesc: String
    @State var remPriority: Int16
    @State var remAlarm: Date
    
    @State var showReminderDetail: Bool
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }
    @State private var reminderDate = Date()
    let notificationManager = SetNotification()
    
    var body: some View{
        NavigationView {
                List {
                    Section {
                        VStack {
                            TextField("Title", text: $remTitle)
                            Divider()
                            TextField("Description", text: $remDesc)
                        }.padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0)).accentColor(Color.red)
                    }
                    
                    Section {
                        VStack {
                            HStack {
                                Toggle(isOn: $showReminderDetail) {
                                    Text("Reminder")
                                    
                                }
                            }
                                
                                if showReminderDetail {
                                    Divider()
                                    //Text("\(reminderDate, formatter: dateFormatter)")
                                    DatePicker("Alarm", selection: $remAlarm)
                                    
                                }
                        }.padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                    
                    }
                    
                    Section {
                        VStack {
                            HStack {
                                NavigationLink(destination: PriorityView(reminderPriority: $remPriority)) {
                                    Text("Priority")
                                    Spacer()
                                    if remPriority == 0 {
                                        Text("None").foregroundColor(Color.gray)
                                    } else if remPriority == 1 {
                                        Text("Low").foregroundColor(Color.gray)
                                    } else if remPriority == 2 {
                                        Text("Medium").foregroundColor(Color.gray)
                                    } else {
                                        Text("High").foregroundColor(Color.gray)
                                    }
                                    
                                }
                            }
                            
                        }.accentColor(Color.red)
                    }
                } .listStyle(GroupedListStyle())
                    
            .navigationBarTitle("Details", displayMode: .inline)
            .navigationBarItems(trailing:
                Button(action: {
                    reminderDetailEdit(taskId: self.remId, aTitle: self.remTitle, aDesc: self.remDesc, aPriority: self.remPriority,aAlarmStatus: self.showReminderDetail,aAlarmDate: self.remAlarm)
                    self.isReminderDetailShowing.toggle()
                    if self.showReminderDetail {
                        self.notificationManager.setPermissions()
                        self.notificationManager.setNotification(aTitle: self.remTitle, aDesc: self.remDesc, aDate: self.remAlarm)
                    }
                }) {
                    Text("Done").fontWeight(.semibold).foregroundColor(Color.red)
                }
            )
            }
    
    }
}

struct PriorityView: View{
    
    @Binding var reminderPriority: Int16
    var priorityArr = ["None","Low","Medium","High"]
    //@State var priorityStatus = 0
    
    var body:some View{
        
        List {
            ForEach((0..<priorityArr.count), id: \.self) { index in
                HStack {
                    Text("\(self.priorityArr[index])")
                    Spacer()
                    Button(action: {
                        
                    }) {
                        if self.reminderPriority == index {
                            Image(systemName: "checkmark.square").imageScale(.large).foregroundColor(Color.red)
                        } else {
                            Image(systemName: "square").imageScale(.large).foregroundColor(Color.black)
                        }
                        
                    } .onTapGesture {
                        self.reminderPriority = Int16(index)
                    }
                }
            }
        }.listStyle(GroupedListStyle())
            .navigationBarTitle("Priority", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: NavigationPrioritItem())
    }
}

struct NavigationPrioritItem: View {
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
           Button(action: {
            self.presentationMode.wrappedValue.dismiss()
           }){
                HStack {
                    Image(systemName: "chevron.left").imageScale(.medium).font(Font.headline.weight(.semibold)).foregroundColor(Color.red)
                    Text("Details").font(.headline).fontWeight(.semibold).foregroundColor(Color.red)
                    }
            }
    }
}

//edit reminder  detail
func reminderDetailEdit(taskId: UUID, aTitle: String, aDesc: String, aPriority: Int16, aAlarmStatus: Bool,aAlarmDate: Date) {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
    let managedContext = appDelegate.persistentContainer.viewContext
    
    let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Reminders")
    fetchRequest.predicate = NSPredicate(format: "id = %@", "\(taskId)")
    do {
        let test = try managedContext.fetch(fetchRequest)
        let objectUpdate = test[0] as! NSManagedObject
        objectUpdate.setValue(aTitle, forKey: "title")
        objectUpdate.setValue(aDesc, forKey: "descrip")
        objectUpdate.setValue(aPriority, forKey: "priority")
        objectUpdate.setValue(aAlarmStatus, forKey: "reminderStatus")
        objectUpdate.setValue(aAlarmDate, forKey: "reminder")
        do {
            try managedContext.save()
        } catch {
            print(error)
        }
    } catch {
        print(error)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
