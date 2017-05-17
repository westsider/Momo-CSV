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
//  add 3 buttons

/*
 Need to automate the weekly update becuase it is error prone if working / traveling
 
 I. func initialImport()                                                DONE
 * Only happens once on first run in VDL using NSUserdefaults           DONE
 * on subsequent runs load realm portfolio                              DONE
 * create a journal entry of actions in realm, text var object in realm DONE
 II. every weds                                                         DONE
 * manually add a new csv file, change "latestDownload"                 DONE
 * updateWeeklyPortfolio()                                              DONE
 *** if 2nd weds
 * compareWeight()
 * Show any buy / sell actions                                          DONE
 * disable button until next weds
 * enable replace BaseProftfolio
 * then disables replace portfolio
 * update journal entry of actions in realm
 */
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
        //MARK: - Original file import - Only happens once and is then disabled
        textView.text = initialImport(origFile: portfolioDownload)
    }
    
    //MARK: - Weekly Rebalance
    @IBAction func weeklyImportAction(_ sender: Any) {
        messageText = portfolioActions.weeklyRebalance(newFile: latestDownload)
        textView.text = messageText
        print("\nWEEKLY UPDATE\n")
        print(FilteredSymbolsData().readObjctsFromRealm())
    }
    //MARK: - Show portfolio
    @IBAction func originalImportAction(_ sender: Any) {
        textView.text =  positionSize.getRealmPortfolio()
    }
    
    //MARK: - Show Journal
    @IBAction func showJournal(_ sender: Any) {
        textView.text = JournalUpdate().readContent()
    }
    
    func initialImport(origFile: String)-> String {
        
        // check nsuserdefaults if 1strun
        if  UserDefaults.standard.object(forKey: "FirstRun") == nil {
            
            print("\nThis was first run.\n")
            
            messageText = importAndParseCSV(file: origFile)
            
            messageText = filterTickersAndSaveRealm(file: origFile)
            
            messageText = positionSize.calcPositionSise(account_One: regAccount, account_Two: iraAccount)
            
            positionSize.splitRealmPortfolio(account_One: regAccount, account_Two: iraAccount)
            
            // update nsuserdefaults
            UserDefaults.standard.set(false, forKey: "FirstRun")
            
            messageText =  positionSize.getRealmPortfolio()
            
            JournalUpdate().addContent(lastEntry: messageText)
        }
        
        messageText =  positionSize.getRealmPortfolio()
        
        return messageText
    }
    
    func warningMessage(message: String) {
        let alertController : UIAlertController = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        
        let action_cancel = UIAlertAction.init(title: "OK", style: .default) { (UIAlertAction) -> Void in }
        
        alertController.addAction(action_cancel)
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    // read data from file and saves a string Data object
    @IBAction func importAction(_ sender: Any) {
        //textView.text = importAndParseCSV()
    }
    
    @IBAction func fiterAction(_ sender: Any) {
        //textView.text = filterTickersAndSaveRealm()
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
        //print(FilteredSymbolsData().readObjctsFromRealm())
    }
    
    func importAndParseCSV(file: String)-> String {
        guard let fileString = csvParse.readDataFromFile(file: file) else {
            textView.text =  "Warning csv file does not exist!"
            return "Warning csv file does not exist!"
        }
        
        // calls convertCSV, cleanRows returns String
        return  csvParse.printData(of: fileString)
    }
    
    func filterTickersAndSaveRealm(file: String) -> String {
        //  Saves to realm Ticker Objects of top momentum symbols that fit portfolio
        csvParse.filterTickers(file: file)
        
        // reads filtered symbols from realm
        return filteredSymbolsData.readFromRealm()
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



