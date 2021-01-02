//
//  StationService.swift
//  Lilo
//
//  Created by Maïlys Perez on 30/12/2020.
//

import Foundation
import Alamofire
import SwiftyJSON
import CoreLocation

class StationService {
    static let instance = StationService()
    
    var stations: Stations!
    
    func getAllStations(completion: @escaping CompletionHandler) {
        AF.request("\(URL_STATIONS_INFOS)", method: .get).responseJSON { (response) in
    
            switch response.result {
            case .success( _):
                guard let data = response.data else { return }
                self.parseStation(data: data)
                completion(true)
            case .failure(let error):
                completion(false)
                debugPrint(error)
            }
        }
    }
    
    func parseStation(data: Data) {
        let json = try! JSON(data: data)
        var stationsLocation = [CLLocation]()
        var stationsIdByLocation = [CLLocation:Int]()
        
        if let items = json["data"]["stations"].array {
            for item in items {
                let id = item["station_id"].intValue
                let lat = item["lat"].doubleValue
                let lon = item["lon"].doubleValue
                let coordonate = CLLocation(latitude: lat, longitude: lon)

                stationsLocation.append(coordonate)
                stationsIdByLocation[coordonate] = id
            }
            stations = Stations(stationsLocation: stationsLocation, stationsIdByLocation: stationsIdByLocation)
        }
    }
    
    func sortedByTenClosestLocation(userLocation: CLLocation) -> [CLLocation] {
        stations.stationsLocation = [CLLocation]((stations.stationsLocation.sorted(by: { userLocation.distance(from: $0) < userLocation.distance(from: $1)}).prefix(10)))
        return stations.stationsLocation
    }
    
    func getStationIdByLocation(stationLocation: CLLocation) -> Int {
        var id = 0
        
        for (key, value) in stations.stationsIdByLocation {
            if stationLocation.coordinate.longitude == key.coordinate.longitude &&
                stationLocation.coordinate.latitude == key.coordinate.latitude {
                id = value
            }
        }
        return id
    }
}
