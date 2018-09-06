//
//  OpenFDA_APII.swift
//  OpenFDA
//
//  Created by Mitchell Murphy on 8/30/18.
//  Copyright © 2018 Mitchell Murphy. All rights reserved.
//

import SwiftyJSON

struct DrugStruct {
    var setId: String
    var dosages: [Int]?
    var indications: String?
    var contractictions: String?
    var adverseReactions: String?
    var warnings: String?
    var brandName: String
    var genericName: String
    var route: String?
    var description: String?
    var information: String?
    
    init(_ setId: String, _ brandName: String,_ genericName: String) {
        self.setId = setId
        self.brandName = brandName
        self.genericName = genericName
    }
}


import SwiftyJSON


class OpenFDA {
    
    let session = URLSession.shared
    
    let baseURL = "https://api.fda.gov/drug/label.json?search="
    
    // a full API request is going to involve 2 parts
    // 1 - Call the search API and fetch the set_id UUID and meta.results.total field
    
    // 2 - from this limit call the search API again with the limit parameter set
    
    
    private func getTotal(_ brandName: String, completion: @escaping (_ error: Error?, _ count: Int?) -> Void) {
        if let url = URL(string: "\(baseURL)openfda.brand_name:\(brandName)") {
            let task = session.dataTask(with: url) { (data, response, error) in
                guard error == nil else {
                    return completion(error!, nil)
                }
                if let data = data {
                    let jsonResult = JSON(data)
                    if let total = jsonResult["meta"].dictionary?["results"]?.dictionary?["total"]?.int {
                        completion(nil, total)
                    } else {
                        print("Could not get results")
                        completion(nil, nil)
                    }
                } else {
                    completion((NSError(domain: "No data returned.", code: 2, userInfo: nil) as Error), nil)
                }
            }
            
            task.resume()
        }
    }
    
    func search(byMedicationName brandName: String, completion: @escaping (_ error: Error?, _ drugs: [DrugStruct]?) -> Void) {
        getTotal(brandName) { (error, total) in
            guard error == nil else {
                return completion(error!, nil)
            }
            if let total = total, let url = URL(string: "\(self.baseURL)openfda.brand_name:\(brandName)&limit=\(total)") {
                // fire off new API call with limit set
                let task = self.session.dataTask(with: url, completionHandler: { (data, response, error) in
                    guard error == nil else {
                        return completion(error!, nil)
                    }
                    if let data = data,
                        let results = JSON(data)["results"].array {
                        var drugs = [DrugStruct]()
                        var drugNames: Set<String> = Set()
                        var allDosages: Set<Int> = Set()
                        for result in results {
                            if let drug = self.drugFromJSON(result) {
                                if !drugNames.contains(drug.brandName) {
                                    drugNames.insert(drug.brandName)
                                    drugs.append(drug)
                                }
                                if let dosages = drug.dosages {
                                    _ = dosages.map { dose in allDosages.insert(dose) }
                                }
                            }
                        }
                        let dosagesArray = Array(allDosages).sorted()
                        print(dosagesArray)
                        completion(nil, drugs)
                    }
                })
                task.resume()
            }
            
            
        }
    }
    
    func search(bySetId setId: String, completion: @escaping (_ error: Error?, _ drug: DrugStruct?) -> Void) {
        let url = URL(string: "\(self.baseURL)set_id:\(setId)")!
        
        let task = session.dataTask(with: url) { (data, response, error) in
            guard error == nil else {
                return completion(error!, nil)
            }
            if let data = data, let results = JSON(data)["results"].array?.first {
                completion(nil, self.drugFromJSON(results))
            }
        }
        task.resume()
    }
    
    private func drugFromJSON(_ drugJSON: JSON) -> DrugStruct? {
        guard let setId = drugJSON["set_id"].string,
            let openFDA = drugJSON["openfda"].dictionary,
            let brandName = openFDA["brand_name"]?.array?.first?.string,
            let genericName = openFDA["generic_name"]?.array?.first?.string else {
            return nil
        }
        
        var drug = DrugStruct.init(setId, brandName, genericName)
        
        if let dosages = drugJSON["dosage_forms_and_strengths"].array?.first?.string {
            drug.dosages = parseDosages(dosages)
        } else if let dosages = drugJSON["dosage_and_administration"].array?.first?.string {
            drug.dosages = parseDosages(dosages)
        }
    
        if let description = drugJSON["description"].array?.first?.string {
            drug.description = description.replacingOccurrences(of: "11 DESCRIPTION ", with: "")
        }
        if let interactions = drugJSON["drug_interactions"].array?.first?.string {
            var interactionsClean = interactions.replacingOccurrences(of: "", with: "")
            interactionsClean = interactionsClean.replacingOccurrences(of: "\\[.*?\\]", with: "")
            drug.indications = interactionsClean
        }
        if let contraindications = drugJSON["contraindications"].array?.first?.string {
            var contraindicationsClean = contraindications.replacingOccurrences(of: "", with: "4 CONTRAINDICATIONS ")
            contraindicationsClean = contraindicationsClean.replacingOccurrences(of: "\\[.*?\\]", with: "")
            drug.contractictions = contraindicationsClean
        }
        if let warnings = drugJSON["warnings_and_cautions"].array?.first?.string {
            drug.warnings = parseWarning(warnings)
        }
        if let route = openFDA["route"]?.array?.first?.string {
            drug.route = route
        }
        if let adverseReactions = drugJSON["adverse_reactions"].array?.first?.string {
            drug.adverseReactions = adverseReactions.replacingOccurrences(of: "6 ADVERSE REACTIONS ", with: "")
        }
        if let information = drugJSON["information_for_patients"].array?.first?.string {
            drug.information = information
        }

        
        return drug
        
    }
        
    
    private func parseDosages(_ dosageString: String) -> [Int]? {
        let pattern = "(\\d+) mg"
        
        let regex = try! NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let matches = regex.matches(in: dosageString, range: NSMakeRange(0, dosageString.utf16.count))
        
        var dosages = Set<Int>()
        for match in matches {
            let range = match.range(at: 1)
            let dosage = Int(String(dosageString.substring(with: range)!))!
            dosages.insert(dosage)
        }
        
        
        return Array(dosages).sorted()
    }
    
    private func parseInteractions(_ interactions: String) -> String {
        var newInteractions = interactions
        newInteractions = interactions.replacingOccurrences(of: "7 DRUG INTERACTIONS ", with: "")
        newInteractions = newInteractions.replacingOccurrences(of: "\\[.*?\\]", with: "")
        
        return newInteractions
    }
    
    private func parseWarning(_ warnings: String) -> String {
        var warningsClean = warnings.replacingOccurrences(of: "5 WARNINGS AND PRECAUTIONS • ", with: "")
        warningsClean = warningsClean.replacingOccurrences(of: "• |\\[.*?\\]|\\(.*?\\)", with: "", options: .regularExpression)
        warningsClean = warningsClean.replacingOccurrences(of: "  .", with: ".", options: .regularExpression)
        //warningsClean = warningsClean.replacingOccurrences(of: "\\d\\.\\d", with: "", options: .regularExpression)
        return warningsClean
    }
}
