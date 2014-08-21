//
//  RemindersViewController.swift
//  Map
//
//  Created by Kirby Shabaga on 8/20/14.
//  Copyright (c) 2014 Worxly. All rights reserved.
//

import CoreData
import UIKit

protocol RemindersViewDelegate {
    func removeAnnotation()
}

class RemindersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var moc : NSManagedObjectContext!
    var fetchedResultsController : NSFetchedResultsController!
    
    var selectedCell : UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupEditButtonItem()
        self.setupFetchedResultsController()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        var error : NSError?
        self.fetchedResultsController?.performFetch(&error)
        if error != nil {
            println("viewWillAppear \(error?.localizedDescription)")
        }
    }
    
    func setupEditButtonItem() {
        var editButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Edit, target: self, action: Selector("toggleEditMode:"))
        self.navigationItem.rightBarButtonItem = editButtonItem
    }
    
    func toggleEditMode(sender : UIBarButtonItem) {
        self.tableView.editing = !self.tableView.editing
    }
    
    func setupFetchedResultsController() {
        var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        self.moc = appDelegate.managedObjectContext
        
        var request = NSFetchRequest(entityName: "Reminder")
        let sort = NSSortDescriptor(key: "message", ascending: true)
        request.sortDescriptors = [sort]
        request.fetchBatchSize = 20
        
        var error : NSError?
        
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: self.moc, sectionNameKeyPath: nil, cacheName: nil)
        self.fetchedResultsController.delegate = self
    }
    
    // ----------------------------------------------------------------
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return self.fetchedResultsController!.sections[section].numberOfObjects
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        var cell = tableView.dequeueReusableCellWithIdentifier("ReminderCell", forIndexPath: indexPath) as UITableViewCell
        self.configureCell(cell, forIndexPath: indexPath)
        return cell
    }
    
    func configureCell(cell : UITableViewCell, forIndexPath indexPath: NSIndexPath) {
        var reminderForRow = self.fetchedResultsController.fetchedObjects[indexPath.row] as Reminder
        cell.textLabel.text = reminderForRow.message
//        if self.tableView.editing {
            cell.showsReorderControl = true
//        }
    }
    
    // ----------------------------------------------------------------
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(controller: NSFetchedResultsController!) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController!, didChangeSection sectionInfo: NSFetchedResultsSectionInfo!, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete:
            self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        default:
            self.tableView.reloadSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        }
    }
    
    func controller(controller: NSFetchedResultsController!, didChangeObject anObject: AnyObject!, atIndexPath indexPath: NSIndexPath!, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath!) {
        switch type {
        case .Insert:
            self.tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
        case .Delete:
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        case .Update:
            self.configureCell(self.tableView.cellForRowAtIndexPath(indexPath), forIndexPath: indexPath)
        case .Move:
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            self.tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController!) {
        self.tableView.endUpdates()
    }
    
    // -------------------------------
    
    func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
        // don't need anything here, just have to implement it for the respondsToSelector test
    }
    
    func tableView(tableView: UITableView!, editActionsForRowAtIndexPath indexPath: NSIndexPath!) -> [AnyObject]! {
        let deleteAction = UITableViewRowAction(style: .Default, title: "Delete") { (action, indexPath) -> Void in
            println("Delete row \(indexPath.row)")
            if let reminderForRow = self.fetchedResultsController.fetchedObjects[indexPath.row] as? Reminder {
                self.moc.deleteObject(reminderForRow)
                var error : NSError?
                self.moc.save(&error)
                if error != nil {
                    println("Error during delete: \(error?.localizedDescription)")
                }
                self.fetchedResultsController.fetchRequest
            }
        }
        deleteAction.backgroundColor = UIColor.redColor()
        
        let editAction = UITableViewRowAction(style: .Default, title: "Edit") { (action, indexPath) -> Void in
            println("TODO - edit reminder")
            self.selectedCell = tableView.cellForRowAtIndexPath(indexPath) as UITableViewCell
            self.performSegueWithIdentifier("EditReminder", sender: self)
        }
        editAction.backgroundColor = UIColor.lightGrayColor()
        
        return [deleteAction, editAction]
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        if segue.identifier == "EditReminder" {
            var editReminderVC = segue.destinationViewController as EditReminderViewController
            var reminder = self.fetchedResultsController.objectAtIndexPath(self.tableView.indexPathForCell(self.selectedCell)) as Reminder
            editReminderVC.reminder = reminder
        }
    }
    
    func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        println("canEditRowAtIndexPath \(indexPath.row)")
        return true
    }
    
    func tableView(tableView: UITableView!, canMoveRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        println("canMoveRowAtIndexPath \(indexPath.row)")
        return true
    }
    
    func tableView(tableView: UITableView!, moveRowAtIndexPath sourceIndexPath: NSIndexPath!, toIndexPath destinationIndexPath: NSIndexPath!) {
        println("moveRowAtIndexPath")
        
    }


}