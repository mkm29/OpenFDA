//
//  SearchViewController.swift
//  OpenFDA
//
//  Created by Mitchell Murphy on 9/2/18.
//  Copyright © 2018 Mitchell Murphy. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    let drugDB = DrugDB()
    let openFDA = OpenFDA()
    
    
    var drugNames: [String]?
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if drugDB != nil {
            searchBar.delegate = self
            searchBar.returnKeyType = UIReturnKeyType.done
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // clear search text
        searchBar.text = ""
        drugNames = nil
        tableView.reloadData()
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if let drugNames = drugNames {
            return drugNames.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "DrugCell"), let drugNames = drugNames {
            let drugName = drugNames[indexPath.row]
            cell.textLabel?.text = drugName
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Segue to drug, need to get the set_id from the db then call the openFDA API to get drug info")
//        let drug = drugs[indexPath.row]
//        // get the drug info from FDA
//        tableView.deselectRow(at: indexPath, animated: false)
//        openFDA.search(bySetId: drug.setId) { (error, drug) in
//            guard error == nil else {
//                AppDelegate.getAppDelegate().showAlert("Error", "Unable to download drug information. Please try again.")
//                return
//            }
//
//            if let drug = drug {
//                DispatchQueue.main.async {
//                    self.performSegue(withIdentifier: "showDrugDetail", sender: drug)
//                }
//            }
//        }
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let drugDB = drugDB else {
            print("No connection to drug database")
            return
        }
        
        let minimumLength = 1
        
        if searchText.count >= minimumLength {
            // fire off a db search
            do {
                drugNames = try drugDB.findDrugs(byName: searchText, ofType: .Prescription)
                tableView.reloadData()
            } catch {
                print(error)
            }
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDrugDetail", let drug = sender as? DrugStruct {
            let nvc = segue.destination as! UINavigationController
            let drugDetailVC = nvc.viewControllers.first as! DrugDetailViewController
            drugDetailVC.drug = drug
        }
    }

}
