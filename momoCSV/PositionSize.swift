//
//  PositionSize.swift
//  momoCSV
//
//  Created by Warren Hansen on 5/6/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//

import Foundation
import RealmSwift

class PositionSize: NSObject {
    
    let initialBalanceReg = 250000.00
    
    let initialBalanceIRA = 75000.00

    func calcPositionSise()-> String {
        
        let totalCash = initialBalanceReg + initialBalanceIRA
        
        let otherRealm = try! Realm()
        
        let otherResults = otherRealm.objects(FilteredSymbolsData.self)
        
        var result = "\nTicker\tClose\tWeight\tShares\tCost\n"
        
        var confirmCash = 0.0
        
        for items in otherResults {
            
            let thisAllocation =  totalCash / items.allTickers[0].weight
            
            let numShares = thisAllocation / items.allTickers[0].close
            
            confirmCash += thisAllocation
            
            // tab evenly add space to Ticker
            let tkr = items.allTickers[0].ticker
            var fullTicker = ""
            if tkr.characters.count < 3 {
                fullTicker = tkr + "  "
            } else {
                fullTicker = tkr
            }
            
            // tab evenly round weight to 2 deciamls
            let x = items.allTickers[0].weight
            let y = Double(round(1000*x)/1000)
            
            // tab evenly add spacece to shares < 100
            
            let n = numShares
            var numsharesToString = ""
            if n < 100 {
                numsharesToString = "\(String(format: "$%.0f", n))   "
            } else if n < 1000 {
                numsharesToString = "\(String(format: "$%.0f", n)) "
            } else {
                numsharesToString = "\(String(format: "$%.0f", n))"
            }//String(format: "%.2f", 10.426123)
            
            
            result += "\(fullTicker)\t\(items.allTickers[0].close)\t\(String(format: "%.1f", y))\t\t\(numsharesToString)\t$\(Int(thisAllocation))\n"
        }
        
        result += "\nTotal Allocation $\(Int(confirmCash))"
        
        return result
    }
    
}

