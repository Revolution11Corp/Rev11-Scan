//
//  NetworkManager.swift
//  Rev11 Scan
//
//  Created by Sean Allen on 11/11/17.
//  Copyright © 2017 Revolution11. All rights reserved.
//

import Foundation
import Alamofire

class NetworkManager {
    
    static let shared    = NetworkManager()
    static let baseURL   = "https://fms4446.triple8.net/fmi/data/v1/databases/registry/"
    
    fileprivate let authenticateDemoUserURL = baseURL + "sessions"
    fileprivate let beconEntriesURL         = baseURL + "layouts/REG__Registry/records"

    private init() {}
    
    
    func authenticateDemoUser(completed: @escaping ((String?, Error?) -> Void)) {

        let user                = "dataAPI"
        let password            = "dataAPI"
        let credentialData      = "\(user):\(password)".data(using: String.Encoding.utf8)!
        let base64Credentials   = credentialData.base64EncodedString(options: [])

        let auth                = HTTPHeader(name: "Authorization", value: "Basic \(base64Credentials)")
        let contentType         = HTTPHeader(name: "Content-Type", value: "application/json")
        let headers             = HTTPHeaders([auth, contentType])

        let request             = AF.request(authenticateDemoUserURL, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: headers)
        
        request.responseJSON { (response: AFDataResponse<Any>) in
            
            switch(response.result) {
                
            case .success(_):

                let data        = response.value as! [String: Any]
                let response    = data["response"] as! [String: String]
                let token       = response["token"]
                
                completed(token, nil)
                
            case .failure(let error):
                completed(nil, error)
            }
        }
    }
    
    func getBeaconEntries(token: String, completed: @escaping (([iBeaconItem]?, Error?) -> Void)) {

        let headers = HTTPHeaders([HTTPHeader(name: "Authorization", value: "Bearer \(token)")])
        let request = AF.request(beconEntriesURL, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
        
        request.responseJSON { (response: AFDataResponse<Any>) in
            
            switch(response.result) {
                
            case .success(_):
                
                let responseData    = response.value as! [String : Any]
                let response        = responseData["response"] as! [String: Any]
                let data            = response["data"] as! [[String: Any]]
                
                var beacons: [iBeaconItem] = []
                
                for item in data {
                    
                    let fieldData   = item["fieldData"] as! [String: Any]
                    let recordID    = item["recordId"] as! String
                    let modID       = item["modId"] as! String
                    
                    let beacon      = iBeaconItem(data: fieldData)
                    beacon.recordID = recordID
                    beacon.modID    = modID
                    
                    beacons.append(beacon)
                }
                
                completed(beacons, nil)
                
            case .failure(let error):
                completed(nil, error)
            }
        }
    }
    
    
    func downloadImage(url: String, completion: @escaping ((Data) -> Void)) {
        
        let configuration: URLSessionConfiguration = .default
        let session = URLSession(configuration: configuration)
        
        var request: URLRequest!
        
        if let url = URL(string: url) {
            request = URLRequest(url: url)
        } else {
            return
        }
      
        let dataTask = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            if error == nil {
                
                if let httpResponse = response as? HTTPURLResponse {
                    
                    switch (httpResponse.statusCode) {
                        
                    case 200:
                        if let data = data {
                            completion(data)
                        }
                        
                    default:
                        print("Status Code = \(httpResponse.statusCode)")
                    }
                }
                
            } else {
                //TODO: Handle download error - Maybe show placeholder image
                print("Error downloading data: \(String(describing: error?.localizedDescription))")
            }
        }
        
        dataTask.resume()
    }

}
