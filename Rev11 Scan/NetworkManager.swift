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
    static let baseURL   = "https://fms4398.triple8.net/fmi/rest/api/"
    
    fileprivate let authenticateDemoUserURL = baseURL + "auth/registry"
    fileprivate let beconEntriesURL         = baseURL + "record/registry/REG__Registry"

    private init() {}
    
    
    func authenticateDemoUser(completed: @escaping ((String?, Error?) -> Void)) {
        
        let parameters: [String: String] =  ["user": "dataAPI", "password": "dataAPI", "layout": "REG__Registry"]
        
        let request = Alamofire.request(authenticateDemoUserURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil)
        
        request.responseJSON { (response: DataResponse<Any>) in
            
            switch(response.result) {
                
            case .success(_):
                
                let data  = response.result.value as! [String : Any]
                let token = data["token"] as! String
                
                completed(token, nil)
                
            case .failure(let error):
                completed(nil, error)
            }
        }
    }
    
    func getBeaconEntries(token: String, completed: @escaping (([iBeaconItem]?, Error?) -> Void)) {
        
        let headers: [String: String] =  ["FM-Data-Token": token]
        
        let request = Alamofire.request(beconEntriesURL, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
        
        request.responseJSON { (response: DataResponse<Any>) in
            
            switch(response.result) {
                
            case .success(_):
                
                let data  = response.result.value as! [String : Any]
//                let token = data["token"] as! String
                
                completed([], nil)
                
            case .failure(let error):
                completed(nil, error)
            }
        }
    }



}
