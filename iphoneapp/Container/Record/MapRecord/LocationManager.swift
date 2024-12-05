//
//  LocationManager.swift
//  iphoneapp
//
//  Created by mac on 11/19/24.
//

import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var trackedLocations: [CLLocationCoordinate2D] = []
    @Published var currentLocation: CLLocation?
    @Published var authorization : CLAuthorizationStatus?
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        
    }

    func requestAuthorization() {
        manager.requestWhenInUseAuthorization()
        
    }

    func startUpdatingLocation() {
        manager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation(){
        manager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            currentLocation = location
            
            DispatchQueue.main.async {
                self.trackedLocations.append(location.coordinate)
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            authorization = status
        }
    }
}
