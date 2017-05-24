//
//  PortfolioRebalance.swift
//  momoCSV
//
//  Created by Warren Hansen on 5/14/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//

import Foundation
import RealmSwift

class PortfolioActions {
    
    let filteredSymbolsData = FilteredSymbolsData()
    
    var latestData = [[String:String]]()
    
    var availableCash = (reg: 0, ira: 0)
    
    let realm = try! Realm()
    
    //MARK: - Weekly Reblance
    func weeklyRebalance(newFile: String)-> String {
        
        var result = "Ticker\tRow\tTrend\tGap\tAdvise\n"
        //MARK: - get data from last parse
        let csvParse = CSVParse()

        // read data from file and saves a string Data object
        guard let fileString = csvParse.readDataFromFile(file: newFile) else {
            result = "Warning csv file does not exist!"
            return result
        }
        
        // load the filestring into a dictionary
        _ = csvParse.printData(of: fileString)
        
        latestData = csvParse.data
        
        //MARK: -  get current symbols from realm
        let allObjects = filteredSymbolsData.readObjctsFromRealm()
        
        var theseTickers  = [String]()
        
        // make an array of Tickers
        for items in allObjects {
            theseTickers.append(items.ticker)
        }
        
        let todaysDate = dateToString()
        
        //MARK: = Check if symbol is in top 20%
        for (index, row ) in latestData.enumerated() {
            
            guard let ticker = row["Ticker"] else {
                print("Got nil in ticker")
                continue
            }
            guard let trend = Int(row["\"Stock Trend - SMA100\""]!) else {
                print("Got nil in trend")
                continue
            }
            guard let gap = Double(row["\"Max Gap\""]!) else {
                print("Got nil in gap")
                continue
            }
            
            var advise = "Hold"

            if trend != 1  || gap > 14 || index > 100 {
                advise = "Sell"
               // print("\nSell was triggered on \(ticker) \(trend) \(gap) \(index)\n")
            }
            
            // update realm to hold / sell
            let realm = try! Realm()
 
            if theseTickers.contains(ticker) {
                
                //print("The Ticker detected in Data: \(ticker)")
                
                let thisObject = realm.objects(TickersData.self).filter("ticker = '\(ticker)'")
                
                try! realm.write {
                    
                    thisObject[0].action = advise
                    thisObject[0].lastUpdate = todaysDate
                }
                
                result += "\(ticker)  \t\(index)\t\(trend)\t\(gap)   \t\(advise)\n"
                
            }
        }
        
        // check and make sure each ticker was found and updated
        let dateConfirm = FilteredSymbolsData().readObjctsFromRealm()
        
        for each in dateConfirm {
            if each.lastUpdate != todaysDate {
                result += "\n\(each.ticker) was not updated and isnt in the index!/n"
                print("\n\(each.ticker) was not updated and isnt in the index!/n")
            }
        }
        
        print("This is the result of weeklyRebalance \(result)")

        return result
    }
    
    //MARK: - Delete Sells
    func deleteSells()-> (reg: Int, ira: Int) {
        
        let realm = try! Realm()
        
        // loop throu realm and delete any tickers that say sell
        //MARK: -  get current symbols from realm
        let allObjects = filteredSymbolsData.readObjctsFromRealm()
        
        var thisUpdate = "These tickers have been sold\n"
        
        var iraTotal = 0.0
        
        var regTotal = 0.0
        
        for item in allObjects {
            if item.action == "Sell" && item.account == "IRA" {
                
                thisUpdate += item.ticker + ", "
                
                iraTotal += item.cost
                
                print("\nRemoving \(item.ticker)")
                try! realm.write {
                    realm.delete(item)
                }
            } else if item.action == "Sell" && item.account == "REG" {
                
                thisUpdate += item.ticker + ", "
                
                regTotal += item.cost
                
                print("\nRemoving \(item.ticker)")
                try! realm.write {
                    realm.delete(item)
                }
            }
        }
        
        JournalUpdate().addContent(lastEntry: thisUpdate)
        
        print("\nInside deleteSells: calling readingObjectsFrom Realm\n")
        
        // prove it
        let remainingObjects = filteredSymbolsData.readObjctsFromRealm()
        //print("\nThis is the update realm \(remainingObjects)\n")
        // loop through and get cost of new realm
        
        var sumOfNewPortfolio = 0.0
        
        for things in  remainingObjects {
            sumOfNewPortfolio += things.cost
        }
        
        availableCash.reg = Int(regTotal)
        
        availableCash.ira = Int(iraTotal)
        
        return (Int(regTotal), Int(iraTotal))
    }
    
