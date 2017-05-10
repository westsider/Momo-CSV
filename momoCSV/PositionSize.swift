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
    
    var regAccount = "Reg"
    
    var iraAccount = "IRA"

    var account = ""
    
    let realm = try! Realm()
    
    func calcPositionSise()-> String {
        
        let totalCash = initialBalanceReg + initialBalanceIRA
        
        let otherRealm = try! Realm()
        
        let otherResults = otherRealm.objects(FilteredSymbolsData.self)
        
        var result = "\nTicker\tClose\tWeight\tShares\tCost\n"
        
        var totalAccocation = 0.0
        
        for items in otherResults {
            
            let thisAllocation =  totalCash / items.allTickers[0].weight
            
            let numShares = thisAllocation / items.allTickers[0].close
            
            try! realm.write {
                items.allTickers[0].cost = thisAllocation
                items.allTickers[0].shares = numShares
            }
            
            totalAccocation += thisAllocation
            
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
                numsharesToString = "\(String(format: "%.0f", n))   "
            } else if n < 1000 {
                numsharesToString = "\(String(format: "%.0f", n)) "
            } else {
                numsharesToString = "\(String(format: "%.0f", n))"
            }
            
            result += "\(fullTicker)\t\(items.allTickers[0].close)\t\(String(format: "%.1f", y))\t\t\(numsharesToString)\t$\(Int(thisAllocation))\t\(account)\n"
            
        }
        
        result += "\nTotal Allocation $\(Int(totalAccocation))"
        
        return result
    }
    
    func splitRealmPortfolio() {
        let otherRealm = try! Realm()
        
        let otherResults = otherRealm.objects(FilteredSymbolsData.self)
        
        var thisAllocation = [Int]()
        
        for items in otherResults {
            
            let result = "\(items.allTickers[0].ticker)\t\(items.allTickers[0].close)\t\(items.allTickers[0].weight)\t\t\(items.allTickers[0].shares)\t\(Int(items.allTickers[0].cost))\t\(items.allTickers[0].account)"
            print("\(result)")
            
            thisAllocation.append(Int(items.allTickers[0].cost))
        }
        
        //find best fit for smaller portfolio
        let sortedAllocation = thisAllocation.sorted{$0 < $1}
        
        var smallerAccount = [Int]()
        
        var smallerAccountSum = 0
        
        let initialBalanceIRA = 75000
        
        for item in sortedAllocation {
            
            smallerAccountSum = smallerAccount.reduce(0) { $0 + $1 }
            
            if smallerAccountSum < initialBalanceIRA {
                
                smallerAccount.append(item)
            } else {
                smallerAccount.removeLast()
            }
        }
        //let finalSum = smallerAccount.reduce(0) { $0 + $1 }
        //print(smallerAccount, finalSum)
        
        // update realm object
        for item in otherResults {
            
            if Int(item.allTickers[0].cost) == smallerAccount[0] || Int(item.allTickers[0].cost) == smallerAccount[1] {
                try! realm.write {
                    item.allTickers[0].account = "IRA"
                }
            } else {
                try! realm.write {
                    item.allTickers[0].account = "REG"
                }
            }
        }
        
    }
    
    func getRealmPortfolio()-> String {
        
        let otherRealm = try! Realm()
        
        let otherResults = otherRealm.objects(FilteredSymbolsData.self)
        
        var result = "\nTicker\tClose\tWeight\tShares\tCost\tAccount\n"
        
        var totalAccocation = 0.0
        
        for items in otherResults {
            
            totalAccocation += items.allTickers[0].cost
            
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
            
            let n = items.allTickers[0].shares
            var numsharesToString = ""
            if n < 100 {
                numsharesToString = "\(String(format: "%.0f", n))   "
            } else if n < 1000 {
                numsharesToString = "\(String(format: "%.0f", n)) "
            } else {
                numsharesToString = "\(String(format: "%.0f", n))"
            }
            
            result += "\(fullTicker)\t\(items.allTickers[0].close)\t\(String(format: "%.1f", y))\t\t\(numsharesToString)\t$\(Int(items.allTickers[0].cost))\t\(items.allTickers[0].account)\n"
            
        }
        
        result += "\nTotal Allocation $\(Int(totalAccocation))"
        
        return result
    }

}

