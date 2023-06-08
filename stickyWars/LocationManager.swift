//
//  LocationManager.swift
//  stickyWars
//
//  Created by josefin hellgren on 2023-02-14.
//

import Foundation
import CoreLocation
class LocationManager : NSObject, CLLocationManagerDelegate, ObservableObject {
    
    static let shared = LocationManager()
    
    var location : CLLocationCoordinate2D?
    let manager = CLLocationManager()
    
    override init() {
        super.init()
        manager.delegate = self
    }
    
    func startLocationUpdates  ()  {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first?.coordinate
    }
}
