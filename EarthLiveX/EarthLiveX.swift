//
//  EarthLiveX.swift
//  EarthLiveX
//
//  Created by Ryinn on 2022/3/23.
//

import Foundation
import Cocoa
import SwiftUI
import Wallpaper
import LaunchAtLogin
import Schedule

@main
struct EarthLiveX: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    
    let tenMinute: Int = 0
    let thirtyMinute: Int = 1
    let oneHour: Int = 2
    
    var statusItem: NSStatusItem!
    
    var statusMenu: NSMenu!
    
    var startItem: NSMenuItem!
    var intervalItem: NSMenuItem!
    
    var intervalSubMenu: NSMenu!
    var tenMinutesItem: NSMenuItem!
    var thirtyMinutesItem: NSMenuItem!
    var oneHourItem: NSMenuItem!
    
    var refreshItem: NSMenuItem!
    var quitItem: NSMenuItem!
    
    var plan: Plan = Plan.every(1.hour)
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            button.image = NSImage(named: "StatusIcon")
            startItem = NSMenuItem(title: "开机启动", action: #selector(startOnLunch), keyEquivalent: "s")
            startItem.state = LaunchAtLogin.isEnabled ? .on : .off
            
            intervalItem = NSMenuItem(title: "更新间隔", action: nil, keyEquivalent: "")
            intervalSubMenu = NSMenu()
            tenMinutesItem = NSMenuItem(title: "10分钟", action: #selector(setPlan(_:)), keyEquivalent: "")
            thirtyMinutesItem = NSMenuItem(title: "30分钟", action: #selector(setPlan(_:)), keyEquivalent: "")
            oneHourItem = NSMenuItem(title: "1小时", action: #selector(setPlan(_:)), keyEquivalent: "")
            oneHourItem.state = .on

            refreshItem = NSMenuItem(title: "刷新", action: #selector(refresh), keyEquivalent: "r")
            quitItem = NSMenuItem(title: "退出", action: #selector(quit), keyEquivalent: "q")

            intervalSubMenu.addItem(tenMinutesItem)
            intervalSubMenu.addItem(thirtyMinutesItem)
            intervalSubMenu.addItem(oneHourItem)
            
            intervalItem.submenu = intervalSubMenu
            
            statusMenu = NSMenu()
            statusMenu.addItem(startItem)
            statusMenu.addItem(intervalItem)
            statusMenu.addItem(refreshItem)
            statusMenu.addItem(.separator())
            statusMenu.addItem(quitItem)
            statusMenu.minimumWidth = 200
            statusItem.menu = statusMenu
        }
        updateMenuItem()
        getLaestImg()
        startPlan()
    }
    
    @objc func setPlan(_ sender: NSMenuItem) {
        switch sender {
        case tenMinutesItem:
            plan = Plan.every(10.minute)
            UserDefaults.standard.set(tenMinute, forKey: "interval")
        case thirtyMinutesItem:
            plan = Plan.every(30.minute)
            UserDefaults.standard.set(thirtyMinute, forKey: "interval")
        case oneHourItem:
            plan = Plan.every(1.hour)
            UserDefaults.standard.set(oneHour, forKey: "interval")
        default:
            plan = Plan.every(1.hour)
            UserDefaults.standard.set(oneHour, forKey: "interval")
        }
        updateMenuItem()
        startPlan()
    }
    
    func updateMenuItem() {
        statusItem.menu?.item(at: 1)?.submenu?.item(at: 0)?.state = .off
        statusItem.menu?.item(at: 1)?.submenu?.item(at: 1)?.state = .off
        statusItem.menu?.item(at: 1)?.submenu?.item(at: 2)?.state = .off
        var value: Int = oneHour
        value = UserDefaults.standard.integer(forKey: "interval")
        print(value)
        switch value {
        case tenMinute:
            statusItem.menu?.item(at: 1)?.submenu?.item(at: 0)?.state = .on
        case thirtyMinute:
            statusItem.menu?.item(at: 1)?.submenu?.item(at: 1)?.state = .on
        case oneHour:
            statusItem.menu?.item(at: 1)?.submenu?.item(at: 2)?.state = .on
        default:
            statusItem.menu?.item(at: 1)?.submenu?.item(at: 2)?.state = .on
        }
    }
    
    func startPlan() {
        _ = plan.do {
            getLaestImg()
        }
    }
    
    @objc func startOnLunch() {
        LaunchAtLogin.isEnabled = !LaunchAtLogin.isEnabled
        statusItem.menu?.item(at: 0)?.state = LaunchAtLogin.isEnabled ? .on : .off
        print("LaunchAtLogin: \(LaunchAtLogin.isEnabled)")
    }
    
    @objc func refresh() {
        getLaestImg()
    }

    @objc func quit() {
        NSApplication.shared.terminate(self)
    }
    
}
