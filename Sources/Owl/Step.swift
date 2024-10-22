//
//  File.swift
//  
//
//  Created by Morel Fotsing on 10/19/24.
//

import Foundation

class Step {
    let name: String
    var labels: [String:Codable]
    
    init(_ name: String) {
        self.name = name
        self.labels = [:]
    }
    
    func label(key: String, val: Codable) {
        self.labels[key] = val
    }
}
