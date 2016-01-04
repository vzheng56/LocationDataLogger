//
//  ViewController.swift
//  LocationDataLogger
//
//  Created by Stuart Robinson on 06/05/2015.
//  Copyright (c) 2015 SJR Development. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    
    var lastLat = 0.0
    var lastLng = 0.0
    var lastTimestamp = NSDate()
    let formatter = NSDateFormatter()
    var journeyArray: [AnyObject] = []
    
    @IBOutlet weak var jsonOutputScreen: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("loaded ok")
        
        self.formatter.timeStyle = .MediumStyle
        self.formatter.dateStyle = .ShortStyle
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func JSONStringify(value: AnyObject, prettyPrinted: Bool = false) -> String {
        print("getting json...")
        
        let options = prettyPrinted ? NSJSONWritingOptions.PrettyPrinted : NSJSONWritingOptions.PrettyPrinted
        
        print(NSJSONSerialization.isValidJSONObject(value))
        
        if NSJSONSerialization.isValidJSONObject(value) {
            if let data = try? NSJSONSerialization.dataWithJSONObject(value, options: options) {
                if let string = NSString(data: data, encoding: NSUTF8StringEncoding) {
                    return string as String
                }
            }
        }
        return ""
    }
    
    @IBAction func getMyLocation(sender: AnyObject) {
        print("getting location");
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("updated location")
        
        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: {(placemarks, error)->Void in
            
            if (error != nil) {
                print("Reverse geocoder failed with error" + error!.localizedDescription)
                return
                
            }
            
            if (placemarks!.count > 0) {
                let pm = placemarks![0] as! CLPlacemark
                self.displayLocationInfo(pm)
            } else {
                print("Problem with the data received from geocoder")
            }
        })
    }
    
    func displayLocationInfo(placemark: CLPlacemark) {
        /*
        println("got new placemark")
        //stop updating location to save battery life
        // self.locationManager.stopUpdatingLocation()
        println("Latitude: \(placemark.location.coordinate.latitude)")
        println("Longitude: \(placemark.location.coordinate.longitude)")
        println("Locality: \(placemark.locality)")
        */
        
        /*
        println("Locality: \(placemark.locality)")
        println(placemark.postalCode)
        println(placemark.administrativeArea)
        println(placemark.country)
        */
        var thisDate = NSDate()
        
        
        if(self.lastLat == 0.0) {
            self.lastLat = placemark.location!.coordinate.latitude
            self.lastLng = placemark.location!.coordinate.longitude
            
            logChange(placemark.location!, thisDate: thisDate)
        }
        
        if(thisDate.timeIntervalSinceDate(self.lastTimestamp) >= 10) {
            self.lastTimestamp = thisDate
            
            print("got update")
            
            
            if(placemark.location!.coordinate.latitude != self.lastLat || placemark.location!.coordinate.longitude != self.lastLng) {
                
                logChange(placemark.location!, thisDate: thisDate)
                
            } else {
                print("But no change");
            }
            
        } else {
            return
        }
        
    }
    
    func logChange(placemark:CLLocation, thisDate:NSDate) {
        self.lastLat = placemark.coordinate.latitude
        self.lastLng = placemark.coordinate.longitude
        
        print("--New location--")
        // timestamp
        // string timestamp
        // placemark.location
        // latitude (double)
        // longitude (double)
        /*
        println("timestamp")
        println(thisDate)
        println("date")
        println(self.formatter.stringFromDate(thisDate))
        println("placemark")
        println(placemark.location)
        println("lat")
        println(Double(placemark.location.coordinate.latitude))
        println("lng")
        println(Double(placemark.location.coordinate.longitude))
        */
        
        let newRowData = [
            "tstamp": thisDate.description,
            "date": self.formatter.stringFromDate(thisDate),
            "placemark": placemark.description,
            "lat": Double(placemark.coordinate.latitude),
            "lng": Double(placemark.coordinate.longitude)
        ]
        
        print(newRowData)
        self.journeyArray.append(newRowData)
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("failed to update location \(error.localizedDescription)");
    }
    
    @IBAction func finishJourney(sender: AnyObject) {
        print("---Journey complete---")
        self.locationManager.stopUpdatingLocation()
        
        let jsonStringPretty = JSONStringify(self.journeyArray, prettyPrinted: true)
        print(jsonStringPretty)
        self.jsonOutputScreen.text = jsonStringPretty
    }
    
}

