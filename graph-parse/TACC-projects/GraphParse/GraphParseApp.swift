//
//  GraphParseApp.swift
//  GraphParse
//
//  Created by TACC Staff on 1/30/25.
//

import SwiftUI
import FirebaseCore
import FirebaseStorage
import UIKit
 

// The appdelegate class is the launchpad for firebase
class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct GraphParseApp: App {
    
    // register app delegate for firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    init() {
        FirebaseApp.configure()
        print("Firebase configured")
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
