import Foundation
import SwiftUI

@main
struct AnytypeApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ApplicationCoordinatorView()
        }
    }
}
