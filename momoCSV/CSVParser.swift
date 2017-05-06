//
//  CSVParser.swift
//  momoCSV
//
//  Created by Warren Hansen on 5/5/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//

import Foundation
import UIKit

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
    
    
    func convertCSV(file:String) {
        let rows = cleanRows(file: file).components(separatedBy: "\n")
        if rows.count > 0 {
            data = []
            columnTitles = getStringFieldsForRow(row: rows.first!,delimiter:",")
            for row in rows{
                let fields = getStringFieldsForRow(row: row,delimiter: ",")
                if fields.count != columnTitles.count {continue}
                var dataRow = [String:String]()
                for (index,field) in fields.enumerated(){
                    let fieldName = columnTitles[index]
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
    
}
