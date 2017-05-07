//
//  RealmObjects.swift
//  momoCSV
//
//  Created by Warren Hansen on 5/6/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//

import Foundation
import RealmSwift

class TickersData: Object {

    dynamic var ticker = ""
    
    dynamic var close = 0.0
    
    dynamic var weight = 0.0
}

class FilteredSymbolsData: Object {
    
    dynamic var taskID = NSUUID().uuidString
    
    let allTickers = List<TickersData>()
    
    func saveRealmWith(Tickers: FilteredSymbols )-> String {
        
        let realm = try! Realm()
        
        var displayText = ""
        
        for item in Tickers.allTickers {
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
        return displayText
    }
    
    func readFromRealm()-> String {
        
        let otherRealm = try! Realm()
        
        let otherResults = otherRealm.objects(FilteredSymbolsData.self)
        
        //print("Retrived Tickers count \(otherResults.count) icker \(otherResults)")
        
        var result = ""
        
        for items in otherResults {
            
            result += "\(items.allTickers[0].ticker)\t\(items.allTickers[0].close)\t\(items.allTickers[0].weight)\n"
        }
        return result
    }
    
}

