//
//  DrugDetailViewController.swift
//  OpenFDA
//
//  Created by Mitchell Murphy on 9/4/18.
//  Copyright © 2018 Mitchell Murphy. All rights reserved.
//

import UIKit

class DrugDetailViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    var drug: DrugStruct?
    var dosageStrings = [String]()
    var dosages = [Int]()
    @IBOutlet weak var brandName: UILabel!
    @IBOutlet weak var genericName: UILabel!
    @IBOutlet weak var dosagePicker: UIPickerView!
    @IBOutlet weak var dosageButton: UIButton!
    @IBOutlet weak var selectedDosageLabel: UILabel!
    
    @IBOutlet var addDosageView: UIView!
    @IBOutlet weak var addDosageTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dosagePicker.delegate = self
        dosagePicker.dataSource = self
        dosagePicker.isHidden = true
        // Do any additional setup after loading the view.
        if let drug = drug {
            brandName.text = drug.brandName
            genericName.text = drug.genericName.lowercased().capitalized
            
            if let drugDosages = drug.dosages {
                print(drugDosages)
                dosages = drugDosages
            } else {
                print("Unable to set dosages")
            }
        }
    }
    @IBAction func cancel(_ sender: Any) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func pickDosage(_ sender: Any) {
        dosagePicker.isHidden = false
        dosageButton.isHidden = true
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dosages.count + 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if row <= dosages.count {
            print("count: \(dosages.count) row: \(row)")
            //return "\(dosages[row-1]) mg"
            return  "0 mg"
        } else {
            return "Add Dosage"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("row: \(row) inComponent: \(component)")
        // need to hide the picker view now
        if row <= dosages.count {
            //dosageButton.titleLabel?.text = title
            selectedDosageLabel.text = "\(dosages[row-1]) mg"
            pickerView.isHidden = true
            dosageButton.isHidden = false
        } else {
            addDosageView.center = view.center
            view.addSubview(addDosageView)
        }
    }
    
    @IBAction func addDosage(_ sender: Any) {
        if let dosageString = addDosageTextField.text.nilIfEmpty, let dosage = Int(dosageString) {
            dosages.append(dosage)
            dosages = dosages.sorted()
            dosagePicker.reloadComponent(0)
            addDosageView.removeFromSuperview()
        }
    }
}
