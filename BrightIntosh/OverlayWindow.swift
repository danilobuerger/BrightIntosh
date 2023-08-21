//
//  OverlayWindow.swift
//  BrightIntosh
//
//  Created by Niklas Rousset on 13.07.23.
//

import Cocoa

class OverlayWindow: NSWindow {
    
    private var overlay: Overlay?
    
    private let highlightMode: Bool = true
    
    private var overlayedScreen: NSScreen?
    private var highlightTimer: Timer?
    
    init(rect: NSRect, screen: NSScreen) {
        super.init(contentRect: rect, styleMask: [], backing: BackingStoreType(rawValue: 0)!, defer: false)
        overlayedScreen = screen
        var position = screen.frame.origin
        position.y += screen.frame.height
        
        
        setFrameOrigin(position)
        isOpaque = false
        hasShadow = false
        backgroundColor = NSColor.clear
        ignoresMouseEvents = true
        level = .screenSaver
        collectionBehavior = [.stationary, .ignoresCycle, .canJoinAllSpaces]
        isReleasedWhenClosed = false
        canHide = false
        isMovableByWindowBackground = true
        alphaValue = 1
        orderFrontRegardless()
        
        overlay = Overlay(frame: rect, screen: screen)
        
        if highlightMode {
            styleMask = [.titled, .fullSizeContentView]
            isMovableByWindowBackground = true
            titlebarAppearsTransparent = true
            titleVisibility = .hidden
            showsToolbarButton = false
            overlay?.activateHighlightMode()
            highlightTimer = Timer(timeInterval: 0.05, repeats: true) {_ in
                self.getActiveWindow()
            }
            RunLoop.current.add(highlightTimer!, forMode: RunLoop.Mode.default)
        }
        
        contentView = overlay
    }
    
    func screenUpdate(screen: NSScreen) {
        overlay?.screenUpdate(screen: screen)
    }
    
    func getActiveWindow(verbose: Bool = false) -> NSWindow? {
        guard let app = NSWorkspace.shared.frontmostApplication else {
            return nil
        }
        let options = kCGWindowIsOnscreen
        guard let windows = CGWindowListCopyWindowInfo(.optionOnScreenOnly, kCGNullWindowID) as NSArray? as? [[String: AnyObject]] else {
            return nil
        }
        
        var activeWindow: [String: AnyObject]? = nil
        for window in windows {
            if window["kCGWindowLayer"] as! Int64 == 0 && window["kCGWindowOwnerPID"] as! UInt32 == app.processIdentifier {
                if verbose {
                    print("Found:")
                    print(app.localizedName!)
                    print(window)
                }
                activeWindow = window
            }
        }
        guard let window = activeWindow else {
            return nil
        }
        
        if highlightMode {
            let bounds = window["kCGWindowBounds"] as! NSDictionary
            let height = CGFloat((bounds["Height"] as! NSNumber).doubleValue)
            let width = CGFloat((bounds["Width"] as! NSNumber).doubleValue)
            let x = CGFloat((bounds["X"] as! NSNumber).doubleValue)
            let y = CGFloat(-(bounds["Y"] as! NSNumber).doubleValue + overlayedScreen!.frame.height)
            
            setFrame(NSRect(x: x, y: y, width: width, height: height), display: true)
            setFrameTopLeftPoint(NSPoint(x: x, y: y))
        }
        
        return nil
    }
}
