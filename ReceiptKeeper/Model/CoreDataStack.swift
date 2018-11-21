//
//  CoreDataStack.swift
//  ReceiptKeeper
//
//  Created by Perez Willie Nwobu on 11/5/18.
//  Copyright © 2018 Perez Willie Nwobu. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    
    static let shared = CoreDataStack()
    lazy var container : NSPersistentContainer = {
       let container = NSPersistentContainer(name: "ReceiptKeeper")
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error {
                fatalError("Failed to load persistent store : \(error)")
            }
        })
        return container
    }()
    
    var mainContext : NSManagedObjectContext {
        return container.viewContext
    }
}
