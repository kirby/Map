//
//  AddReminderViewController.swift
//  Map
//
//  Created by Kirby Shabaga on 8/19/14.
//  Copyright (c) 2014 Worxly. All rights reserved.
//

import CoreData
import CoreLocation
import UIKit

protocol EditReminderDelegate {
    func updateReminder(reminder : Reminder)
}

class EditReminderViewController: UIViewController {

    @IBOutlet weak var latTextField: UILabel!
    @IBOutlet weak var longTextField: UILabel!
    @IBOutlet weak var messageText: UITextView!
    
    var reminder : Reminder!
    
    var myContext : NSManagedObjectContext!
    var delegate : EditReminderDelegate!
    var location : CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.latTextField.text = "\(reminder.lat)"
        self.longTextField.text = "\(reminder.long)"
        self.messageText.text = reminder.message
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func saveReminderButtonPressed(sender: AnyObject) {
        println("update reminder")
        reminder.message = messageText.text
        var error : NSError?
        reminder.managedObjectContext.save(&error)
//        self.dismissViewControllerAnimated(true, completion: nil)
        self.navigationController.popToRootViewControllerAnimated(true)
    }

}
