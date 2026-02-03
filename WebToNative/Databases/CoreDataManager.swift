//
//  CoreDataManager.swift
//  WebToNative
//
//  Created by Akash Kamati on 28/05/24.
//  Copyright © 2024 WebToNative. All rights reserved.
//

import Foundation
import CoreData

/**
 Manages the Core Data stack for the application, including data persistence and context management.
 */
class CoreDataManager {

    // MARK: - Properties
    /// The name of the Core Data model.
    private let modelName: String
    /// The private queue context used for writing operations.
    private let writeContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    /// The main context associated with the persistent store container.
    lazy var mainContext: NSManagedObjectContext = {
        return self.storeContainer.viewContext
    }()
    
    /// The persistent store container that encapsulates the Core Data stack.
    public lazy var storeContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: self.modelName)
        container.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("Unresolved error \(error), \(error.localizedDescription)")
            }
        }
        return container
    }()

    // MARK: - Initializers
    /**
      Initializes the Core Data manager with the specified model name.
      
      - Parameter modelName: The name of the Core Data model to be managed.
      */
    init(modelName: String) {
        self.modelName = modelName
        self.writeContext.persistentStoreCoordinator = storeContainer.persistentStoreCoordinator
    }
    
    // MARK: - Public methods
    
       /**
        Saves changes made in the main context to the persistent store.
        */
    func saveContext () {
        guard mainContext.hasChanges else { return }
        
        do {
            try mainContext.save()
        } catch let nserror as NSError {
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
      
    /**
        Creates a new derived background context for performing asynchronous operations.
        
        - Returns: A new background `NSManagedObjectContext` instance derived from the persistent store container.
        */
    func newDerivedContext() -> NSManagedObjectContext {
        let context = self.storeContainer.newBackgroundContext()
        return context
    }
    
}
