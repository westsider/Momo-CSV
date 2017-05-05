//
//  ViewController.swift
//  momoCSV
//
//  Created by Warren Hansen on 5/5/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    let csvParse = CSVParse()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fileString = csvParse.readDataFromFile(file: "2017_05_04")
        
        let cleanedRows = csvParse.cleanRows(file: fileString!)
  
        textView.text = csvParse.printData(of: cleanedRows)
        
        print("The Titles: \(csvParse.data[0])")
        
        print("Row 1: \(csvParse.data[1])")
    }

}

