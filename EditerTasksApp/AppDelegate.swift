//
//  AppDelegate.swift
//  EditerTasksApp
//
//  Created by Shahid on 17/06/2022.
//

import UIKit
import AWSS3

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        self.initializeS3() //2
        return true
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
    
    //3
      func initializeS3() {
          let poolId = "***** your poolId *****" // 3-1
          let credentialsProvider = AWSCognitoCredentialsProvider(regionType: .USWest1, identityPoolId: poolId)//3-2
          let configuration = AWSServiceConfiguration(region: .USWest1, credentialsProvider: credentialsProvider)
          AWSServiceManager.default().defaultServiceConfiguration = configuration
          
          
      }


}

