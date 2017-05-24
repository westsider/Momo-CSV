//
//  Initial Import.swift
//  momoCSV
//
//  Created by Warren Hansen on 5/24/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//

import Foundation

class InitialImportClass {
    
    let positionSize = PositionSize()
    
    let csvParse = CSVParse()
    
    let filteredSymbolsData = FilteredSymbolsData()
    
    var messageText = ""
    
    func initialImport(origFile: String, accouny_One: Int, account_Two: Int)-> String {
        
        // check nsuserdefaults if 1strun
        if  UserDefaults.standard.object(forKey: "FirstRun") == nil {
            
            print("\nThis was first run.\n")
            
            messageText = importAndParseCSV(file: origFile)
            
            messageText = filterTickersAndSaveRealm(file: origFile)
            
            messageText = positionSize.calcPositionSise(account_One: accouny_One, account_Two: account_Two)
            
            positionSize.splitRealmPortfolio(account_One: accouny_One, account_Two: account_Two)
            
            // update nsuserdefaults
            UserDefaults.standard.set(false, forKey: "FirstRun")
            
            messageText =  positionSize.getRealmPortfolio()
            
            JournalUpdate().addContent(lastEntry: messageText)
        }
        
        messageText =  positionSize.getRealmPortfolio()
        
        return messageText
    }
    
    //MARK - Helper Functions  import CSV
    func importAndParseCSV(file: String)-> String {
        guard let fileString = csvParse.readDataFromFile(file: file) else {
            return "Warning csv file does not exist!"
        }
        
        // calls convertCSV, cleanRows returns String
        return  csvParse.printData(of: fileString)
    }
    
    //MARK - Helper Functions  filter and save
    func filterTickersAndSaveRealm(file: String) -> String {
        //  Saves to realm Ticker Objects of top momentum symbols that fit portfolio
        csvParse.filterTickers(file: file)
        
        // reads filtered symbols from realm
        return filteredSymbolsData.readFromRealm()
    }
}
