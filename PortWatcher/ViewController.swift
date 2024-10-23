//
//  ViewController.swift
//  PortWatcher
//
//  Created by Jarvis on 10/23/24.
//  Copyright © 2024 AMS. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet weak var outPutTextView: NSScrollView!
    @IBOutlet var outPut: NSTextView!
    @IBOutlet weak var commandPopUpButton: NSPopUpButton! // Connect this to your pop-up button in the storyboard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Enable layer for the NSTextView
        outPutTextView.wantsLayer = true
        outPutTextView.layer?.cornerRadius = 10.0
        outPutTextView.layer?.borderColor = NSColor.gray.cgColor
        outPutTextView.layer?.borderWidth = 7.0
        outPutTextView.layer?.masksToBounds = true
        
        // Set the font for the NSTextView
        let font = NSFont(name: "Courier", size: 10.0)
        outPut.font = font // Set the font for the NSTextView
    }
    
    @IBAction func InPut(_ sender: Any) {
        RunCommand()
    }
    
    func RunCommand() {
        
        // Get the selected command from the pop-up button
        guard let selectedItem = commandPopUpButton.selectedItem else {
            DispatchQueue.main.async {
                self.outPut.string = "No command selected."
            }
            return
        }
        
        // Retrieve the tag
        let selectedCommand = selectedItem.tag
        
        // Print the selected command to debug
        print("Selected command: \(selectedCommand)")
        
        // Prepare the command based on the selection
        var command = ""
        switch selectedCommand {
        case 1:
            command = "sudo -S netstat -plnt"
        case 2:
            command = "sudo -S lsof -i -n -P | grep TCP"
        case 3:
            command = "netstat -p tcp -van | grep '^Proto\\|LISTEN'"
        case 4:
            command = "lsof -Pi | grep -i listen"
        default:
            DispatchQueue.main.async {
                self.outPut.string = "Invalid command selected."
            }
            return
        }
        
        // Prompt user for password
        let password = getPasswordFromUser()
        if password.isEmpty {
            DispatchQueue.main.async {
                self.outPut.string = "No password entered."
            }
            return
        }
        
        // Execute the command
        let fullCommand = "echo \(password) | " + command // Using echo to provide the password
        
        let task = Process()
        let pipe = Pipe()
        
        task.standardOutput = pipe
        task.standardError = pipe
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", fullCommand] // Execute command directly
        
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? "No output"
        
        DispatchQueue.main.async {
            self.outPut.string = output
        }
    }
    
    func getPasswordFromUser() -> String {
        
        // Prompt for the password using an alert dialog
        let alert = NSAlert()
        alert.messageText = "Enter Admin Pass"
        alert.informativeText = "Please enter your administrator password."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        
        let passwordField = NSSecureTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        alert.accessoryView = passwordField
        
        if alert.runModal() == .alertFirstButtonReturn {
            return passwordField.stringValue
        }
        
        return ""
    }
}
