//
//  PositionSize.swift
//  momoCSV
//
//  Created by Warren Hansen on 5/6/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//

import Foundation

class PositionSize: NSObject {
    
    let initialBalanceReg = 250000
    
    let initialBalanceIRA = 75000
    
    /*
     what do I nned from filterTickers
     
     ticker, close, targetWeight
     
     
 */
    
    /*
     
     for each new ticker
        get target weight
        thjisAllocation =  cash / aloocation
        numShares = thisAllocation / share price
 
 */
//    func calcPostionSize(tickers: FilteredSymbols){
//        
//        let filterResults = csvParse.filterTickers()
//        
//        var displayText = ""
//        for item in filterResults.allTickers {
//            let thisRow = "\(item.ticker)\t\t\(item.close)\t\t\(item.weight)\r"
//            displayText += thisRow
//        }
//        
//        print(displayText)
//        
//    }
}

