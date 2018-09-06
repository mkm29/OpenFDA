//
//  DrugDB.swift
//  OpenFDA
//
//  Created by Mitchell Murphy on 9/4/18.
//  Copyright © 2018 Mitchell Murphy. All rights reserved.
//
import UIKit
import SQLite3

struct BasicDrug {
    var setId: String
    var brandName: String
    
    init(setId: String, brandName: String) {
        self.setId = setId
        self.brandName = brandName
    }
}

enum DrugType: String {
    case Prescription = "prescription"
    case OTC = "otc"
}

enum DatabaseErrors: Error {
    
    case connection //= NSError(domain: "Unable to connect to database", code: 1, userInfo: nil)
    case select //= NSError(domain: "SELECT statement could not be prepared", code: 2, userInfo: nil)
    case notFound
}

class DrugDB {
    
    var db: OpaquePointer!
    
    
    init?() {
        do {
            try openDatabase()
        } catch {
            print(error)
            return nil
        }
    }
    
    private func openDatabase() throws {
        if let dbPath = Bundle.main.path(forResource: "drugs", ofType: "sqlite3"), sqlite3_open(dbPath, &db) == SQLITE_OK {
            print("Successfully opened connection to database at \(dbPath)")
        } else {
            throw DatabaseErrors.connection
        }
    }
    
    func findDrugs(byName name: String, ofType type: DrugType) throws -> [String]? {
        var names: Set<String> = Set()
        
//        guard let db = db else {
//            throw DatabaseErrors.connection
//        }
        
        let searchSQL = "SELECT `brand_name` FROM \(type.rawValue) WHERE brand_name LIKE '%\(name)%' ORDER BY `brand_name` ASC"
        
        var queryStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, searchSQL, -1, &queryStatement, nil) == SQLITE_OK {
            
            while (sqlite3_step(queryStatement) == SQLITE_ROW) {
                // need to get set_id and brand_name
                //let set_id = sqlite3_column_text(queryStatement, 0)
                let queryResultCol1 = sqlite3_column_text(queryStatement, 0)
                if let queryResultCol1 = queryResultCol1 {
                    let name = String(cString: queryResultCol1).lowercased().capitalized
                    names.insert(name)
                }
            }
            
        } else {
            throw DatabaseErrors.select
        }
        sqlite3_finalize(queryStatement)
        
        return Array(names)
    }
    
    func getSetId(fromBrandName name: String, ofType type: DrugType) throws -> String? {
//        guard let db = db else {
//            throw DatabaseErrors.connection
//        }
        
        let searchSQL = "SELECT `set_id` FROM \(type.rawValue) WHERE brand_name LIKE '%\(name)%' ORDER BY `brand_name` ASC"
        
        var queryStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, searchSQL, -1, &queryStatement, nil) == SQLITE_OK {
            
            while (sqlite3_step(queryStatement) == SQLITE_ROW) {
                // need to get set_id and brand_name
                //let set_id = sqlite3_column_text(queryStatement, 0)
                let queryResultCol1 = sqlite3_column_text(queryStatement, 0)
                if let queryResultCol1 = queryResultCol1 {
                    let setId = String(cString: queryResultCol1).lowercased().capitalized
                    return setId
                }
            }
            
        } else {
            throw DatabaseErrors.select
        }
        sqlite3_finalize(queryStatement)
        throw DatabaseErrors.notFound
    }
    
}
