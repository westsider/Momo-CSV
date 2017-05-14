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
//  fix: error in poition size as % of total portfolio
//  fix: allocation of 75K to IRA
//  fix UI for split of portfolio

//  print the sum or IRA and Reg
//  Construct the initial portfolio. Buy from the top until you run out of cash.

//  Calc the Portfolio rebalance every weds
//  Calc the Position rebalance every 2nd weds
//  Download the cvs directly to my own backend

import UIKit
import RealmSwift

class ViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    let csvParse = CSVParse()
    
    let filteredSymbolsData = FilteredSymbolsData()
    
    let positionSize = PositionSize()

    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func importAction(_ sender: Any) {
        
        // read data from file and saves a string Data object
        guard let fileString = csvParse.readDataFromFile(file: "2017_05_04") else {
            textView.text =  "Warning csv file does not exist!"
            return
        }
        
        // calls convertCSV, cleanRows returns String
        let parsedCvs = csvParse.printData(of: fileString)

        textView.text = parsedCvs
    }
    
    @IBAction func fiterAction(_ sender: Any) {
        
        // returns array of Ticker Objects of top momentum filtered symbols that will fit into portfolio
        let filterResults = csvParse.filterTickers()
        
        // saves above Ticker objects into a realm Ticker Object array
        let displayText = filteredSymbolsData.saveRealmWith(Tickers: filterResults)
        
        print("DISPLAY TEXT:\n\(displayText)")
        
        textView.text = displayText
        
    }
    
    @IBAction func posSizeAction(_ sender: Any) {
        
        //MARK: - Load Realm array of Ticker Objects and assigns cash value to each symbol and save to realm
        let posSize = positionSize.calcPositionSise()
        
        textView.text  =  posSize         
    }

    //MARK: - Load Realm array of Ticker Objects and split into ira nad reg
    @IBAction func splitPortfolio(_ sender: Any) {
        
        positionSize.splitRealmPortfolio()
        textView.text  =  positionSize.getRealmPortfolio()
    }
    
    @IBAction func clearRealm(_ sender: Any) {
        //MARK: - Delete All
        try! realm.write {
            realm.deleteAll()
        }
        textView.text =  "Realm Database Deleted"
    }
}



