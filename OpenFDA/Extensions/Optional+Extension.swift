//
//  Optional+Extension.swift
//  OpenFDA
//
//  Created by Mitchell Murphy on 9/5/18.
//  Copyright © 2018 Mitchell Murphy. All rights reserved.
//

extension Optional where Wrapped == String {
    var nilIfEmpty: String? {
        guard let strongSelf = self else {
            return nil
        }
        return strongSelf.isEmpty ? nil : strongSelf
    }
}
