//
//  BestFitIRA.swift
//  momoCSV
//
//  Created by Warren Hansen on 5/13/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//

import Foundation

class BestFit {
    /*
     //find best fit for smaller portfolio
     
     let thisAllocation = [15112, 19662, 31037, 20800, 26682, 18882, 12252, 15567, 19500, 18167, 22230, 26487, 30062, 27657]
     
     print("best fit")
     let thisFit = bestFit(initBalanceIRA: 75000, allocations: thisAllocation)
     print(thisFit)
     
     best fit
     [15567, 18167, 18882, 19500, 72116]
     
     is an array of components of IRA portfoio + Sum or Ira portfoio
     
     */
    
    
    func seachAllocation(startIndex: Int, initBalIRA: Int, allocation: [Int]) -> [Int] {
        
        let sortedAllocation = allocation.sorted{$0 < $1}
        
        var smallerAccount = [Int]()
        
        var smallerAccountSum = 0
        
        var finalSum = 0
        
        for ( index, item) in sortedAllocation.enumerated() {
            
            if index > startIndex {
                
                smallerAccountSum = smallerAccount.reduce(0) { $0 + $1 }
                
                if smallerAccountSum < initBalIRA {
                    
                    smallerAccount.append(item)
                  
                } else {
                    smallerAccount.removeLast()
                    break
                }
            }
        }
        
        finalSum = smallerAccount.reduce(0) { $0 + $1 }
        
        smallerAccount.append(finalSum)
        
        return smallerAccount
    }
    
    
    
    func bestFit(initBalanceIRA: Int, allocations: [Int])-> [Int] {
        
        var x = 0
        
        var allSollutions:[[Int]] = [[Int]]()
        
        while x < 7 {
            
            let thisSolution = seachAllocation(startIndex: x, initBalIRA: initBalanceIRA, allocation: allocations)
            
            allSollutions.append(thisSolution)
            
            x = x + 1
        }
        
        let sortedSolutions = allSollutions.sorted{$0.last! < $1.last!}
        
        let finalSolution = sortedSolutions.last!
        
        
        
        return finalSolution
    }
}
