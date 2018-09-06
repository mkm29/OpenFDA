//
//  String+Extension.swift
//  OpenFDA
//
//  Created by Mitchell Murphy on 8/31/18.
//  Copyright © 2018 Mitchell Murphy. All rights reserved.
//
import Foundation

extension String {
    
    
    func substring(with nsrange: NSRange) -> Substring? {
        guard let range = Range(nsrange, in: self) else { return nil }
        return self[range]
    }
    
}
