//
//  BikeService.swift
//  Lilo
//
//  Created by Maïlys Perez on 31/12/2020.
//

import Foundation
import Alamofire
import SwiftyJSON

class BikeService {
    static let instance = BikeService()
    
    var stations: Stations!
    var bikes: Bikes!
    
    func getAllAvailableBikesInStations(completion: @escaping CompletionHandler) {
        AF.request("\(URL_BIKES_IN_STATIONS_INFOS)", method: .get).responseJSON { (response) in
            
            switch response.result {
            case .success( _):
                guard let data = response.data else { return }
                self.parseBikesInStations(data: data)
                completion(true)
            case .failure(let error):
                completion(false)
                debugPrint(error)
            }
        }
    }
    
    func parseBikesInStations(data: Data) {
        let json = try! JSON(data: data)
        var bikesByStationsId = [Int:Int]()
        
        if let items = json["data"]["stations"].array {
            for item in items {
                let id = item["station_id"].intValue
                let nbrBikes = item["numBikesAvailable"].intValue
        
                bikesByStationsId[id] = nbrBikes
            }
            bikes = Bikes(bikesByStationsId: bikesByStationsId)
        }
    }
    
    func sortNbrBikesByTenCLosestLocation() -> [Int:Int] {
        var newDict = [Int:Int]()
        var idsTabs = [Int]()
        
        stations = StationService.instance.stations
        for items in stations.stationsLocation {
            for (key, value) in stations.stationsIdByLocation {
                if items == key {
                    idsTabs.append(value)
                }
            }
        }
        for items in idsTabs {
            for (key, value) in bikes.bikesByStationsId {
                if items == key {
                    newDict[key] = value
                }
            }
        }
        bikes.bikesByStationsId = newDict
        return bikes.bikesByStationsId
    }
    
    func getBikesNbrById(bikesByStationsId: [Int:Int], stationId: Int) -> Int {
        var id = 0
        
        for (key, value) in bikesByStationsId {
            if key == stationId {
                id = value
            }
        }
        return id
    }
}
