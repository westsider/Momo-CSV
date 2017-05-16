//
//  PortfolioActions.swift
//  momoCSV
//
//  Created by Warren Hansen on 5/14/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//

import Foundation
import RealmSwift

class PortfolioActions {
    
    func weeklyRebalance(newFile: String)-> String {
        
        let filteredSymbolsData = FilteredSymbolsData()
        
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
        let latestData = csvParse.data
        
        //MARK: -  get current symbols from realm
        //let realm = try! Realm()
        let allObjects = filteredSymbolsData.readObjctsFromRealm()
        
        var theseTickers  = [String]()
        
        // make an array of Tickers
        for items in allObjects {
            theseTickers.append(items.ticker)
        }
        
        // todays date
        let date = Date()
        let formatter = DateFormatter()
        //Give the format you want to the formatter:
        formatter.dateFormat = "dd.MM.yyyy"
        //Get the result string:
        let todaysDate = formatter.string(from: date)
        
        
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
            //MARK: -  sell position if not
            //MARK: -  query in top 20%
            //MARK: -  query for above 100 sma
            //MARK: -  query if N has gap > 15
            //MARK: -  query is in index - have to do another pass later for date
            if trend != 1  || gap > 14 || index > 100 {
                advise = "Sell"
               // print("\nSell was triggered on \(ticker) \(trend) \(gap) \(index)\n")
            }
            
            // update realm to hold / sell
            let realm = try! Realm()
 
            if theseTickers.contains(ticker) {
                
                print("The Ticker detected in Data: \(ticker)")
                
                let thisObject = realm.objects(TickersData.self).filter("ticker = '\(ticker)'")
                
                try! realm.write {
                    
                    thisObject[0].action = advise
                    thisObject[0].lastUpdate = todaysDate
                }
                
                print("\nYO Bitch I got ---- \(thisObject)\n")
                
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
        return result
    }
    
    // Calc the Position rebalance every 2nd weds = Check position size
    func biWeeklyRebalance(newFile: String)-> String  {
        
        var result = "Ticker\tRow\tTrend\tGap\tAdvise\tOld Weight\tNew Weight\n"
        //MARK: - get data from last parse
        let csvParse = CSVParse()
        
        // read data from file and saves a string Data object
        guard let fileString = csvParse.readDataFromFile(file: newFile) else {
            result = "Warning csv file does not exist!"
            return result
        }
        
        // load the filestring into a dictionary
        _ = csvParse.printData(of: fileString)
        let latestData = csvParse.data
        
        //MARK: -  get current symbols from realm
        let otherRealm = try! Realm()
        
        let otherResults = otherRealm.objects(FilteredSymbolsData.self)
        
        print(otherResults)
        var theseTickers  = [String]()
        
        // make an array of Tickers
        for items in otherResults {
            theseTickers.append(items.allTickers[0].ticker)
        }
        
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
            guard let targetWeight = Double(row["\"Target Weight\""]!) else {
                print("Got nil in targetWeight")
                continue
            }
            var hold = "Hold"
            //MARK: -  sell position if not
            //MARK: -  query in top 20%
            //MARK: -  query for above 100 sma
            //MARK: -  query if N has gap > 15
            //MARK: -  query is in index
            
            // first see if this ticker should still be in portfolio then change hold to sell
            if trend != 1  || gap > 14 || index > 100 {
                hold = "Sell"
            }
            
            if theseTickers.contains(ticker) {
                
//               let puppies = otherRealm.objects(FilteredSymbolsData.self).filter("allTickers == %@", ticker)
//                print("my puppies: \(puppies)")
                
                result += "\(ticker)  \t\(index)\t\(trend)\t\(gap)   \t\(hold)\(targetWeight)\n"
                
            }
        }
        
        return result
    }
}


