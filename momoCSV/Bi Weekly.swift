//
//  Bi Weekly.swift
//  momoCSV
//
//  Created by Warren Hansen on 5/24/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//

import Foundation

class BiMonthlyUpdate {
    
    var regAccount = 266297
    
    var iraAccount = 71336
    
    var messageText = ""
    
    let csvParse = CSVParse()
    
    let filteredSymbolsData = FilteredSymbolsData()
    
    //MARK: - Bi Monthly compare new weight to current weight
    func compareWeight(latestFile: String, account_One: Int, account_Two: Int)-> String {
        
        regAccount = account_One
        
        iraAccount = account_Two
        
        // load new cvs as Dictionary
        messageText = InitialImportClass().importAndParseCSV(file: latestFile)
        
        compareWeight(latestFile: latestFile)
        
        return messageText
    }
    
    //MARK: - Bi Monthly compare new weight to current weight
    func compareWeight(latestFile: String) {
        
        // load new cvs as Dictionary
        messageText = importAndParseCSV(file: latestFile)
        
        messageText = csvParse.compareWeights(account_One: regAccount, account_Two: iraAccount)
    }
    
    //MARK - Helper Functions  import CSV
    func importAndParseCSV(file: String)-> String {
        guard let fileString = csvParse.readDataFromFile(file: file) else {
            messageText =  "Warning csv file does not exist!"
            return "Warning csv file does not exist!"
        }
        
        // calls convertCSV, cleanRows returns String
        return  csvParse.printData(of: fileString)
    }
    
}
