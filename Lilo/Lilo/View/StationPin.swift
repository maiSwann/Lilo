//
//  StationPin.swift
//  Lilo
//
//  Created by Maïlys Perez on 30/12/2020.
//

import UIKit
import MapKit

class StationPin: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var identifier: String
    
    init(coordinate: CLLocationCoordinate2D, identifier: String) {
        self.coordinate = coordinate
        self.identifier = identifier
        super.init()
    }
}
