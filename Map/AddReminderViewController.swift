//
//  AddReminderViewController.swift
//  Map
//
//  Created by Kirby Shabaga on 8/19/14.
//  Copyright (c) 2014 Worxly. All rights reserved.
//

import UIKit
import CoreLocation

protocol AddReminderDelegate {
    func addReminder(reminder : Reminder)
}

class AddReminderViewController: UIViewController {

    @IBOutlet weak var latTextField: UILabel!
    @IBOutlet weak var longTextField: UILabel!
    @IBOutlet weak var messageText: UITextView!
    
    var delegate : AddReminderDelegate!
    var location : CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.latTextField.text = "\(self.location.coordinate.latitude)"
        self.longTextField.text = "\(self.location.coordinate.longitude)"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func saveReminderButtonPressed(sender: AnyObject) {
        println("save reminder")
        
        var reminder = Reminder()
        
        reminder.lat = self.location.coordinate.latitude
        reminder.long = self.location.coordinate.longitude
        
        reminder.message = messageText.text
        
        self.delegate.addReminder(reminder)
    }

}
