//
//  CSVParser.swift
//  momoCSV
//
//  Created by Warren Hansen on 5/5/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class FilteredSymbols: Tickers {
    
    var allTickers = [Tickers]()
    
    static let shared = FilteredSymbols()
    
}

class Tickers: NSObject {
    
    var ticker = ""
    
    var close = 0.0
    
    var weight = 0.0
    
    var updated = ""
}


class CSVParse: NSObject {
    
    var  data:[[String:String]] = []
    
    var  columnTitles:[String] = []
    
    func readDataFromFile(file:String)-> String!{
        guard let filepath = Bundle.main.path(forResource: file, ofType: "csv")
            else {
                return nil
        }
        do {
            let contents = try String(contentsOfFile: filepath, encoding: .utf8)
            return contents
        } catch {
            print("File Read Error for file \(filepath)")
            return nil
        }
    }
    
    func cleanRows(file: String) -> String {
        var cleanFile = file
        cleanFile = cleanFile.replacingOccurrences(of: "\r", with: "\n")
        cleanFile = cleanFile.replacingOccurrences(of: "\n\n", with: "\n")
        return cleanFile
    }
    
    // Convert Cleaned cvs file to dictionary
    func convertCSV(file:String) {
        let rows = cleanRows(file: file).components(separatedBy: "\n")
        if rows.count > 0 {
            data = []
            columnTitles = getStringFieldsForRow(row: rows.first!,delimiter:",")
            
            for row in rows{
                
                var fields = getStringFieldsForRow(row: row,delimiter: ",")
                
                // concatonate for a comma in fields[8]
                if fields.count != columnTitles.count && fields.count > 1 {
                    let combinedElement = "\(fields[8])-\(fields[9])"
                    fields[8] = combinedElement
                    fields.remove(at: 9)
                }
                
                // concatonate for a 2nd comma in fields[8]
                if fields.count != columnTitles.count && fields.count > 1 {
                    let combinedElement = "\(fields[8])-\(fields[9])"
                    fields[8] = combinedElement
                    fields.remove(at: 9)
                }
                var dataRow = [String:String]()
                
                for (index,field) in fields.enumerated(){
                    
                    let fieldName = columnTitles[index]  // indedx error here
                    dataRow[fieldName] = field
                }

                data += [dataRow]
                
            }
        } else {
            print("No data in file")
        }
    }
    
    func getStringFieldsForRow(row: String, delimiter: String) -> [String] {
        return row.components(separatedBy: delimiter)
    }
    
    func printData(of: String) -> String {
        convertCSV(file: of)
        var tableString = ""
        var rowString = ""

        for row in data{
            rowString = ""
            for fieldName in columnTitles{
                guard let field = row[fieldName] else{
                    print("field not found: \(fieldName)")
                    continue
                }
                rowString += String(format:"%@     ",field)
            }
            tableString += rowString + "\n"
        }
        return tableString
    }
    
    func compareWeights(account_One: Int, account_Two: Int)-> String {
        
        var messageText = "Bi Monthly Rebalance\n\n"
        
        let totalCash = Double( account_One + account_Two )
        
        // make a tuple array of tickers in portfloio
        let realm = try! Realm()
        
        let allObjects = FilteredSymbolsData().readObjctsFromRealm()
        
        var tupleArray: [(ticker: String, weight: Double)] = []
        
        // make an array of Tickers
        for items in allObjects {
            //theseTickers.append(items.ticker)
            tupleArray.append((ticker: items.ticker, weight: items.weight))
        }
        
        // loop rows in newest file
        for row in data {
                
            guard let ticker = row["Ticker"] else {
                print("Got nil in ticker")
                continue
            }

            guard let close = Double(row["\"Close Price\""]!) else {
                print("Got nil in Close Price")
                continue
            }
            
            guard let targetWeight = Double(row["\"Target Weight\""]!) else {
                print("Got nil in targetWeight")
                continue
            }
            
            // if tickers match compare weight and alert if different
            if tupleArray.contains(where: { $0.0 == ticker }) {
                // get this specific ticker from realm
                let thisTicker = realm.objects(TickersData.self).filter("ticker = '\(ticker)'")
                
                // if different
                if targetWeight != thisTicker[0].weight {
                    messageText +=  "\(ticker) : \(targetWeight) New Weight \(thisTicker[0].ticker) : \(thisTicker[0].weight)\n"
                    
                    // calc shares to buy or sell
                    let thisAllocation =  totalCash * ( targetWeight * 0.01) // get cash in % of total portfolio
                    
                    let numShares = thisAllocation / close  // String(format: "%.0f", n))
                    
                    let diff = numShares - thisTicker[0].shares
                    
                    messageText += "Before: \(String(format: "%.0f", thisTicker[0].shares)) After: \(String(format: "%.0f", numShares)) Adjustment \(String(format: "%.0f", diff))\n\n"
                    
                    // replace weight in realm
                    try! realm.write {
                        thisTicker[0].shares = numShares
                    }
                }
            }
        }
        
        // make journal entry
        JournalUpdate().addContent(lastEntry: messageText)
        
        let latestPortfolio = "Portfollio now is:\n \(FilteredSymbolsData().readFromRealm())"
        
        JournalUpdate().addContent(lastEntry: latestPortfolio)
        
        return messageText
    }
    
    //MARK: - Filter Tickers
    func filterTickers(file: String) {
        
        var totalPortfoio = 0.0
        
        var filteredResults = ""
        
        //      Portfolio Rebalancing Every Wednesday
        //      1. Sell Stocks not in top 20% = get row number
        //      2. Sell Stocks below 100 SMA
        //      3. Sell Stocks that gap over 15%in last week
        //      4. Sell if Stock Left Index
        
        for (index, row ) in data.enumerated() {
            
            if index > 0 && totalPortfoio < 105 { // exclude title row and portfolio full
                
                let thisTicker = Tickers()
                
                let newTicker = TickersData()
                
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
                if trend == 1   && gap < 15 {
                    let results = "\nticker: \(ticker) Date: \(updated) slope:\(slope) trend: \(trend) gap: \(gap) Taregt Weight: \(targetWeight) Total Weight: \(totalPortfoio)"
                  
                    filteredResults += results
                    thisTicker.ticker = ticker
                    // trim porfolio wieght > 100 ooon last sybmol
                    if totalPortfoio > 100 {
                        thisTicker.weight = ( targetWeight - totalPortfoio - 100 )
                    } else {
                        thisTicker.weight =  targetWeight
                    }
                    thisTicker.weight = targetWeight
                    thisTicker.close = close
                    
                    // realm persistant Data
                    newTicker.ticker = ticker
                    newTicker.weight = targetWeight
                    newTicker.close = close
                    newTicker.updated = updated
                    newTicker.currentFileName = file
                    
                    let realm = try! Realm()
                    
                    try! realm.write() {
                        //let person = realm.create(FilteredSymbolsData.self, value: [ticker, targetWeight, close])
                       // filteredSymbolsData.append(newRow)
                        realm.add(newTicker)
                    }
                    
                    //filteredSymbols.allTickers.append(thisTicker)
                    
                } else {
                    print("Excluded: \(ticker) Trend: \(trend) Gap: \(gap)")
                }
                totalPortfoio += targetWeight
            }
        }
        
        // return filteredSymbols
    }
    
}
