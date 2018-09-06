//
//  NSError+Extension.swift
//  OpenFDA
//
//  Created by Mitchell Murphy on 8/30/18.
//  Copyright © 2018 Mitchell Murphy. All rights reserved.
//
import Foundation

extension NSError {
    
    func makeError(description: String, code: Int) -> NSError {
        return NSError(domain: description, code: code, userInfo: nil)
    }
    
    
}
