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
        
        var result = ""
        
        var confirmCash = 0.0
        
        for items in otherResults {
            
            let thisAllocation =  totalCash / items.allTickers[0].weight
            
            let numShares = thisAllocation / items.allTickers[0].close
            
            confirmCash += thisAllocation
            
            result += "\(items.allTickers[0].ticker)\t\(items.allTickers[0].close)\t\(items.allTickers[0].weight)\t\(Int(numShares))\t$\(Int(thisAllocation))\n"
        }
        
        result += "\nTotal Allocation $\(Int(confirmCash))"
        
        return result
    }
    
}

