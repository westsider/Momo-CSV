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
    
    var regAccount = "Reg"
    
    var iraAccount = "IRA"

    var account = ""
    
    let filteredSymbolsData = FilteredSymbolsData()
    
    let realm = try! Realm()
    
    func calcPositionSise(account_One: Int, account_Two: Int)-> String {
        
        let totalCash = Double( account_One + account_Two )
        
        let allObjects = filteredSymbolsData.readObjctsFromRealm()
        
        var result = "\nTicker\tDate\tClose\tWeight\tShares\tCost\n"
        
        var totalAccocation = 0.0
        
        var sumOfAllocation = 0.0
        
        for items in allObjects {
            
            let thisAllocation =  totalCash * ( items.weight * 0.01) // get cash in % of total portfolio
            
            let numShares = thisAllocation / items.close
            
            try! realm.write {
                items.cost = thisAllocation
                items.shares = numShares
            }
            
            sumOfAllocation += items.weight
            
            totalAccocation += thisAllocation
            
            // tab evenly add space to Ticker
            let tkr = items.ticker
            var fullTicker = ""
            if tkr.characters.count < 3 {
                fullTicker = tkr + "  "
            } else {
                fullTicker = tkr
            }
            
            // get short date
            let updated = truncateDate(oldDates: items.updated)
            
            // tab evenly round weight to 2 deciamls
            let x = items.weight
            let y = Double(round(1000*x)/1000)
            
            // tab evenly add spacece to shares < 100
            
            let n = numShares
            var numsharesToString = ""
            if n < 100 {
                numsharesToString = "\(String(format: "%.0f", n))   "
            } else if n < 1000 {
                numsharesToString = "\(String(format: "%.0f", n)) "
            } else {
                numsharesToString = "\(String(format: "%.0f", n))"
            }
            
            result += "\(fullTicker)\t\(updated)\t\(items.close)\t\(String(format: "%.1f", y))\t\t\(numsharesToString)  \t$\(Int(thisAllocation))\t\(account)\n"
            
        }
        
        result += "\nSum of Allocation \(sumOfAllocation)  Total Allocation $\(Int(totalAccocation))"
        
        return result
    }
    
    func splitRealmPortfolio(account_One: Int, account_Two: Int) {
        
        let allObjects = filteredSymbolsData.readObjctsFromRealm()
        
        var thisAllocation = [Int]()
        
        for items in allObjects {
            
            //let result = "\(items.ticker)\t\(items.close)\t\(items.weight)\t\t\(items.shares)\t\(Int(items.cost))\t\(items.account)"
            
            thisAllocation.append(Int(items.cost))
        }
        
        // find the best fit of symbols to fill the IRA Account, account_Two
        var bestFit = BestFit().bestFit(initBalanceIRA: account_Two, allocations: thisAllocation)
        
        print("This is the best fit + Sum \(bestFit)\n")
        
        bestFit.removeLast()
        
        print("This is the best fit - Sum \(bestFit)\n")
        
        // update realm object
        for item in allObjects {
            
            for best in bestFit {
                
                if Int(item.cost) == best {
                    try! realm.write {
                        item.account = "IRA"
                    }
                }
                
            }
            
        }
        
    }
    
    func getRealmPortfolio()-> String {
        
        let allObjects = filteredSymbolsData.readObjctsFromRealm()
        
        var result = "\nTicker\tDate\tClose\tWeight\tShares\tCost\t\tAccount\n"
        
        var totalAccocation = 0.0
        
        var iraAllocation = 0.0
        
        var regAllocation = 0.0
        
        for items in allObjects {
            
            totalAccocation += items.cost
            
            if items.account == "IRA"{
                iraAllocation += items.cost
            } else {
                regAllocation += items.cost
            }
            
            // tab evenly add space to Ticker
            let tkr = items.ticker
            var fullTicker = ""
            if tkr.characters.count < 3 {
                fullTicker = tkr + "  "
            } else {
                fullTicker = tkr
            }
            
            // tab evenly round weight to 2 deciamls
            let x = items.weight
            let y = Double(round(1000*x)/1000)
            
            // tab evenly add spacece to shares < 100
            let n = items.shares
            var numsharesToString = ""
            if n < 100 {
                numsharesToString = "\(String(format: "%.0f", n))    "
            } else if n < 1000 {
                numsharesToString = "\(String(format: "%.0f", n))   "
            } else {
                numsharesToString = "\(String(format: "%.0f", n))"
            }
            
            result += "\(fullTicker)\t\(truncateDate(oldDates: items.updated))\t\(items.close)\t\(String(format: "%.1f", y))\t\t\(numsharesToString)\t$\(Int(items.cost))\t\t\(items.account)\n"
            
        }
        
        result += "\nReg = $\(regAllocation) IRA = $\(iraAllocation)\nTotal Allocation $\(Int(totalAccocation))"
        
        return result
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

