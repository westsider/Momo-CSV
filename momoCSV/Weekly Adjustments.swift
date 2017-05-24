//
//  Weekly Adjustments.swift
//  
//
//  Created by Warren Hansen on 5/24/17.
//
//

import Foundation
//
//class  WeeklyUpdate {
//    
//    var messageText = ""
//    
//    let portfolioActions = PortfolioActions()
//    
//    func weeklyPortfolioUpdate(file: String) {
//        
//        // first run assign a name so we dont get nil
//        if  UserDefaults.standard.object(forKey: "FileName") == nil { UserDefaults.standard.set("noFile", forKey: "FileName") }
//        
//        let thisFIle = UserDefaults.standard.object(forKey: "FileName") as! String
//        
//        print("\nIn WeeklyImport got \(thisFIle) as file name\n")
//        
//        // if not same fie then run update
//        if thisFIle != file {
//            print("\n\(thisFIle) is a new filename so running the rebalance\n")
//            messageText = portfolioActions.weeklyRebalance(newFile: file)
//            //textView.text = messageText
//            JournalUpdate().addContent(lastEntry: messageText)
//            print("\nWEEKLY UPDATE\n")
//            print(FilteredSymbolsData().readObjctsFromRealm())
//            // update nsuserdefaults
//            UserDefaults.standard.set(file, forKey: "FileName")
//            weeklyImportButton.isEnabled = false
//            replacePortfolioButton.isEnabled = true
//        } else {
//            // send error pop up if file was alreeady imported
//            print("\n\(file) isn'T a new filename so show error message\n")
//            warningMessage(message: "You've aready imported the file \(file)")
//        }
//        
//        print("\nCalling delete sells\n")
//        
//        let newPortfolioSum = portfolioActions.deleteSells()
//        
//        let cashAvailable = newPortfolioSum.ira + newPortfolioSum.reg
//        
//        let thisUpdate = "Sum of new Portfolio is \(newPortfolioSum) and available cash is \(cashAvailable)\n\(newPortfolioSum.reg) in Reg and \(newPortfolioSum.ira)in Ira"
//        
//        JournalUpdate().addContent(lastEntry: thisUpdate)
//        
//        portfolioActions.searchForNewBuys(account_One: regAccount, account_Two: iraAccount)
//    }
//    
//}
