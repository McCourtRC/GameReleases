//
//  GiantBombAPI.swift
//  GameReleases
//
//  Created by Corey McCourt on 10/13/16.
//  Copyright © 2016 Corey McCourt. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import SwiftMoment

struct GBGame {
    var id: Int = -1
    var name: String = ""
    var thumbUrl: NSURL? = nil
    var mediumUrl: NSURL? = nil
    var date: String? = nil
    var deck: String? = nil
    var description: String? = nil
}

struct GiantBombAPI {
    static let baseUrl = "http://www.giantbomb.com/api"
    static let API_KEY = "96ac27c489e63c4203812ab0e6dca92ecf7c2ea4"
    
    enum Endpoint: String {
        case games = "/games/"
    }
    
    // MARK: - Games Endpoint
    static func games(id: String, complete: @escaping ([GBGame]?) -> ()) {
        var params = [String: String]()
        params["id"] = id
        
        request(endpoint: .games, params: params) { (data) in
            complete(data)
        }
    }
    
    static func games(date: String, endDate: String? = nil, complete: @escaping ([GBGame]?) -> ()) {
        var params = [String: String]()
        params["sort"] = "original_release_date:asc"
        params["filter"] = endDate == nil ? "original_release_date:\(date)" : "original_release_date:\(date)|\(endDate!)"
        
        request(endpoint: .games, params: params) { (data) in
            complete(data)
        }
    }
    
    // MARK: - Base Request
    static func request(endpoint: Endpoint, params: [String: String], complete: @escaping ([GBGame]?) -> ()) {
        let url = baseUrl + endpoint.rawValue
        
        var parameters = params
        parameters["api_key"] = API_KEY
        parameters["format"] = "json"
        
        Alamofire.request(url, parameters: parameters).responseJSON { (response) in
            guard let resp = response.result.value else {
                complete(nil)
                return
            }
            
            print()
            print()
            print(response.request)
            print()
            print()

            var data = [GBGame]()
            let json = JSON(resp)
            let results = json["results"]
            for (_, res) in results {
                let id = res["id"].int
                let name = res["name"].string
                let thumbUrl = res["image"]["thumb_url"].URL
                let mediumUrl = res["image"]["medium_url"].URL
                let date = getDate(from: res)
                let deck = res["deck"].string
                let description = res["description"].string
                let game = GBGame(id: id!, name: name!, thumbUrl: thumbUrl, mediumUrl: mediumUrl, date: date, deck: deck, description: description)
                data.append(game)
            }
            complete(data)
        }
    }
    
    // MARK: - Utilities
    private static func getDate(from gameData: JSON) -> String? {
        var date: String? = nil
        
        if let dateString = gameData["original_release_date"].string {
            // Get valid syntax: 2016-12-30
            let splitDate = dateString.components(separatedBy: " ")
            let d = splitDate[0]
            // Set date
            if let mo = moment(d) {
                date = mo.format("YYYY-MM-dd")
            }
        }
        else {
            var d = [String: Int]()
            var format = ""
            if let year = gameData["expected_release_year"].int {
                d["year"] = year
                format = "YYYY"
            }
            if let month = gameData["expected_release_month"].int {
                d["month"] = month
                format = "YYYY-MM"
            }
            if let day = gameData["expected_release_day"].int {
                d["day"] = day
                format = "YYYY-MM-dd"
            }
            // Set date
            if let mo = moment(d) {
                date = mo.format(format)
            }
        }
        return date
    }
}
