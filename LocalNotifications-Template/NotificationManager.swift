//
//  NotificationManager.swift
//  LocalNotifications-Template
//
//  Created by Juan Diego Ocampo on 13/03/2022.
//

import Foundation
import UserNotifications

final class NotificationManager: ObservableObject {
    
    @Published private(set) var notifications: [UNNotificationRequest] = []
    @Published private(set) var authorizationStatus: UNAuthorizationStatus?
    
    var noNotifications: Bool { notifications.isEmpty }
    
    func reloadAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.authorizationStatus = settings.authorizationStatus
            }
        }
    }
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { isGranted, _ in
            DispatchQueue.main.async {
                self.authorizationStatus = isGranted ? .authorized : .denied
            }
        }
    }
    
    func reloadLocalNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { notifications in
            DispatchQueue.main.async {
                self.notifications = notifications
            }
        }
    }
    
    func createLocalNotification(title: String, body: String, hour: Int, minute: Int, count: Int,completion: @escaping (Error?) -> Void) {
        var dateComponents = DateComponents()
        
        print("⚠️ stepperValue: \(count) ⚠️")
        let hourlyDifferenceBetweenAlarms = 24 / count
        
        for i in 0..<count {
            
            dateComponents.hour = (i * hourlyDifferenceBetweenAlarms) + hour
            dateComponents.minute = minute
            
            if dateComponents.hour! > 23 {
                break
            }
            
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            
            let notificationContent = UNMutableNotificationContent()
            
            notificationContent.title = title == ""   ? "Notification Title" : title
            notificationContent.body  = body  == ""   ? "Notification Title" : body
            notificationContent.sound = .default
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: notificationContent, trigger: trigger)
            
            print("⏰ HOUR COMPONENT: \(hour) ⏰")
            print("⏰ MINUTE COMPONENT: \(minute) ⏰")
            
            UNUserNotificationCenter.current().add(request, withCompletionHandler: completion)
            
        }
    }
    
    func deleteLocalNotifications(identifiers: [String]) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
}
