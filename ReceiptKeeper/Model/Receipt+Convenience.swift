//
//  Receipt+Convenience.swift
//  ReceiptKeeper
//
//  Created by Perez Willie Nwobu on 11/5/18.
//  Copyright © 2018 Perez Willie Nwobu. All rights reserved.
//

import Foundation
import CoreData

enum ReceiptPriority : String , CaseIterable{
    case necessity, important, nonnecessity
}


extension Receipt {
    convenience init(name : String,
                     notes : String? = nil ,
                     imageData : Data? = nil,
                     date : Date = Date(),
                     
                     priority : ReceiptPriority? = nil,
                     managedObjectContext : NSManagedObjectContext = CoreDataStack.shared.mainContext){
        
        self.init(context: managedObjectContext)
        
        self.name = name
        self.notes = notes
        self.imageData = imageData
        self.date = date
    }
}
