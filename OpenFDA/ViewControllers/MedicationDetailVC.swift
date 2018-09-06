//
//  MedicationDetailVC.swift
//  OpenFDA
//
//  Created by Mitchell Murphy on 8/31/18.
//  Copyright © 2018 Mitchell Murphy. All rights reserved.
//

import UIKit

//    var dosages: [Int]?
//    var indications: String?
//    var contractictions: String?
//    var adverseReactions: String?
//    var warnings: String?
//    var brandName: String
//    var genericName: String
//    var route: String?
//    var description: String?
//    var information: String?

class MedicationDetailVC: UIViewController {
    
    var medication: DrugStruct?
    var dosage: Int?


    @IBOutlet weak var brandName: UILabel!
    @IBOutlet weak var genericName: UILabel!
    @IBOutlet weak var dosageTextField: UILabel!
    
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var detailTextView: UITextView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detailView.layer.borderWidth = 1
        detailView.layer.borderColor = UIColor.lightGray.cgColor
        // Do any additional setup after loading the view.
        if let medication = medication {
            brandName.text = medication.brandName
            genericName.text = medication.genericName
        }
        if let dosage = dosage {
            dosageTextField.text = "\(dosage) mg"
        }
        
    }
    @IBAction func closeDetail(_ sender: Any) {
        detailView.isHidden = true
    }
    
    @IBAction func showDescription(_ sender: Any) {
        if let description = medication?.description {
            detailTextView.text = description
            detailView.isHidden = false
        }
    }
    
    @IBAction func showInformation(_ sender: Any) {
        if let information = medication?.information {
            detailTextView.text = information
            detailView.isHidden = false
        }
    }
    @IBAction func showWarnings(_ sender: Any) {
        if let warnings = medication?.warnings {
            detailTextView.text = warnings
            detailView.isHidden = false
        }
    }
    
    @IBAction func back(_ sender: Any) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
}
