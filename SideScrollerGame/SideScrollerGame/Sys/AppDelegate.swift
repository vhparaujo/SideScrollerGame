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
            window.collectionBehavior = [.fullScreenPrimary]
            configureWindow(window)
            window.toggleFullScreen(nil)
        }

        disableKeyboardShortcuts()
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

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        return .terminateCancel // Prevent the app from quitting
    }

    func applicationWillTerminate(_ notification: Notification) {
        if let eventMonitor = eventMonitor {
            NSEvent.removeMonitor(eventMonitor)
        }
    }

    private func configureWindow(_ window: NSWindow) {
        // Remove window controls
        window.standardWindowButton(.closeButton)?.isHidden = true
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window.standardWindowButton(.zoomButton)?.isHidden = true
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.isMovable = false
        window.styleMask.remove(.resizable)
    }

    private func disableKeyboardShortcuts() {
        // Disable Command + Q and other shortcuts
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.modifierFlags.contains(.command) {
                switch event.keyCode {
                case 12, // 'Q' key
                     46, // 'M' key
                     53: // Escape key
                    return nil
                default:
                    break
                }
            }

            if event.keyCode == 53 { // Escape key
                return nil
            }

            return event
        }
    }

    private func setPresentationOptions() {
        let options: NSApplication.PresentationOptions = [
            .hideDock,
            .hideMenuBar,
            .disableForceQuit,        // Disable Command + Option + Escape
            .disableProcessSwitching, // Disable Command + Tab
            .disableSessionTermination,
            .disableHideApplication
        ]
        NSApp.presentationOptions = options
    }
}
