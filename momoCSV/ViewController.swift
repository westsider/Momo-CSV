//
//  ViewController.swift
//  momoCSV
//
//  Created by Warren Hansen on 5/5/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//  task: Add gap + trend filter to list
//  bug: why am I filtering IDXX in my main data file?
//  task: move tickerFIlter to another class
//  func to print filtered tickers
//  task: button to show filtered tickers
//  fix: adding wrong symbols to filtered

//  task: add realm
//  task: calc num shares on 325,000
//  task: split shares on IRS 75k vs Reg 250k
//  Calc the Port rebalance every weds
//  Calc the Pos rebalance every 2nd weds
//  Find a way to download the cvs directly

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    let csvParse = CSVParse()
    
    var fileString = ""
    
    //var filterResults = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fileString = csvParse.readDataFromFile(file: "2017_05_04")
    }
    
    @IBAction func importAction(_ sender: Any) {
        
        fileString = csvParse.readDataFromFile(file: "2017_05_04")
        
        let parsedCvs = csvParse.printData(of: fileString) // calls convertCSV, cleaneRows

        textView.text = parsedCvs
    }
    
    @IBAction func fiterAction(_ sender: Any) {
        
        let filterResults = csvParse.filterTickers()
        
        var displayText = ""
        for item in filterResults.allTickers {
            let thisRow = "\(item.ticker)\t\t\(item.close)\t\t\(item.weight)\r"
            displayText += thisRow
        }

        print(displayText)
        
        textView.text = displayText
        
        
    }
    
    @IBAction func posSizeAction(_ sender: Any) {
    }

}


