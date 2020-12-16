//
//  HomeViewController.swift
//  Bike Tracker
//
//  Created by Justin Holmes on 12/15/20.
//

import Foundation
import UIKit
import Firebase
import FirebaseFirestore

class ViewController: UIViewController {
    
    let db = Firestore.firestore();
    
    
    @IBOutlet weak var todaysDate: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var mileInput: UITextField!
    
    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var milesLeftTextField: UILabel!
    
    @IBOutlet weak var milesLeftVal: UILabel!
    
    @IBOutlet weak var daysLeftTextField: UILabel!
    
    @IBOutlet weak var daysLeftVal: UILabel!
    
    @IBOutlet weak var milesPerDayTextField: UILabel!
    
    @IBOutlet weak var milesPerDayVal: UILabel!
    
    @IBOutlet weak var topLabel: UILabel!
    
    @IBOutlet weak var lastDayVal: UILabel!
    
    @IBOutlet weak var bottomLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadData()
        self.hideKeyboardWhenTappedAround()
        
    }
    
    @IBAction func submitTapped(_ sender: Any) {
        let today = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MM.dd.yyyy"
        let date = formatter.string(from: today)
        
        var dist = mileInput.text
        
        if dist == "" {
            dist = "0.0"
        }
        
        if Float(dist!) != nil {
            db.collection("miles").document(date).setData(["date":date, "distance":dist!])
            { err in
                if let err = err {
                    print("Error writing document: \(err)")
                }
            }
        }
        
        else {return }
    
        mileInput.text = ""
        loadData()
    }
    
    
    func loadData() {
        var distanceDouble = 0.0
        var milesBiked = 0.0
        let totalMiles = 300.0
        var milesLeft = totalMiles - milesBiked
        
        var distanceList: Array<Double> = [];
        var avglist: Array<Double> = [];
        
        db.collection("miles").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let distance = document.get("distance") as! String
                    distanceDouble = Double(distance)!
                    distanceList.append(distanceDouble)
                    milesBiked = distanceList.reduce(.zero, +)
                    milesLeft = totalMiles - milesBiked
                    self.milesLeftVal.text = String(Int(milesLeft))
                    
                    let today = Date()
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MM/dd/yyyy"
                    self.dateLabel.text = formatter.string(from: today)
                    
                    let end = Date(timeIntervalSinceReferenceDate: 631843200) // Jan 9, 2020, 12:00 AM
                    
                    let diffInDays = Double(Calendar.current.dateComponents([.day], from: today, to: end).day!) + 1.0

                    self.daysLeftVal.text = String(Int(diffInDays))
                    
                    let milesPerDay = milesLeft/diffInDays
                    
                    self.milesPerDayVal.text = String(format: "%.1f", ceil(milesPerDay*100)/100)
                }
            }
            
            lastDayData()
        }

        
        func lastDayData() {
            let milesRef = db.collection("miles");
            
            milesRef.order(by: "date", descending: true).limit(to: 5).getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        let distance = document.get("distance") as! String
                        distanceDouble = Double(distance)!
                        avglist.append(distanceDouble)
                        }
                    
                    let avgDistSum = avglist.reduce(.zero, +)
                    
                    let avgDist = Double(avgDistSum) / Double(avglist.count)
                    
                    let today = Date()
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MM/dd/yyyy"
                    self.dateLabel.text = formatter.string(from: today)
                    
                    let end = Date(timeIntervalSinceReferenceDate: 631843200) // Jan 9, 2020, 12:00 AM
                    
                    let diffInDays = Double(Calendar.current.dateComponents([.day], from: today, to: end).day!)
                    
                    let avgDistTotal = avgDist * (diffInDays)
        
                    let lastDayMiles = milesLeft - avgDistTotal
                    
                    if lastDayMiles > 0.0 {
                        var txt = String(format: "%.1f", ceil(lastDayMiles*100)/100)
                        txt += " Miles"
                        self.lastDayVal.text = txt
                    }
                    else {
                        self.lastDayVal.text = "You will be finished!"
                    }
                }
            }
        }
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

