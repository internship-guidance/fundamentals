//
//  ViewController.swift
//  FundamentalsAssignment
//
//  Created by egmars.janis.timma on 02/05/2019.
//  Copyright © 2019 egmars.janis.timma. All rights reserved.
//

import UIKit
import SFundamentals

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var viewForTableView: UIView!
    @IBOutlet var tableViewOutlet: UITableView!
    @IBOutlet var resetOutlet: UIButton!
    @IBOutlet var searchOutlet: UIButton!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var yearLabel: UILabel!
    @IBOutlet var yearSlider: UISlider!
    
    @IBAction func didChangeYear(_ sender: UISlider) {
        searching = true
        self.yearLabel.text = "\(Int(yearSlider.minimumValue))"
        self.yearLabel.text = "\(Int(sender.value.self))"
    }
    
    @IBOutlet var priceSliderOutlet: UISlider!
    @IBOutlet var priceLabel: UILabel!
    @IBAction func priceSlider(_ sender: UISlider) {
        searching = true
        self.priceLabel.text = "\(Int(priceSliderOutlet.minimumValue))"
        self.priceLabel.text = "\(Int(sender.value.self)) €"
        return
    }
    
    @IBAction func switchTransmission(_ sender: UISwitch) {
        searching = true
        if (sender.isOn) {
            transmissionLabel.text = "automatic"
        } else {
            transmissionLabel.text = "manual"
        }
    }
    
    @IBOutlet var gearSwitch: UISwitch!
    
    @IBOutlet var transmissionLabel: UILabel!
    
    @IBOutlet var bodyCheckboxes: [CheckBox]!
    
    var carBodyTypes: [Int: Car.Body] = [0 : .sedan,
                                         1 : .hatchback,
                                         2 : .coupe,
                                         3 : .cabrio,
                                         4 : .wagon,
                                         5 : .crossover,
                                         6 : .minivan]
    
    
    @IBOutlet var fuelTypeCheckBoxes: [CheckBox]!
    
    var carFuelTypes: [Int: Car.FuelType] = [10 : .gasoline,
                                             11 : .diesel,
                                             12 : .electric,
                                             13 : .hydrogen,
                                             14 : .solar,
                                             15 : .vegetableOil]
    
    var carsArray : [Car] = []
    var searchCar = [Car]()
    var searching = false
    
    var activityIndicatorView: UIActivityIndicatorView!
    var rows: [String]?
    let dispatchQueue = DispatchQueue(label: "Example Queue")
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return searchCar.count
        }
        return carsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TableViewCell
        
        if searching {
            let newValue = searchCar[indexPath.row]
            cell.configureCell(car: newValue)
        } else {
            let newValue = carsArray[indexPath.row]
            cell.configureCell(car: newValue)
        }
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicatorView = UIActivityIndicatorView(style: .gray)
        tableView.backgroundView = activityIndicatorView
        searchOutlet.layer.cornerRadius = searchOutlet.frame.height / 4
        searchOutlet.layer.shadowColor = UIColor.black.cgColor
        searchOutlet.layer.shadowRadius = 5
        searchOutlet.layer.shadowOpacity = 0.8
        searchOutlet.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        resetOutlet.layer.cornerRadius = resetOutlet.frame.height / 2
        resetOutlet.layer.shadowColor = UIColor.black.cgColor
        resetOutlet.layer.shadowRadius = 5
        resetOutlet.layer.shadowOpacity = 0.8
        resetOutlet.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        tableView.layer.borderWidth = 1
        tableView.layer.borderColor = UIColor.gray.cgColor
        tableView.layer.cornerRadius = tableViewOutlet.frame.height / 40
        viewForTableView.layer.cornerRadius = viewForTableView.frame.height / 40
        viewForTableView.layer.shadowColor = UIColor.black.cgColor
        viewForTableView.layer.shadowRadius = 10
        viewForTableView.layer.shadowOpacity = 0.8
        viewForTableView.layer.shadowOffset = CGSize(width: 0, height: 0)

        for checkBox in bodyCheckboxes {
            checkBox.delegate = self
        }
        
        for checkBox in fuelTypeCheckBoxes {
            checkBox.delegate = self
        }
        
        JSON.shared.fetch { (carValues) in
            DispatchQueue.main.async {
                self.carsArray = carValues
                self.searchCar = carValues
                self.tableView.reloadData()
                let carYears = carValues.map { $0.year }
                
                if let lowestYear = carYears.min() {
                    self.yearSlider.minimumValue = Float(lowestYear)
                    self.yearLabel.text = "\(lowestYear)"
                }
                
                if let highestYear = carYears.max() {
                    self.yearSlider.maximumValue = Float(highestYear)
                }
                
                let carPrice = carValues.map{ $0.price }
                
                if let lowestPrice = carPrice.min() {
                    self.priceSliderOutlet.minimumValue = Float(lowestPrice)
                    self.priceLabel.text = "\(lowestPrice) €"
                }
                
                if let highestPrice = carPrice.max() {
                    self.priceSliderOutlet.maximumValue = Float(highestPrice)
                }
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (rows == nil) {
            activityIndicatorView.startAnimating()
            
            tableView.separatorStyle = .none
            
            dispatchQueue.async {
                Thread.sleep(forTimeInterval: 10)
                OperationQueue.main.addOperation() {
                    self.rows = ["One", "Two", "Three", "Four", "Five"]
                    self.activityIndicatorView.stopAnimating()
                    
                    self.tableView.separatorStyle = .singleLine
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    @IBAction func resetButton(_ sender: UIButton) {
        searching = false
        searchCar.removeAll()
        tableView.reloadData()
    }
    
    @IBAction func searchButton(_ sender: UIButton) {
        let ongoingCars = searching ? searchCar : carsArray
        
        var results = Cars()
        
        for checkbox in bodyCheckboxes {
            if checkbox.isChecked {
                let filteredByBody = ongoingCars.filter({ (car) -> Bool in
                    return car.body == carBodyTypes[checkbox.tag]
                })
                
                results.append(contentsOf: filteredByBody)
            }
        }
        
        if results.isEmpty {
            results = ongoingCars
        }
        
        var results2 = Cars()
        
        for checkBox in fuelTypeCheckBoxes {
            if checkBox.isChecked {
                let filteredByFuelType = results.filter({ (car) -> Bool in
                    return car.fuelType == carFuelTypes[checkBox.tag]
                })
                
                results2.append(contentsOf: filteredByFuelType)
            }
        }
        
        if results2.isEmpty {
            results2 = results
        }
        
        let filteredByTransmission = results2.filter({ (car) -> Bool in
            return car.transmission == (gearSwitch.isOn ? .automatic : .manual)
        })
        
        let results3 = filteredByTransmission
        var results4 = Cars()
        let carPossibleYearRange = Int(yearSlider.value)...Int(yearSlider.maximumValue)
        
        results4 = results3.filter({ (car) -> Bool in
            return carPossibleYearRange ~= car.year
            
        })
        
        var results5 = Cars()
        let possiblePriceRange = Int(priceSliderOutlet.minimumValue)...Int(priceSliderOutlet.value)
        
        results5 = results4.filter({ (car) -> Bool in
            return possiblePriceRange ~= car.price
        })
        
        searchCar = results5
        searching = true
        tableView.reloadData()
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searching = true
        searchCar = carsArray.filter({ (car) -> Bool in
            return (car.make.contains(searchText)) || (car.model.contains(searchText))
        })
        tableView.reloadData()
    }
}

extension ViewController: UIButtonDelegate {
    func checkButtons() {
        searching = true
    }
}
