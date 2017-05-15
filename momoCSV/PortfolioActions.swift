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
        
        print("Called weeklyRebalance")
        
        var result = "Ticker\tRow\tTrend\tGap\tAdvise\n"
        //MARK: - get data from last parse
        let csvParse = CSVParse()
        
        // read data from file and saves a string Data object
        guard let fileString = csvParse.readDataFromFile(file: newFile) else {
            print( "Warning csv file does not exist!")
            result = "Warning csv file does not exist!"
            return result
        }
        
        // load the filestring into a dictionary
        _ = csvParse.printData(of: fileString)
        let latestData = csvParse.data
        
        //MARK: -  get current symbols from realm
        let otherRealm = try! Realm()
        
        let otherResults = otherRealm.objects(FilteredSymbolsData.self)
        
        var theseTickers  = [String]()
        
        // make an array of Tickers
        for items in otherResults {
            theseTickers.append(items.allTickers[0].ticker)
        }
        
        //MARK: = Check if symbol is in top 20%
        for (index, row ) in latestData.enumerated() {

            //for thisTicker in theseTickers {
                
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
                
                var hold = "Hold"
                
                if trend != 1  || gap > 14 || index > 100 {
                    hold = "Sell"
                }
                
            //let elements = [1,2,3,4,5]
            if theseTickers.contains(ticker) {
               // print("yes")
                //result += "Match\n"
            //}
                
                //if thisTicker == ticker && thisTicker != lastTicker {
                   // lastTicker = thisTicker
                    result += "\(ticker)  \t\(index)\t\(trend)\t\(gap)   \t\(hold)\n"

                }
            //}
        }
        //MARK: -  sell position if:
        //MARK: -  query in top 20%
        //MARK: -  query for above 100 sma
        //MARK: -  query if N has gap > 15
        //MARK: -  query is in index
        
        return result
        
    }
    
    
}


