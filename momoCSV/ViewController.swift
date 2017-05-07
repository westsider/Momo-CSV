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
    
    var fileString = ""
    
    //var filterResults = ""

    let realm = try! Realm()
    
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
            
            // load into realm
            let newTicker = TickersData()
            newTicker.ticker = item.ticker
            newTicker.close = item.close
            newTicker.weight = item.weight
            let newTickerArray = FilteredSymbolsData()
            newTickerArray.allTickers.append(newTicker)
                try! realm.write {
                    realm.add(newTickerArray)
            }
        }

        print(displayText)
        
        textView.text = displayText
        
    }
    
    @IBAction func posSizeAction(_ sender: Any) {
        
        //MARK: - Load Realm
        print("'nRetriving from realm")
        
        let otherRealm = try! Realm()
        
        let otherResults = otherRealm.objects(FilteredSymbolsData.self)
        
        print("Retrived Tickers count \(otherResults.count) icker \(otherResults)")
        
        var result = ""
        
        for items in otherResults {
            
            result += "\(items.allTickers[0].ticker)\t\(items.allTickers[0].close)\t\(items.allTickers[0].weight)\n"
        }
        
        textView.text  = result  //print(result)
    }

    @IBAction func clearRealm(_ sender: Any) {
        //MARK: - Delete All
        try! realm.write {
            realm.deleteAll()
        }
    }
}
/*
// MARK: - Store realm
let newTicker = TickersData()
newTicker.ticker = "MSFT"
newTicker.close = 60.20
newTicker.weight = 4.89
print("Added ticker; \(newTicker.ticker) : \(newTicker.close) : \(newTicker.weight)")

let newTickerArray = FilteredSymbolsData()
newTickerArray.allTickers.append(newTicker)

print("\nAppended new ticker to array: \(newTickerArray.allTickers)")

let realm = try! Realm()

print("\nAdding to realm")

try! realm.write {
    realm.add(newTickerArray)
}

//MARK: - Load Realm
print("'nRetriving from realm")

let otherRealm = try! Realm()

let otherResults = otherRealm.objects(FilteredSymbolsData.self)

print("Retrived Tickers count \(otherResults.count) icker \(otherResults)")

for items in otherResults {
    print("Ticker : \(items.allTickers[0].ticker) Close : \(items.allTickers[0].close) Weight : \(items.allTickers[0].weight)\n")
    
    
}
*/


