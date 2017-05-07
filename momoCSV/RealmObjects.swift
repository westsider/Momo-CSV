//
//  RealmObjects.swift
//  momoCSV
//
//  Created by Warren Hansen on 5/6/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//

import Foundation
import RealmSwift

//// class to add tableview rows to each event
//class TableViewRow: Object {
//    dynamic var icon = ""
//    dynamic var title = ""
//    dynamic var detail =  ""
//    dynamic var catagory = 0
//    
//    override var description: String { return "TableViewRow {\(icon), \(title), \(detail)}" }
//}
//
//// class to hold each event, user and tableview list of equipment
//class EventUserRealm: Object {
//    
//    dynamic var eventName = "Default"
//    dynamic var taskID = NSUUID().uuidString
//    dynamic var userName = "Default"
//    dynamic var production = ""
//    dynamic var company = ""
//    dynamic var city = ""
//    dynamic var date = ""
//    dynamic var weather = ""
//    
//    var tableViewArray = List<TableViewRow>()
//}

class TickersData: Object {

    dynamic var ticker = ""
    
    dynamic var close = 0.0
    
    dynamic var weight = 0.0
}

class FilteredSymbolsData: Object {
    
    dynamic var taskID = NSUUID().uuidString
    
    let allTickers = List<TickersData>()
    
}

