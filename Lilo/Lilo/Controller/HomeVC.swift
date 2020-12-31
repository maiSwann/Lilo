//
//  HomeVC.swift
//  Lilo
//
//  Created by Maïlys Perez on 29/12/2020.
//

import UIKit
import MapKit
import CoreLocation

class HomeVC: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager = CLLocationManager()
    let regionRadius: Double = 1000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        configureLocationServices()
        
        StationService.instance.getAllStations { (success) in
            if success {
                let coordinate: CLLocationCoordinate2D = self.locationManager.location!.coordinate
                let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                let closestTenLocation = StationService.instance.sortedByTenClosestLocation(userLocation: location)
                
                self.displayStationPin(locations: closestTenLocation)
                /* Call request bike
                    if !sucess return
                 */
                BikeService.instance.getAllAvailableBikesInStations { (success) in
                    if !success {
                        return
                    }
                }
            }
        }
    }
    
    @IBAction func centerMapBtnWasPressed(_ sender: Any) {
        if locationManager.authorizationStatus == .authorizedAlways || locationManager.authorizationStatus == .authorizedWhenInUse {
            centerMapOnUserLocation()
        }
    }
}

extension HomeVC: MKMapViewDelegate {
    func centerMapOnUserLocation() {
        let coordinate: CLLocationCoordinate2D = locationManager.location!.coordinate
        let coordinateRegion = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func displayStationPin(locations: [CLLocation]) {
        for i in 0..<locations.count {
            let pinCoordinate = locations[i].coordinate
            let annotation = StationPin(coordinate: pinCoordinate, identifier: "stationPin")
            mapView.addAnnotation(annotation)
        }
    }
}

extension HomeVC: CLLocationManagerDelegate {
    func configureLocationServices() {
        if locationManager.authorizationStatus != .notDetermined {
            return
        }
        locationManager.requestAlwaysAuthorization()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.first == nil {
            return
        }
        centerMapOnUserLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
}
