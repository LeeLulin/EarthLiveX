//
//  StatusBarController.swift
//  EarthLiveX
//
//  Created by Ryinn on 2022/3/23.
//

import AppKit

class StatusBarController {
    private var statusBar: NSStatusBar
    private var statusItem: NSStatusItem
    private var mainView: NSView

    init(_ view: NSView) {
        self.mainView = view
        statusBar = NSStatusBar()
        statusItem = statusBar.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.image = NSImage(named: "StatusIcon")
            let menuItem = NSMenuItem()
            menuItem.view = mainView
            let menu = NSMenu()
            menu.addItem(menuItem)
            statusItem.menu = menu
        }
    }
}
