//
//  Date Helpers.swift
//  momoCSV
//
//  Created by Warren Hansen on 5/17/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//

import Foundation
import UIKit

class DateFunctions {

    func dateToString() -> String {
        // todays date
        let date = Date()
        let formatter = DateFormatter()
        //Give the format you want to the formatter:
        formatter.dateFormat = "MM.dd.yyyy"
        //Get the result string:
        let todaysDate = formatter.string(from: date)
        return todaysDate
    }
    
    func timeToString()-> String {
        let date = Date()
        let calendar = Calendar.current
        
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        let seconds = calendar.component(.second, from: date)
        return "\(hour):\(minutes):\(seconds)"
    }
}

extension Date {
    func dayNumberOfWeek() -> Int? {
        return Calendar.current.dateComponents([.weekday], from: self).weekday
    }
}

// returns an integer from 1 - 7, with 1 being Sunday and 7 being Saturday
//print(Date().dayNumberOfWeek()!) // 4
