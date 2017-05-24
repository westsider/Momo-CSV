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
//  func initialImport()                                                    
//  on subsequent runs load realm portfolio
//  create a journal entry of actions in realm, text var object in realm
//  every weds manually add a new csv file, change "latestDownload"
//  updateWeeklyPortfolio()
//  Show any buy / sell actions
//  disable button until next weds
//  enable "Replace Proftfolio" button
//  delete sells in current portfolio
//  get the available cash
//  add journal entry
//  show list of new buys
//  position size new buys in portfolio
//  task:  re order buttoms + remove top row
//  task: added logo
//  task: if 2nd weds    compareWeight()

//  change Journal report of port folio to include eveything
//  insure week 3 does become base portfolio and week 2 never does
//  delete class NewBuys: Object when finished with it
//  make UI nicer
//      latest is 5-22

import UIKit
import RealmSwift
import MessageUI

class ViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var regTextField: UITextField!
    
    @IBOutlet weak var iraTextField: UITextField!
    
    @IBOutlet weak var weeklyImportButton: UIButton!
    
    @IBOutlet weak var replacePortfolioButton: UIButton!
    
    let csvParse = CSVParse()
    
    let filteredSymbolsData = FilteredSymbolsData()
    
    let positionSize = PositionSize()
    
    let portfolioActions = PortfolioActions()
    
    let realm = try! Realm()
    
    let regAccount = 266297
    
    let iraAccount = 71336
    
    let origDownload    = "2017_05_04"
    
    let secondDownload  = "Momentum rankings - 2017-05-11 - $spx"   // weekly download
    
    let thirdDownload   = "Momentum rankings - 2017-05-16 - $spx"   // Bi Monthly Download
    
    let dayOfWeek = Date().dayNumberOfWeek()!
    
    var messageText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        regTextField.text = "\(regAccount)"
        
        iraTextField.text = "\(iraAccount)"
        
        //MARK: - Original file import - Only happens once and is then disabled
        messageText = initialImport(origFile: origDownload)
        
        textView.text = messageText
        
        enableDayOfWeekFilter(day: 4, on: false)
    }

    //MARK: - Weekly Rebalance ### FIRST ACTION ###
    @IBAction func weeklyImportAction(_ sender: Any) {
        // get new cvs and look for stocks I should sell
        weeklyPortfolioUpdate(file: secondDownload)
    }
    
     //MARK: - make new buys ### SECOND ACTION ###
    @IBAction func newBuysAction(_ sender: Any) {
        // retrieve potential buys and allocate
        portfolioActions.allocateNewBuys()
    }
    
    //MARK: - Show portfolio
    @IBAction func showPortfolio(_ sender: Any) {
        textView.text =  positionSize.getRealmPortfolio()
    }
    
    //MARK: - Show Journal
    @IBAction func showJournal(_ sender: Any) {
        
        textView.text = JournalUpdate().readContent()
    }
    
    //MARK: - bi-weekly action  ### THIRD ACTION ###
    @IBAction func biWeeklyAction(_ sender: Any) {
        // get new cvs and look for stocks I should sell
        //weeklyPortfolioUpdate()
        // then compare weight to prior portfolio
        compareWeight(latestFile: thirdDownload)
        
    }

    //MARK: - Bi Monthly compare new weight to current weight
    func compareWeight(latestFile: String) {
        
        // check if 2nd or 4th weds?
        
        // load new cvs as Dictionary
        messageText = importAndParseCSV(file: latestFile)
        
        textView.text = csvParse.compareWeights(account_One: regAccount, account_Two: iraAccount)
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
    
    //MARK - Helper Functions Alert VC
    func warningMessage(message: String) {
        let alertController : UIAlertController = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        
        let action_cancel = UIAlertAction.init(title: "OK", style: .default) { (UIAlertAction) -> Void in }
        
        alertController.addAction(action_cancel)
        
        present(alertController, animated: true, completion: nil)
    }
    
    //MARK - Helper Functions  filter and save
    func filterTickersAndSaveRealm(file: String) -> String {
        //  Saves to realm Ticker Objects of top momentum symbols that fit portfolio
        csvParse.filterTickers(file: file)
        
        // reads filtered symbols from realm
        return filteredSymbolsData.readFromRealm()
    }
    
    //MARK - Helper Functions  import CSV
    func importAndParseCSV(file: String)-> String {
        guard let fileString = csvParse.readDataFromFile(file: file) else {
            textView.text =  "Warning csv file does not exist!"
            return "Warning csv file does not exist!"
        }
        
        // calls convertCSV, cleanRows returns String
        return  csvParse.printData(of: fileString)
    }
    
    func weeklyPortfolioUpdate(file: String) {
        
        // first run assign a name so we dont get nil
        if  UserDefaults.standard.object(forKey: "FileName") == nil { UserDefaults.standard.set("noFile", forKey: "FileName") }
        
        let thisFIle = UserDefaults.standard.object(forKey: "FileName") as! String
        
        print("\nIn WeeklyImport got \(thisFIle) as file name\n")
        
        // if not same fie then run update
        if thisFIle != file {
            print("\n\(thisFIle) is a new filename so running the rebalance\n")
            messageText = portfolioActions.weeklyRebalance(newFile: file)
            textView.text = messageText
            JournalUpdate().addContent(lastEntry: messageText)
            print("\nWEEKLY UPDATE\n")
            print(FilteredSymbolsData().readObjctsFromRealm())
            // update nsuserdefaults
            UserDefaults.standard.set(file, forKey: "FileName")
            weeklyImportButton.isEnabled = false
            replacePortfolioButton.isEnabled = true
        } else {
            // send error pop up if file was alreeady imported
            print("\n\(file) isn'T a new filename so show error message\n")
            warningMessage(message: "You've aready imported the file \(file)")
        }
        
        print("\nCalling delete sells\n")
        
        let newPortfolioSum = portfolioActions.deleteSells()
        
        let cashAvailable = newPortfolioSum.ira + newPortfolioSum.reg
        
        let thisUpdate = "Sum of new Portfolio is \(newPortfolioSum) and available cash is \(cashAvailable)\n\(newPortfolioSum.reg) in Reg and \(newPortfolioSum.ira)in Ira"
        
        JournalUpdate().addContent(lastEntry: thisUpdate)
        
        portfolioActions.searchForNewBuys(account_One: regAccount, account_Two: iraAccount)
    }
    
    func enableDayOfWeekFilter(day: Int, on: Bool) {
        // wednesday == 4
        if on {
            weeklyImportButton.isEnabled = false
            //MARK: - Weekly rebalance reminder
            if dayOfWeek == day {
                textView.text = "Today is wednesday have you updated the portfolio?"
                // enable weekly update button
                weeklyImportButton.isEnabled = true
            }
        }
    }
    
    @IBAction func shareAction(_ sender: Any) {
        messageText = JournalUpdate().readContent()
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
        
        UserDefaults.standard.set(nil, forKey: "FirstRun")
        
        UserDefaults.standard.set(nil, forKey: "FileName")
        
        textView.text = initialImport(origFile: origDownload)
        
        textView.text =  "Realm Database Deleted"
    }
    
    // this is where I update account bal
    @IBAction func updateAccounts(_ sender: Any) {
        
    }
}