    //MARK: - Search For New Buys
    func searchForNewBuys(account_One: Int, account_Two: Int) {
    
        let totalCash = Double( account_One + account_Two )
        
        let cashNowAvailable =  availableCash.reg + availableCash.ira
    
        // make arrat=y of current symbols
        let allObjects = filteredSymbolsData.readObjctsFromRealm()
        
        var currentSymbols = [String]()
        
        var results = [String]()
        
        var thisUpdate = "New Buys Found\nTicker\tClose  \tWeight  \tShares  \tCost\n"
        
        var newAllocationSum = 0.0
        
        for item in allObjects {
            currentSymbols.append(item.ticker)
        }
        
        var tickersToAdd = "Searching for new tickers to add...\n"
        
        //MARK: = Check if symbol is in top 20%
        for (index, row ) in latestData.enumerated() {
            
            if index > 0 && index < 105 { // exclude title row and portfolio full
                
                guard let ticker = row["Ticker"] else {
                    print("Got nil in ticker")
                    continue
                }
                guard let slope = Double(row["Adj.Slope90"]!) else {
                    print("Got nil in slope: \(index)")
                    continue
                }
                guard let trend = Int(row["\"Stock Trend - SMA100\""]!) else {
                    print("Got nil in trend")
                    continue
                }
                guard let gap = Double(row["\"Max Gap\""]!) else {
                    print("Got nil in gap")
                    continue
                }
                guard let targetWeight = Double(row["\"Target Weight\""]!) else {
                    print("Got nil in targetWeight")
                    continue
                }
                guard let close = Double(row["\"Close Price\""]!) else {
                    print("Got nil in Close Price")
                    continue
                }
                guard let updated = row["Updated"] else {
                    print("Got nil in date: \(index)")
                    continue
                }

                // make a list of new ptential buys
                //if results.count < 11 {
                if Int(newAllocationSum) < cashNowAvailable {
                    if trend == 1   && gap < 15 && !currentSymbols.contains(ticker) {
                         results.append("Ticker: \(ticker) Date: \(updated) Slope: \(slope) Trend: \(trend) Gap: \(gap) Taregt Weight: \(targetWeight) Close: \(close)")
                        
                        let realm = try! Realm()
                        
                        let newBuys = NewBuys()
    
                        // Important distiction, using total porfolio value / cash to use with
                        //  weight to find porper cash allocation
                        let thisAllocation =  totalCash * ( targetWeight * 0.01) // get cash in % of total portfolio
                        
                        let numShares = thisAllocation / close
                        let n = numShares
                        var numsharesToString = ""
                        if n < 100 {
                            numsharesToString = "\(String(format: "%.0f", n))   "
                        } else if n < 1000 {
                            numsharesToString = "\(String(format: "%.0f", n)) "
                        } else {
                            numsharesToString = "\(String(format: "%.0f", n))"
                        }
                        
                        newBuys.cost = thisAllocation
                        
                        newBuys.shares = numShares
                        
                        // make a new ream object object and add potential buys to it
                        newBuys.ticker = ticker
                        newBuys.weight = targetWeight
                        newBuys.close = close
                        newBuys.updated = updated

                        thisUpdate +=  "\(newBuys.ticker)  \t\(newBuys.close) \t\(String(format: "%.2f", newBuys.weight))  \t\(numsharesToString) \t\(String(format: "%.0f", newBuys.cost))\n"
                        
                        newAllocationSum += thisAllocation
                        
                        try! realm.write {
                            realm.add(newBuys)
                        }
                        
                        tickersToAdd += " Ticker \(newBuys.ticker) is a possible new buy\n"
                    }
                }
                
            }
            
        }
        
        JournalUpdate().addContent(lastEntry: tickersToAdd)
        
    }
    
    //MARK: - Allocate New Buys
    func allocateNewBuys() {
        
        print("Calling allocateNewBuys***************************************\n")
        
        let realm = try! Realm()
        
        let allNewTickers = realm.objects(NewBuys.self)
        
        var newAllocations = "Allocating new buys...\n"
        
        // set up vars to de increment account values
        for newBuy in allNewTickers {
            
            print("Looping thrugh new buys/n")
            
            if newBuy.cost < Double(availableCash.reg) {
                print("Buying Reg\n")
                availableCash.reg -= Int(newBuy.cost)
                
                newAllocations += "Updating realm and buying in reg \(newBuy.ticker) reg cash is now \(availableCash.reg)\n"
                
                try! realm.write {
                newBuy.account = "REG"
                    realm.add(newBuy)
                }
                
            } else if newBuy.cost < Double(availableCash.ira) {
                print("Buying Irs\n")
                
                availableCash.ira -= Int(newBuy.cost)

                newAllocations += "Updating realm and buying in Ira \(newBuy.ticker) Ira cash is now \(availableCash.ira)\n"
                try! realm.write {
                newBuy.account = "IRA"
                    realm.add(newBuy)
                }
            }
        }
        
        print("Making Journal Entries\n")
        var latestPortfolio =  newAllocations + "\n"
        
        latestPortfolio += "Portfollio now is:\n \(PositionSize().getRealmPortfolio())"
        
        JournalUpdate().addContent(lastEntry: latestPortfolio)
        
    }
    
    func dateToString() -> String {
        // todays date
        let date = Date()
        let formatter = DateFormatter()
        //Give the format you want to the formatter:
        formatter.dateFormat = "dd.MM.yyyy"
        //Get the result string:
        let todaysDate = formatter.string(from: date)
        return todaysDate
    }
    
    // Calc the Position rebalance every 2nd weds = Check position size
    func biWeeklyRebalance(newFile: String)-> String  {
        return "no data yet"
    }
}


