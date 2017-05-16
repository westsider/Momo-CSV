//
//  ViewController.swift
//  momoCSV
//
//  Created by Warren Hansen on 5/5/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.

//  task: Add gap + trend filter to list
//  bug: why am I filtering IDXX in my main data file?
//  task: move tickerFIlter to another class
//  func to print filtered tickers
//  task: button to show filtered tickers
//  fix: adding wrong symbols to filtered
//  task: add realm
//  task: calc num shares on 325,000
//  task: split shares on IRS 75k vs Reg 250k
//  fix: error in poition size as % of total portfolio
//  fix: allocation of 75K to IRA
//  fix UI for split of portfolio
//  task: print the sum or IRA and Reg
//  Construct the initial portfolio. Buy from the top until you run out of cash.
//  task: Portfolio accounts as inputs
//  task: Calc the Portfolio rebalance every weds
//  task: Check for new csv and run weekly rebalance on it
//  style: cleaned up print statements
//  task: implement share
//  task: re wrote object so I can update each tickers properties

//  Calc the Position rebalance every 2nd weds = Check position size
//  Download the cvs directly to my own backend

import UIKit
import RealmSwift
import MessageUI

class ViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var regTextField: UITextField!
    
    @IBOutlet weak var iraTextField: UITextField!
    
    let csvParse = CSVParse()
    
    let filteredSymbolsData = FilteredSymbolsData()
    
    let positionSize = PositionSize()
    
    let portfolioActions = PortfolioActions()

    let realm = try! Realm()
    
    let regAccount = 266297
    
    let iraAccount = 71336
    
    let portfolioDownload = "2017_05_04"
    
    let latestDownload = "Momentum rankings - 2017-05-11 - $spx"
    
    var messageText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        regTextField.text = "\(regAccount)"
        iraTextField.text = "\(iraAccount)"
    }
    
    // read data from file and saves a string Data object
    @IBAction func importAction(_ sender: Any) {
        
        guard let fileString = csvParse.readDataFromFile(file: portfolioDownload) else {
            textView.text =  "Warning csv file does not exist!"
            return
        }
        
        // calls convertCSV, cleanRows returns String
        messageText = csvParse.printData(of: fileString)

        textView.text = messageText
    }

    @IBAction func fiterAction(_ sender: Any) {
        
        //  Saves to realm Ticker Objects of top momentum symbols that fit portfolio
        csvParse.filterTickers()
        
        // reads filtered symbols from realm
        messageText = filteredSymbolsData.readFromRealm()
        
        textView.text = messageText
        
        //print(FilteredSymbolsData().readObjctsFromRealm())
    }
    
    //MARK: - Load Realm array of Ticker Objects and assigns cash value to each symbol and save to realm
    @IBAction func posSizeAction(_ sender: Any) {
        messageText = positionSize.calcPositionSise(account_One: regAccount, account_Two: iraAccount)
        textView.text  =  messageText
        //print(FilteredSymbolsData().readObjctsFromRealm())
    }

    //MARK: - Load Realm array of Ticker Objects and split into ira nad reg
    @IBAction func splitPortfolio(_ sender: Any) {
        positionSize.splitRealmPortfolio(account_One: regAccount, account_Two: iraAccount)
        messageText =  positionSize.getRealmPortfolio()
        textView.text = messageText
        print("\nSPLIT PORTFOLIO\n")
       //print(FilteredSymbolsData().readObjctsFromRealm())
    }
    
    //MARK: - Weekly Rebalance
    @IBAction func weeklyRebalanceAction(_ sender: Any) {
        messageText = portfolioActions.weeklyRebalance(newFile: latestDownload)
        textView.text = messageText
        print("\nWEEKLY UPDATE\n")
        print(FilteredSymbolsData().readObjctsFromRealm())
    }
    
    @IBAction func biWeeklyRebalance(_ sender: Any) {
        messageText = portfolioActions.biWeeklyRebalance(newFile: latestDownload)
        textView.text = messageText
    }
    @IBAction func shareAction(_ sender: Any) {
        let activityVC = UIActivityViewController(activityItems: [messageText], applicationActivities: nil)
        activityVC.setValue("Portfolio Update", forKey: "Subject")
        // exclude sms from sharing with images
        activityVC.excludedActivityTypes = [ UIActivityType.message ]
        self.present(activityVC, animated: true, completion: nil)
    }
        @IBAction func clearRealm(_ sender: Any) {
        //MARK: - Delete All
        try! realm.write {
            realm.deleteAll()
        }
        textView.text =  "Realm Database Deleted"
    }
    
    // this is where I update account bal
    @IBAction func updateAccounts(_ sender: Any) {
        
    }
}



