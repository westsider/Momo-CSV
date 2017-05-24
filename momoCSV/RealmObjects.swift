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
    
    dynamic var shares = 0.0
    
    dynamic var cost = 0.0
    
    dynamic var account = "REG"
    
    dynamic var updated = ""
    
    dynamic var action = "Hold"
    
    dynamic var lastUpdate = ""
    
    dynamic var currentFileName = ""
}

class NewBuys: Object {
    
    dynamic var ticker = ""
    
    dynamic var close = 0.0
    
    dynamic var weight = 0.0
    
    dynamic var shares = 0.0
    
    dynamic var cost = 0.0
    
    dynamic var account = "REG"
    
    dynamic var updated = ""
    
    dynamic var action = "Hold"
    
    dynamic var lastUpdate = ""
    
    dynamic var currentFileName = ""
}

class FilteredSymbolsData: Object {
    
    dynamic var taskID = NSUUID().uuidString
    
    func readFromRealm()-> String {
        
        let otherRealm = try! Realm()
        
        let otherResults = otherRealm.objects(TickersData.self)
        
        var result = "Ticker\tDate\tClose\tWeight\n"
        
        for items in otherResults {
            
            result += "\(items.ticker)  \t\(truncateDate(oldDates: items.updated))\t\(items.close)\t\(items.weight)\n"
        }
        return result
    }
    
    func readObjctsFromRealm()-> Results<TickersData> {
        
        let realm = try! Realm()
        
        let allObjects = realm.objects(TickersData.self)
        
        return allObjects
    }
    
    
    
    func truncateDate(oldDates: String)-> String {
        var oldDate = oldDates
        let lowBound = oldDates.index(oldDates.startIndex, offsetBy: 0)
        let hiBound = oldDate.index(oldDate.endIndex, offsetBy: -5)
        let midRange = lowBound ..< hiBound
        oldDate.removeSubrange(midRange)
        return oldDate
    }
}

class JournalUpdate: Object {
    
    dynamic var entry = ""
    
    dynamic var taskID = NSUUID().uuidString
    
    func addContent(lastEntry: String) {
        
        var newEntry = "\nUpdating journal on \(DateFunctions().dateToString()) @ \(DateFunctions().timeToString())\n"
        
        newEntry += lastEntry
        
        let realm = try! Realm()
        
        let thisEntry = JournalUpdate()
        
        thisEntry.entry = "\(newEntry)\n"
        
        try! realm.write {
            realm.add(thisEntry)
        }
    }
    
    func readContent()-> String {
        
        let realm = try! Realm()
        
        let allEntrys = realm.objects(JournalUpdate.self)
        
        var message = "\(allEntrys.count) Journal Entries\n"
        
        for (index, thisEntry) in allEntrys.enumerated() {
            message += "\n--------------------------- Entry \(index) -------------------------------\n" + thisEntry.entry
        }
        
        return message
    }
}

/*
 // get one ticker
 let activeFilters = realm.objects(TickersData.self).filter("ticker = 'AAPL'")
 let thisTicker = activeFilters.value(forKey: "ticker")
 */

