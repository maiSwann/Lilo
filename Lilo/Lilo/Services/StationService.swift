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
    
    var stations = [Station]()
    var stationsId = [Int]()
    var stationsLocation = [CLLocation]()
    
    // Test by dic
    var stationsDict = [CLLocation:Int]()
    
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
        /*
         Parse stationID + lat + lon
         Créer CLLocation
         Comparer closest location avec tab CLLocation, tab station id (Index correspondent)
         return Dict avec station id, Cllocation pour les 10 plus proches
         */
        let json = try! JSON(data: data)
        
        if let items = json["data"]["stations"].array {
            for item in items {
                let id = item["station_id"].intValue
                let lat = item["lat"].doubleValue
                let lon = item["lon"].doubleValue
                let coordonate = CLLocation(latitude: lat, longitude: lon)
//                let station = Station(stationId: id, stationLocation: coordonate)
//
//                stations.append(station)
                stationsId.append(id)
                stationsLocation.append(coordonate)
                stationsDict[coordonate] = id
            }
        }
    }
    
    func sortedByTenClosestLocation(userLocation: CLLocation) -> [CLLocation] {
        print("UserLocation = \(userLocation)")
        return [CLLocation](stationsLocation.sorted(by: { userLocation.distance(from: $0) < userLocation.distance(from: $1)}).prefix(10))
    }
}
