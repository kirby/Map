//
//  ViewController.swift
//  Map
//
//  Created by Kirby Shabaga on 8/18/14.
//  Copyright (c) 2014 Worxly. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {
                            
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
    
    let coreLocationManager = CLLocationManager()
    var gestureRecognizer = UIGestureRecognizer()
    
    var updatingLocations = false
    
    // --------------------------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setDefaultLocation()
        self.coreLocationManager.delegate = self
        if self.checkCoreLocationAuthorization() {
            // get current position
            setCurrentLocation()
            self.gestureRecognizer = self.setupGestureRecognizer()
        }
    }
    
    func setupGestureRecognizer() -> UILongPressGestureRecognizer {
        var gr = UILongPressGestureRecognizer(target: self.mapView, action: Selector("handleLongTouch:"))
        return gr
    }
    
    func setDefaultLocation() {
        self.latTextField.text = "47.6204"
        self.longTextField.text = "-122.3491"
    }
    
    func setCurrentLocation() {
        println("location = \(self.coreLocationManager.location)")
        
        if self.coreLocationManager.location == nil { return }
        
        let lat = self.coreLocationManager.location.coordinate.latitude
        let long = self.coreLocationManager.location.coordinate.longitude
        
        self.latTextField.text = lat.description
        self.longTextField.text = long.description
        
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
//            self.coreLocationManager.startUpdatingLocation()
            authorized = true
        case .AuthorizedWhenInUse:
            println("Good to go")
//            self.coreLocationManager.startUpdatingLocation()
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
        println("sender = \(sender)")
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

}

