//
//  AppDelegate.swift
//  klask
//
//  Created by Joel Whitney on 1/9/18.
//  Copyright © 2018 JoelWhitney. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import Firebase
import CodableFirebase
import UserNotifications
import FirebaseInstanceID
import FirebaseMessaging

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate {

    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        
        // Set upp push notifications
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        print("background fetch status \(UIApplication.shared.backgroundRefreshStatus)")
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        Messaging.messaging().delegate = self
        Messaging.messaging().shouldEstablishDirectChannel = true
        
        let token = Messaging.messaging().fcmToken
        print("FCM token: \(token ?? "")")
        
        // Firebase connection
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
    
        // Check if app has been launched before otherwise clears out any cached creds  (ie re-install)
        let userDefaults = UserDefaults.standard
        
        if userDefaults.bool(forKey: "hasRunBefore") == false {
            
            // remove keychain items here
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
                GIDSignIn.sharedInstance().signOut()
                DataStore.shared.activeuser = nil
                DataStore.shared.activearena = nil
                DataStore.shared.deleteUserDefaults()
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
            
            userDefaults.set(true, forKey: "hasRunBefore")
            
        } else {
            DataStore.shared.getUserDefaults()
        }
        
        return true
    }

    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
       
        DataStore.shared.getUserDefaults()
        
        DataStore.shared.getUserChallenges(onComplete: { (challenges: [KlaskChallenge], error: Error?) in
            
            if challenges.count > 0 {
                var challenges = challenges
                
                challenges.removeDuplicates()
                
                for challenge in challenges {
                    
                    UNUserNotificationCenter.scheduleChallengeNotification(challenge: challenge)

                }
                completionHandler(.newData)
            } else {
                completionHandler(.noData)
            }
        })
    }

    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        // update user here? or store in local cache maybe?
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
            //  This method is called on iOS 10 devices to handle data messages received via FCM through its direct channel (not via APNS). For iOS 9 and below, the FCM data message is delivered via the UIApplicationDelegate’s -application:didReceiveRemoteNotification: method.
    }

    func application(received remoteMessage: MessagingRemoteMessage) {
        //The callback to handle data message received via FCM for devices running iOS 10 or above.
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken as Data
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        //presentChallengeAlert()
        
        // Print full message.
        print(userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        //presentChallengeAlert()
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
            return GIDSignIn.sharedInstance().handle(url, sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: [:])
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.

    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        DataStore.shared.saveUserDefaults()
    }
}

// MARK: - Google Sign In stuff
extension AppDelegate: GIDSignInDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        
        if let error = error {
            print(error)
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
                print(error)
                return
            }
            // fetch active user and set locally
            if let user = user {
                DataStore.shared.getActiveUser(user) {
                    if let navController = self.window?.rootViewController as? UINavigationController, let signInVC = navController.presentedViewController as? SignInViewController {
                        signInVC.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
        print("disconnected")
    }
}

// MARK: - Push notification stuff
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {

    // Receive and show alert while app in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        //presentChallengeAlert()
    
        print(userInfo)
        
        // present alert if app in foreground for remote notifications
        completionHandler(.alert)
    }

    // What to do when opened
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        // if challenge alert will need to present challenge alert
        if response.notification.request.content.categoryIdentifier == "challenge" {
            print(response.notification.request.content.title)
            print(response.notification.request.content.body)
            print(response.notification.request.content.userInfo)
            //presentChallengeAlert()
        } else {
            // otherwise from Firebase FCM
            if let messageID = userInfo[gcmMessageIDKey] {
                print("Message ID: \(messageID)")
            }
            print(userInfo)
        }

        completionHandler()
    }
    
    
}

extension UNUserNotificationCenter {
    static func scheduleChallengeNotification(challenge: KlaskChallenge) {
        
        let content = UNMutableNotificationContent()
        content.title = "Challenge"
        content.categoryIdentifier = "challenge"
        let challenger = (challenge.challengername == "") ? "someone" : challenge.challengername!
        content.body = "You've been challenged by \(String(describing: challenger))"
        content.userInfo = ["datetime": String(describing: challenge.datetime ?? 0), "arenaid": String(describing: challenge.arenaid ?? ""), "challengeruid": String(describing: challenge.challengeruid ?? ""), "challengername": String(describing: challenge.challengername ?? "")]
        let request = UNNotificationRequest(identifier: "\(challenge.challengeruid!)-\(challenge.challengeduid!)", content: content, trigger: nil)
        
        UNUserNotificationCenter.current().add(request) { error in
            
            if let error = error {
                print("Error scheduling the notification: \(error)")
            } else {
                print("Scheduled notification")
                DataStore.shared.deleteChallenge(challenge)
            }
        }
    }
    
    static func scheduleNotification(withIdentifier identifier: String, title: String?, subtitle: String?, body: String?) {
        
        let content = UNMutableNotificationContent()
        content.title = title ?? ""
        content.body = body ?? ""
        content.subtitle = subtitle ?? ""
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: nil)
        
        UNUserNotificationCenter.current().add(request) { error in
            
            if let error = error {
                print("Error scheduling the notification: \(error)")
            } else {
                print("Scheduled notification")
            }
        }
    }
}

