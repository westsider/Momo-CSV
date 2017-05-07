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
import RealmSwift

class ViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    let csvParse = CSVParse()
    
    let filteredSymbolsData = FilteredSymbolsData()
    
    let positionSize = PositionSize()

    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //fileString = csvParse.readDataFromFile(file: "2017_05_04")
    }
    
    @IBAction func importAction(_ sender: Any) {
        
        guard let fileString = csvParse.readDataFromFile(file: "2017_05_04") else {
            textView.text =  "Warning csv file does not exist!"
            return
        }
        
        let parsedCvs = csvParse.printData(of: fileString)  // calls convertCSV, cleanRows

        textView.text = parsedCvs
    }
    
    @IBAction func fiterAction(_ sender: Any) {
        
        let filterResults = csvParse.filterTickers()

        let displayText = filteredSymbolsData.saveRealmWith(Tickers: filterResults)
        
        print(displayText)
        
        textView.text = displayText
        
    }
    
    @IBAction func posSizeAction(_ sender: Any) {
        
        //MARK: - Load Realm
        //let result = filteredSymbolsData.readFromRealm()
        
        let posSize = positionSize.calcPositionSise()
        
        textView.text  =  posSize
    }


    
    @IBAction func clearRealm(_ sender: Any) {
        //MARK: - Delete All
        try! realm.write {
            realm.deleteAll()
        }
        textView.text =  "Realm Database Deleted"
    }

}



