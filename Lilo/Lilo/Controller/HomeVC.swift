//
//  HomeVC.swift
//  Lilo
//
//  Created by Maïlys Perez on 29/12/2020.
//

import UIKit
import MapKit
import CoreLocation

class HomeVC: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var pullUpViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var mapViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var pullUpView: UIView!
    
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
                BikeService.instance.getAllAvailableBikesInStations { (success) in
                    if success {
                        let bikesByStationsId = BikeService.instance.sortNbrBikesByTenCLosestLocation()
                        print("bikesByStationsId: \(bikesByStationsId)")
                    }
                }
            }
        }
    }

    func addSwipe() {
        print("into add swipe")
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(animateViewDown))

        swipe.direction = .down
        pullUpView.addGestureRecognizer(swipe)
    }

    func animateViewUp() {
        pullUpViewHeightConstraint.constant = 300
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }

    @objc func animateViewDown() {
        print("animating down")
        pullUpViewHeightConstraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
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

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        animateViewUp()
        addSwipe()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }

        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "stationPin") as? MKPinAnnotationView
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "stationPin")
                annotationView?.pinTintColor = #colorLiteral(red: 0.1568627451, green: 0.5176470588, blue: 1, alpha: 1)
                annotationView?.canShowCallout = false
            } else {
                annotationView?.annotation = annotation
            }
            return annotationView
    }
    
    func displayStationPin(locations: [CLLocation]) {
        for i in 0..<locations.count {
            let pinCoordinate = locations[i].coordinate
            print("pinCoordinate: \(pinCoordinate)")
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
