//
//  Receipt+Convenience.swift
//  ReceiptKeeper
//
//  Created by Perez Willie Nwobu on 11/5/18.
//  Copyright © 2018 Perez Willie Nwobu. All rights reserved.
//

import Foundation
import CoreData

extension Receipt {
    convenience init(name : String, notes : String? = nil , imageData : Data? = nil, managedObjectContext : NSManagedObjectContext = CoreDataStack.shared.mainContext){
        
        self.init(context: managedObjectContext)
        
        self.name = name
        self.notes = notes
        self.imageData = imageData
    }
}
