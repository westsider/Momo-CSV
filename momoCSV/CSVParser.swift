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
            //let contents = try String(contentsOfFile: filepath, usedEncoding: nil)
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
        //cleanFile = cleanFile.replacingOccurrences(of: "5c", with: "")
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
        //print("data: \(data)")
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
    
    //MARK: - Filter Tickers
    func filterTickers() -> FilteredSymbols {
        
        var totalPortfoio = 0.0
        
        var filteredResults = ""
        
        let filteredSymbols = FilteredSymbols()
        
        let filteredSymbolsData = List<TickersData>()
        
        //filteredSymbols.allTickers.removeAll()
        
        for (index, row ) in data.enumerated() {
            
            if index > 0 && totalPortfoio < 105 { // exclude title row and portfolio full
                
                let thisTicker = Tickers()
                
                let newRow = TickersData()
                
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
                if trend == 1   && gap < 15 {
                    let results = "\nticker: \(ticker) slope:\(slope) trend: \(trend) gap: \(gap) Taregt Weight: \(targetWeight) Total Weight: \(totalPortfoio)"
                    //print(results)
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
                    newRow.ticker = ticker
                    newRow.weight = targetWeight
                    newRow.close = close
                    //print("\nAdded A Realm Row: \(newRow)\n")
                    
                    let realm = try! Realm()
                    
                    try! realm.write() {
                        //let person = realm.create(FilteredSymbolsData.self, value: [ticker, targetWeight, close])
                        filteredSymbolsData.append(newRow)
                        realm.add(filteredSymbolsData)
                    }
                    
                    //print("Adding: \(thisTicker.ticker)")
                    filteredSymbols.allTickers.append(thisTicker)
                    
                } else {
                    print("Excluded: \(ticker) Trend: \(trend) Gap: \(gap)")
                }
                totalPortfoio += targetWeight
                
            }
            
        }
        print("\ntotalPortfoio \(totalPortfoio)\n")
        return filteredSymbols
    }
    
}
