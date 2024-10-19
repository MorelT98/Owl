//
//  File.swift
//  
//
//  Created by Morel Fotsing on 10/19/24.
//

import Foundation

class Step {
    let name: String
    var labels: [String:Any]
    
    init(_ name: String) {
        self.name = name
        self.labels = [:]
    }
    
    func label(key: String, val: Any) {
        self.labels[key] = val
    }
}
