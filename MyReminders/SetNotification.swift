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
        // show this notification five seconds from now
        //let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
                let stringDate = decodeDate(getDate: aDate)
                let stringTime = decodeTime(getDate: aDate)
                let arrayDate = stringDate.components(separatedBy: "/")
                let arrayTime = stringTime.components(separatedBy: ":")
                //let arrayAMPM = stringTime.components(separatedBy: " ")
                //print("date \(arrayTime) \(arrayAMPM)")
        
        //        print(stringDate + " " + stringTime)
        //
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.current
        
        //        dateComponents.day = Int(arrayDate[1])
        //        dateComponents.month = Int(arrayDate[0])
        //        dateComponents.year = Int(arrayDate[2])
        //        //dateComponents.weekday = 3
                dateComponents.hour = Int(arrayTime[0])
                dateComponents.minute = Int(arrayTime[1])
                dateComponents.second = Int(arrayTime[2])
        
        let rDay = Int(arrayDate[1])
        let rMonth = Int(arrayDate[0])
        let rYear = Int("20" + arrayDate[2])
        
        print("day: \(String(describing: rDay)) month: \(String(describing: rMonth)) year: \(String(describing: rYear))")
        
        //values are hard coded
        dateComponents.day = rDay
        dateComponents.month = rMonth
        dateComponents.year = rYear
        //dateComponents.weekday = 3
        dateComponents.hour = 20
        dateComponents.minute = 13
        //dateComponents.second = 0
        
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
    
    func changeDateto24Format(date: String) {
        
        let dateAsString = date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        let date = dateFormatter.date(from: dateAsString)

        dateFormatter.dateFormat = "HH:mm"
        let date24 = dateFormatter.string(from: date!)
        
        print("\(date24)")
    }
}
