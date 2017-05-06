//
//  ViewController.swift
//  momoCSV
//
//  Created by Warren Hansen on 5/5/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//  task: Add gap + trend filter to list

//  bug: why am I filtering IDXX

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    let csvParse = CSVParse()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fileString = csvParse.readDataFromFile(file: "2017_05_04")
        
        let cleanedRows = csvParse.cleanRows(file: fileString!)
  
        textView.text = csvParse.printData(of: cleanedRows)
        
        filterTickers()
    }
    
    
    func filterTickers() {
        
        var totalPortfoio = 0.0
        
        for (index, row ) in csvParse.data.enumerated() {
            
            if index > 0 && totalPortfoio < 100 {
                //print(index, row)
                guard let ticker = row["Ticker"] else {
                    print("Got nil in ticker")
                    continue
                }
                guard let slope = Double(row["Adj.Slope90"]!) else {
                    print("Got nil in slope: \(index)")
                    continue
                }
                guard let trend = Int(row["\"Stock Trend - SMA100\""]!) else {
                    print("Got nil in trend")
                    continue
                }
                guard let gap = Double(row["\"Max Gap\""]!) else {
                    print("Got nil in gap")
                    continue
                }
                guard let targetWeight = Double(row["\"Target Weight\""]!) else {
                    print("Got nil in targetWeight")
                    continue
                }
                
                if trend == 1   && gap < 15 {
                    print("ticker:",ticker, "  slope:", slope, "   trend:", trend, "   gap", gap, "   Taregt Weight:", targetWeight,"   Total Weight:", totalPortfoio)
                } else {
                    print("Excluded: \(ticker) Trend: \(trend) Gap: \(gap)")
                }
                totalPortfoio += targetWeight
            }
            
        }
    }
    


}


