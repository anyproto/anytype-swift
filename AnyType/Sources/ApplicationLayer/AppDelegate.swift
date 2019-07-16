//
//  AppDelegate.swift
//  AnyType
//
//  Created by Denis Batvinkin on 12.07.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import UIKit
import Textile

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		
		do {
			// recoveryPhrase should be optional here, fix coming asap
			let recoveryPhrase = try Textile.initialize(withDebug: false, logToDisk: false)
			// Return phrase to the user for secure, out of app, storage
			print("recoveryPhrase: \(recoveryPhrase)")
			
			// Set the Textile delegate to self so we can make use of events such nodeStarted
			Textile.instance().delegate = self
		} catch {
			print("Unexpected error: \(error).")
		}
		
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

}


extension AppDelegate: TextileDelegate {
	
}

