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
    
    var bikesByStationsId = [Int:Int]()
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
        
        if let items = json["data"]["stations"].array {
            for item in items {
                let id = item["station_id"].intValue
                let nbrBikes = item["numBikesAvailable"].intValue
        
                bikesByStationsId[id] = nbrBikes
            }
            bikes = Bikes(bikesByStationsId: bikesByStationsId)
        }
    }
}
