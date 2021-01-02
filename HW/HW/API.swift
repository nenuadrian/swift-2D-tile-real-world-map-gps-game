//
//  API.swift
//  HW
//
//  Created by Adrian Nenu on 28/03/2017.
//  Copyright © 2017 Adrian Nenu. All rights reserved.
//

import Foundation

class API{
    static let host = "http://localhost:3000/"
    
    static func get(endpoint: String, callback: @escaping (_: JSON) -> Void) {
        APIHelper.get(path: host + endpoint, params: nil, completion: { (_, j) in
            callback(j!)
        })
    }

    static func put(endpoint: String, callback: @escaping (_: JSON) -> Void) {
        APIHelper.put(path: host + endpoint, params: nil, completion: { (_, j) in
            callback(j!)
        })

    }
    
    static func post(endpoint: String, callback: @escaping (_: JSON) -> Void) {
        APIHelper.post(path: host + endpoint, params: nil, completion: { (_, j) in
            callback(j!)
        })

    }
}

