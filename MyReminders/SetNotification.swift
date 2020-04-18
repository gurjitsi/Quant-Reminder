//
//  SetNotification.swift
//  MyReminders
//
//  Created by Gurjit Singh on 21/03/20.
//  Copyright © 2020 Gurjit Singh. All rights reserved.
//

import Foundation
import UserNotifications

struct Notification {
    var title: String
    var desc: String
}

class SetNotification {
    
    func setPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("All set!")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func setNotification(aTitle:String, aDesc:String, aDate: Date) {
        let content = UNMutableNotificationContent()
        content.title = aTitle
        content.subtitle = aDesc
        content.sound = UNNotificationSound.default
        print("Alarm on")
        
        let stringDate = decodeDate(getDate: aDate)
        let arrayDate = stringDate.components(separatedBy: "/")
        //change date to 24 format
        let changedDate = changeDateto24Format(date: aDate)
        let arrayChangedDate = changedDate.components(separatedBy: ":")
        //date components
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.current
        //set hour and minute for reminder
        dateComponents.hour = Int(arrayChangedDate[0])
        dateComponents.minute = Int(arrayChangedDate[1])
        //split date to day, month and year
        let rDay = Int(arrayDate[1])
        let rMonth = Int(arrayDate[0])
        let rYear = Int("20" + arrayDate[2])
        //assign date components
        dateComponents.day = rDay
        dateComponents.month = rMonth
        dateComponents.year = rYear
        
        // Create the trigger as a repeating event.
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents, repeats: false)
        
        // choose a random identifier
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        // add our notification request
        //UNUserNotificationCenter.current().add(request)
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request) { (error) in
            if error != nil {
                print(error!)
            }
        }
    }
    
    func decodeDate(getDate: Date) -> String{
        let date = getDate
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
    
    func decodeTime(getDate: Date) -> String{
        let time = getDate
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        return formatter.string(from: time)
    }
    
    func changeDateto24Format(date: Date) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let newDateString = dateFormatter.string(from: date)
        print("New date from 12 hour: \(newDateString)")
        return newDateString
    }
}
