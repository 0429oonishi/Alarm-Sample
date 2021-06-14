//
//  AppDelegate.swift
//  Alarm-Sample
//
//  Created by 大西玲音 on 2021/06/14.
//

import UIKit
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            if granted {
                UNUserNotificationCenter.current().delegate = self
            }
        }
        return true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // バックグラウンドからアクティブな状態に遷移されたときに呼ばれる。
        UNUserNotificationCenter.current().getDeliveredNotifications { (notifications: [UNNotification]) in
//            for notification in notifications {
//                _ = AlarmVC.shared.getAlarm(from: notification.request.identifier)
//                NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
//            }
        }
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
        let uuid = notification.request.identifier
//        _ = AlarmVC.shared.getAlarm(from: uuid)
        NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let identifier = response.actionIdentifier
        if identifier == "snooze" {
            let snoozeAction = UNNotificationAction(identifier: "snooze", title: "Snooze 5 Minutes", options: [])
            let noAction = UNNotificationAction(identifier: "stop", title: "stop", options: [])
            let alarmCategory = UNNotificationCategory(identifier: "alarmCategory", actions: [snoozeAction, noAction], intentIdentifiers: [], options: [])
            UNUserNotificationCenter.current().setNotificationCategories([alarmCategory])
            let content = UNMutableNotificationContent()
            content.title = "Snooze"
            content.sound = UNNotificationSound.default
            content.categoryIdentifier = "alarmCategory"
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            let request = UNNotificationRequest(identifier: "Snooze", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    fatalError("\(error)")
                }
            }
        }
        let uuid = response.notification.request.identifier
//        _ = AlarmVC.shared.getAlarm(from: uuid)
        NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
        completionHandler()
    }
    
}

