//
//  Notifications.swift
//  NotificationsApp
//
//  Created by Felix Titov on 5/26/22.
//  Copyright © 2022 by Felix Titov. All rights reserved.
//  


import UIKit
import UserNotifications

class Notifications: NSObject, UNUserNotificationCenterDelegate {
    let notificationCenter = UNUserNotificationCenter.current()
    
    func requestAuthorization() {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            print("Permission granted: \(granted)")
                
            guard granted else { return }
            self.getNotificationSettings()
        }
    }
        
    func getNotificationSettings() {
        notificationCenter.getNotificationSettings { (settings) in
            print("Notification settings: \(settings)")
        }
    }

    func scheduleNotification(notificationType: String) {
            
        let content = UNMutableNotificationContent()
        let userAction = "User Action"
        
        content.title = notificationType
        content.body = "This is example how to create " + notificationType
        content.sound = UNNotificationSound.default
        content.badge = 1
        content.categoryIdentifier = userAction
        
        guard let path = Bundle.main.path(forResource: "Photo", ofType: "png") else { return }

        let url = URL(fileURLWithPath: path)

        do {
            let attachment = try UNNotificationAttachment(identifier: "Photo", url: url, options: nil)

            content.attachments = [attachment]
        } catch {
            print("Attachment cannot be loaded!")
        }
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let identifire = "Local Notification"
        let request = UNNotificationRequest(identifier: identifire,
                                            content: content,
                                            trigger: trigger)
        
        notificationCenter.add(request) { (error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
        
        let snoozeAction = UNNotificationAction(identifier: "Snooze", title: "Snooze", options: [])
        let deleleAction = UNNotificationAction(identifier: "Delete", title: "Delete", options: [.destructive])
        
        let category = UNNotificationCategory(
            identifier: userAction,
            actions: [snoozeAction, deleleAction],
            intentIdentifiers: [],
            options: []
        )
        
        notificationCenter.setNotificationCategories([category])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.sound, .banner])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.notification.request.identifier == "Local Notification"{
            print("Handling notification with the local notification identifire")
        }
        
        switch response.actionIdentifier {
        case UNNotificationDismissActionIdentifier:
            print("Dismiss action")
        case UNNotificationDefaultActionIdentifier:
            print("default")
        case "Snooze":
            print("Snooze")
            scheduleNotification(notificationType: "Reminder")
        case "Delete":
            print("Delete")
        default:
            print("Unknown")
        }
        
        completionHandler()
    }

}
