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
    @IBOutlet weak var pullUpView: PullUpView!
    
    var locationManager = CLLocationManager()
    let regionRadius: Double = 1000
    var spinner2: UIActivityIndicatorView!
    var screenSize = UIScreen.main.bounds
    
    var bikesTitleLbl: UILabel?
    var bikesByStationsId: [Int:Int]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        configureLocationServices()
        addSpinner()
        
        StationService.instance.getAllStations { (success) in
            if success {
                let coordinate: CLLocationCoordinate2D = self.locationManager.location!.coordinate
                let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                let closestTenLocation = StationService.instance.sortedByTenClosestLocation(userLocation: location)
                
                self.displayStationPin(locations: closestTenLocation)
                BikeService.instance.getAllAvailableBikesInStations { (success) in
                    if success {
                        let bikesByStationsId = BikeService.instance.sortNbrBikesByTenCLosestLocation()
                        self.bikesByStationsId = bikesByStationsId
                        if self.bikesByStationsId != nil {
                            self.hideSpinner()
                        }
                    }
                }
            }
        }
    }
    
    func addSpinner() {
        spinner2 = UIActivityIndicatorView(frame: CGRect(x: (screenSize.width / 2) - 50, y: (screenSize.height / 2) - 50, width: 100, height: 100))
        spinner2.style = .large
        spinner2.color = #colorLiteral(red: 0.1568627451, green: 0.5176470588, blue: 1, alpha: 1)
        spinner2.startAnimating()
        mapView.addSubview(spinner2)
    }
    
    func hideSpinner() {
        spinner2.isHidden = true
    }

    func addSwipe() {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(animateViewDown))

        swipe.direction = .down
        pullUpView.addGestureRecognizer(swipe)
    }

    @objc func animateViewUp() {
        pullUpViewHeightConstraint.constant = screenSize.height / 5
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }

    @objc func animateViewDown() {
        pullUpViewHeightConstraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func displayNbrBikesAvailable(bikesNbr: Int) {
        
        bikesTitleLbl = UILabel(frame: CGRect(x: (screenSize.width / 2), y: 175, width: 200, height: 40))
        bikesTitleLbl!.center = CGPoint(x: (screenSize.width / 2), y: screenSize.height / 10)
        bikesTitleLbl!.textAlignment = .center
        bikesTitleLbl!.font = UIFont(name: "Gordita Medium", size: 18)
        bikesTitleLbl!.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        bikesTitleLbl!.text = "Vélos disponibles: \(bikesNbr)"
        pullUpView.addSubview(bikesTitleLbl!)
    }
    
    func removeNbrBikesAvailable() {
        if bikesTitleLbl != nil {
            bikesTitleLbl?.removeFromSuperview()
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
        let coordinate = view.annotation!.coordinate
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let id = StationService.instance.getStationIdByLocation(stationLocation: location)
        
        if spinner2.isHidden == true {
            removeNbrBikesAvailable()
            animateViewUp()
            addSwipe()
            if bikesByStationsId != nil {
                let nbr = BikeService.instance.getBikesNbrById(bikesByStationsId: bikesByStationsId!, stationId: id)
                displayNbrBikesAvailable(bikesNbr: nbr)
            }
        }
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
