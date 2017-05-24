//
//  Alerts.swift
//  momoCSV
//
//  Created by Warren Hansen on 5/24/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//

import Foundation
import UIKit
import MessageUI

// neither of these work outside og the man VV


//class PopUpAlert: UIViewController {
//    
//    //MARK - Helper Functions Alert VC
//    func warningMessage(message: String) {
//        let alertController : UIAlertController = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
//        
//        let action_cancel = UIAlertAction.init(title: "OK", style: .default) { (UIAlertAction) -> Void in }
//        
//        alertController.addAction(action_cancel)
//        
//        present(alertController, animated: true, completion: nil)
//    }
//    
//    func sendMessage() {
//        
//        let messageText = JournalUpdate().readContent()
//        let activityVC = UIActivityViewController(activityItems: [messageText], applicationActivities: nil)
//        activityVC.setValue("Portfolio Update", forKey: "Subject")
//        // exclude sms from sharing with images
//        activityVC.excludedActivityTypes = [ UIActivityType.message ]
//        self.present(activityVC, animated: true, completion: nil)
//        
//    }
//}
