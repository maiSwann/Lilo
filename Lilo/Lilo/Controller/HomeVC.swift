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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        configureLocationServices()
    }

    @IBAction func centerMapBtnWasPressed(_ sender: Any) {
    }
}

extension HomeVC: MKMapViewDelegate {
}

extension HomeVC: CLLocationManagerDelegate {
    func configureLocationServices() {
        if locationManager.authorizationStatus == .notDetermined {
             locationManager.requestAlwaysAuthorization()
        } else {
            return
        }
    }
}
