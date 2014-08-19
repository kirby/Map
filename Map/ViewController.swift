//
//  ViewController.swift
//  Map
//
//  Created by Kirby Shabaga on 8/18/14.
//  Copyright (c) 2014 Worxly. All rights reserved.
//

import CoreData
import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate, MKMapViewDelegate, UIGestureRecognizerDelegate, AddReminderDelegate {
                            
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var latTextField: UITextField!
    @IBOutlet weak var longTextField: UITextField!
    
    @IBOutlet weak var currentLat: UILabel!
    @IBOutlet weak var currentLong: UILabel!
    
    @IBAction func toggleTrackingButton(sender: UIButton) {
        self.updatingLocations = !self.updatingLocations
        if self.updatingLocations {
            sender.setTitle("Stop Tracking", forState: UIControlState.Normal)
            self.coreLocationManager.startUpdatingLocation()
        } else {
            sender.setTitle("Start Tracking", forState: UIControlState.Normal)
            self.coreLocationManager.stopUpdatingLocation()
        }
    }
    
    // --------------------------------------------------------------------------------
    
    var myContext : NSManagedObjectContext!
    var reminders = [Reminder]()

    let coreLocationManager = CLLocationManager()
    var gestureRecognizer = UIGestureRecognizer()
    
    var updatingLocations = false
    
    // --------------------------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setDefaultLocation()
        self.coreLocationManager.delegate = self
        self.mapView.delegate = self
        if self.checkCoreLocationAuthorization() {
            // get current position
            self.mapView.showsUserLocation = true
            setCurrentLocation()
            self.gestureRecognizer = self.setupGestureRecognizer()
        }
        self.loadReminders()
        
    }
    
    func loadReminders() {
        println("load reminders")
        var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        self.myContext = appDelegate.managedObjectContext
        
        var request = NSFetchRequest(entityName: "Reminder")
        var error : NSError?
        self.reminders = self.myContext.executeFetchRequest(request, error: &error) as [Reminder]
        if error != nil {
            println("\(error?.localizedDescription)")
        }
    }
    
    func setupGestureRecognizer() -> UILongPressGestureRecognizer {
        var gr = UILongPressGestureRecognizer(target: self, action: Selector("handleLongTouch:"))
//        gr.numberOfTouchesRequired = 1
//        gr.numberOfTapsRequired = 1
        
        gr.delegate = self
        self.mapView.addGestureRecognizer(gr)
        
        return gr
    }
    
    func setDefaultLocation() {
        self.latTextField.text = "47.6204"
        self.longTextField.text = "-122.3491"
        
        self.mapView.showsUserLocation = true
        self.mapView.userLocation.title = "You"
        self.mapView.userLocation.subtitle = "Are here!"
    }
    
    func setCurrentLocation() {
//        if self.coreLocationManager.location == nil { return }
//        
//        let lat = self.coreLocationManager.location.coordinate.latitude
//        let long = self.coreLocationManager.location.coordinate.longitude
//        
//        self.latTextField.text = lat.description
//        self.longTextField.text = long.description
        
        if self.mapView.userLocation.location == nil { return }
        
        let lat = self.mapView.userLocation.location.coordinate.latitude
        let long = self.mapView.userLocation.location.coordinate.longitude
        
        flyToLocation(lat, long: long)
        
    }
    
    func checkCoreLocationAuthorization() -> Bool {
        
        var authorized = false
        
        let authz = CLLocationManager.authorizationStatus() as CLAuthorizationStatus
        
        switch authz {
        case .NotDetermined:
            self.coreLocationManager.requestWhenInUseAuthorization()
        case .Restricted:
            println("Display custom view asking for permission again")
        case .Denied:
            println("Display custom view asking for permission again")
        case .Authorized:
            println("Good to go")
            authorized = true
        case .AuthorizedWhenInUse:
            println("Good to go")
            authorized = true
        default:
            println("checkCoreLocationAuthorization = default")
        }
        
        return authorized
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func goButtonPressed(sender: AnyObject) {
        println("go!")
        
        let lat = NSString(string: self.latTextField.text).doubleValue
        let long = NSString(string: self.longTextField.text).doubleValue

        self.flyToLocation(lat, long: long)
    }
    
    func flyToLocation(lat : Double, long : Double) {
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        let camera = MKMapCamera(lookingAtCenterCoordinate: coordinate, fromEyeCoordinate: coordinate, eyeAltitude: 10000)
        self.mapView.setCamera(camera, animated: true)
    }
    
    func handleLongTouch(sender : UILongPressGestureRecognizer) {
        switch sender.state {
        case .Began:
            println("handleLongTouch began")
            self.performSegueWithIdentifier("addReminder", sender: self)
        case .Changed:
            println("handleLongTouch change")
        case .Ended:
            println("handleLongTouch ended")
        default:
            println("handleLongTouch default")
        }
       
        
//        var point = MKPointAnnotation().setCoordinate(newCoordinate: CLLocationCoordinate2D)
//        var annotation = MKAnnotation.setCoordinate(self.mapView.)
        
//        self.mapView.annotations.append(annotation)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        if segue.identifier == "addReminder" {
            var addReminderVC = segue.destinationViewController as AddReminderViewController
            addReminderVC.location = self.mapView.userLocation.location
            addReminderVC.delegate = self
            addReminderVC.myContext = self.myContext
        }
    }
    
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        println("didSelectAnnotationView")
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if annotation is MKUserLocation {
            return nil
        }
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.animatesDrop = true
            pinView!.pinColor = .Green
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    // --------------------------------------------------------------------------------

    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let lastLocation = locations.last as? CLLocation
        println("lastLocation = \(lastLocation?.description)")
        
        let lat = lastLocation?.coordinate.latitude
        let long = lastLocation?.coordinate.longitude

        
        self.currentLat.text = "\(lat!)"
        self.currentLong.text = "\(long!)"
        
        flyToLocation(lat!, long: long!)
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        println("manager = \(manager)")
        switch status {
        case .Authorized:
            println("good to go!")
        case .AuthorizedWhenInUse:
            println("good to go!")
        case .Denied:
            println("ask for permission")
        case .NotDetermined:
            println("ask for permission")
        case .Restricted:
            println("ask for permission")
        default:
            println("status = default")
        }
    }
    
    // --------------------------------------------------------------------------------
    
    func addReminder(reminder: Reminder) {
        println("add reminder \(reminder)")
    }

}

