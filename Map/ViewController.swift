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

class ViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate, MKMapViewDelegate, UIGestureRecognizerDelegate {
                            
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var latTextField: UITextField!
    @IBOutlet weak var longTextField: UITextField!
    
    @IBOutlet weak var currentLat: UILabel!
    @IBOutlet weak var currentLong: UILabel!
    
    // --------------------------------------------------------------------------------
    
    var moc : NSManagedObjectContext!
    var reminders : [Reminder]!

    let coreLocationManager = CLLocationManager()
    var gestureRecognizer = UIGestureRecognizer()
    
    var updatingLocations = false
    
    // --------------------------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        self.moc = appDelegate.managedObjectContext
        
        self.coreLocationManager.delegate = self
        self.mapView.delegate = self
        
        self.setDefaultLocation()

        if self.checkCoreLocationAuthorization() {
            // get current position
            self.mapView.showsUserLocation = true
            setCurrentLocation()
            self.gestureRecognizer = self.setupGestureRecognizer()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loadReminders()
        
        if let allAnnotations = self.mapView.annotations as? [MKAnnotation] {
            self.mapView.removeAnnotations(allAnnotations)
            self.loadAnnotations()
        }
    }
    
    func loadReminders() {
        var request = NSFetchRequest(entityName: "Reminder")
        let sort = NSSortDescriptor(key: "message", ascending: true)
        request.sortDescriptors = [sort]
        request.fetchBatchSize = 20
        
        var error : NSError?
        
        self.reminders = self.moc.executeFetchRequest(request, error: &error) as [Reminder]
    }
    
    func loadAnnotations() {
        for reminder in reminders {
            println("load reminder \(reminder.message)")
            self.addAnnotation(reminder)
        }
    }
    
    func setDefaultLocation() {
        self.latTextField.text = "47.6204"
        self.longTextField.text = "-122.3491"
        
        self.mapView.showsUserLocation = true
        self.mapView.userLocation.title = "You"
        self.mapView.userLocation.subtitle = "Are here!"
    }
    
    func setupGestureRecognizer() -> UILongPressGestureRecognizer {
        var gr = UILongPressGestureRecognizer(target: self, action: Selector("handleLongTouch:"))
        gr.delegate = self
        self.mapView.addGestureRecognizer(gr)
        return gr
    }

    func setCurrentLocation() {
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
            println("authorizationStatus NotDetermined; ask permission")
            self.coreLocationManager.requestWhenInUseAuthorization()
        case .Restricted:
            println("authorizationStatus Restricted; Display custom view asking for permission again")
        case .Denied:
            println("authorizationStatus; Denied; Display custom view asking for permission again")
        case .Authorized:
            println("authorizationStatus Authorized")
            authorized = true
        case .AuthorizedWhenInUse:
            println("authorizationStatus AuthorizedWhenInUse")
            authorized = true
        default:
            println("authorizationStatus default")
        }
        
        return authorized
    }
    
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

    @IBAction func goButtonPressed(sender: AnyObject) {
        let lat = NSString(string: self.latTextField.text).doubleValue
        let long = NSString(string: self.longTextField.text).doubleValue
        self.flyToLocation(lat, long: long)
    }
    
    func flyToLocation(lat : Double, long : Double) {
        println("flyToLocation \(lat) \(long)")
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        let camera = MKMapCamera(lookingAtCenterCoordinate: coordinate, fromEyeCoordinate: coordinate, eyeAltitude: 10000)
        self.mapView.showsUserLocation = true
        self.mapView.setCamera(camera, animated: true)
    }
    
    func handleLongTouch(sender : UILongPressGestureRecognizer) {
        switch sender.state {
        case .Began:
            println("handleLongTouch began")
            var touchPoint = sender.locationInView(self.mapView)
            var coordinate = self.mapView.convertPoint(touchPoint, toCoordinateFromView: self.mapView)
            addAnnotation(coordinate)
        case .Changed:
            println("handleLongTouch change")
        case .Ended:
            println("handleLongTouch ended")
        default:
            println("handleLongTouch default")
        }
    }
    
    func addAnnotation(coordinate : CLLocationCoordinate2D) {
        var annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "Add Reminder"
        self.mapView.addAnnotation(annotation)
        println("added annoation at \(annotation.coordinate.latitude) \(annotation.coordinate.longitude)")
        
    }
    
    func addAnnotation(reminder : Reminder) {
        var annotation = MKPointAnnotation()
        annotation.coordinate.latitude = reminder.lat
        annotation.coordinate.longitude = reminder.long
        annotation.title = reminder.message
        self.mapView.addAnnotation(annotation)
        println("added annoation at \(annotation.coordinate.latitude) \(annotation.coordinate.longitude)")
    }
    
    func saveAnnotation(coordinate : CLLocationCoordinate2D) {
        println("saveAnnotation \(coordinate.latitude) \(coordinate.longitude)")
        var newReminder = NSEntityDescription.insertNewObjectForEntityForName("Reminder", inManagedObjectContext: self.moc) as Reminder

        newReminder.lat = coordinate.latitude
        newReminder.long = coordinate.longitude
        newReminder.message = "Reminder #1"
        
        var error : NSError?
        
        self.moc.save(&error)
        
        if error != nil {
            println("Trouble saving Reminder: \(error?.localizedDescription)")
        }
    }
    
    // MARK: - MKMapViewDelegate
    
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        println("didSelectAnnotationView")
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {

        if annotation is MKUserLocation {
            return nil
        }
        
        var calloutButton = UIButton.buttonWithType(.ContactAdd) as UIButton
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.animatesDrop = true
            pinView!.pinColor = .Green
            pinView!.rightCalloutAccessoryView = calloutButton
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        
        println("calloutAccessoryControlTapped")
        
        var coordinate = view.annotation.coordinate
        var region = CLCircularRegion(center: coordinate, radius: 200, identifier: "Reminder!")

        self.coreLocationManager.startMonitoringForRegion(region)
        
        self.saveAnnotation(coordinate)

    }
    
    // --------------------------------------------------------------------------------
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!) {
        println("did enter region")
    }
    
    func locationManager(manager: CLLocationManager!, didExitRegion region: CLRegion!) {
        println("did exit region")
    }

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
        switch status {
        case .Authorized:
            println("locationManager Authorized")
        case .AuthorizedWhenInUse:
            println("locationManager AuthorizedWhenInUse")
        case .Denied:
            println("locationManager Denied")
        case .NotDetermined:
            println("locationManager NotDetermined")
        case .Restricted:
            println("locationManager Restricted")
        default:
            println("locationManager default")
        }
    }

}

