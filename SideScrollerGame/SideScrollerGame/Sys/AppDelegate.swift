//
//  AppDelegate.swift
//  SideScrollerGame
//
//  Created by Eduardo on 03/10/24.
//

import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    var eventMonitor: Any?
    var window: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        if let window = NSApplication.shared.windows.first {
            self.window = window
            window.delegate = self
            window.collectionBehavior = [.fullScreenAuxiliary,.fullScreenPrimary]
            configureWindow(window)
            window.toggleFullScreen(nil)
        }
        
        setPresentationOptions()
        
    }

    func windowWillExitFullScreen(_ notification: Notification) {
        // Prevent exiting fullscreen
        if let window = notification.object as? NSWindow {
            DispatchQueue.main.async {
                window.toggleFullScreen(nil)
            }
        }
    }

    private func configureWindow(_ window: NSWindow) {
        // Remove window controls
//        window.standardWindowButton(.closeButton)?.isHidden = true
        window.standardWindowButton(.miniaturizeButton)?.isEnabled = false
        window.standardWindowButton(.zoomButton)?.isEnabled = false
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.isMovable = false
        window.styleMask.remove(.resizable)
    }

    private func setPresentationOptions() {
        let options: NSApplication.PresentationOptions = [
            .hideDock,
//            .hideMenuBar,
//            .disableProcessSwitching, // Disable Command + Tab
            .disableHideApplication
        ]
        NSApp.presentationOptions = options
    }
    
    private func startBackgroundTask() {
        DispatchQueue.global().async {
            while true {
                print("Running in background...")
                Thread.sleep(forTimeInterval: 1)
            }
        }
    }
}
