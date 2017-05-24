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
    
    let dayOfWeek = Date().dayNumberOfWeek()!

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
    
    func enableDayOfWeekFilter(day: Int, on: Bool)-> Bool {
        var state = true
        // wednesday == 4
        if on {
            state = false
            //MARK: - Weekly rebalance reminder
            if dayOfWeek == day {
                //textView.text = "Today is wednesday have you updated the portfolio?"
                // enable weekly update button
                state = true
            }
        }
        return state
    }
}

extension Date {
    func dayNumberOfWeek() -> Int? {
        return Calendar.current.dateComponents([.weekday], from: self).weekday
    }
}

// returns an integer from 1 - 7, with 1 being Sunday and 7 being Saturday
//print(Date().dayNumberOfWeek()!) // 4
