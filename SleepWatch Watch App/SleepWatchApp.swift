//
//  SleepWatchApp.swift
//  SleepWatch Watch App
//
//  Created by Wentao Guo on 28/05/25.
//

import SwiftUI

@main
struct SleepWatch_Watch_AppApp: App {
    
    @WKExtensionDelegateAdaptor(ExtensionDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            EmptyView()
        }
    }
}

class ExtensionDelegate: NSObject, WKExtensionDelegate {
    let manage = HeartRateManager()
    
    func applicationDidFinishLaunching() {
        
    }
}
