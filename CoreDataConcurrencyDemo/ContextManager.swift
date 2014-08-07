//
//  ContextManager.swift
//  CoreDataConcurrencyDemo
//
//  Created by Aaron Douglas on 8/3/14.
//  Copyright (c) 2014 Automattic Inc. All rights reserved.
//

import Foundation
import CoreData

class ContextManager {

    init() {
        
    }
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        var modelPath = NSBundle.mainBundle().pathForResource("CoreDataDemo", ofType: "momd")
        var modelURL = NSURL.fileURLWithPath(modelPath)
        var model = NSManagedObjectModel(contentsOfURL: modelURL)
        
        return model
    }()

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.automattic.TestCoreDataMasterDetail" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as NSURL
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("CoreDataDemo.sqlite")
        var options = [NSInferMappingModelAutomaticallyOption: true, NSMigratePersistentStoresAutomaticallyOption: true]
        var error: NSError? = nil
        
        var psc: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        var ps = psc!.addPersistentStoreWithType(NSSQLiteStoreType, configuration:nil, URL: url, options: options, error: &error)
       
        if (ps == nil) {
            abort()
        }
        
        return psc
    }()
    
    lazy var rootContext: NSManagedObjectContext? = {
        var context: NSManagedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        context.persistentStoreCoordinator = self.persistentStoreCoordinator
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return context
    }()
    
    lazy var mainContext: NSManagedObjectContext? = {
        var mainContext: NSManagedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
        mainContext.parentContext = self.rootContext
        mainContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return mainContext
    }()

    func newDerivedContext() -> NSManagedObjectContext {
        var context: NSManagedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        context.parentContext = self.mainContext
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return context
    }

    func saveContext(context: NSManagedObjectContext) {
        if context.parentContext === self.mainContext {
            saveDerivedContext(context)
            return
        }
        
        context.performBlock() {
            var error: NSError? = nil
            if !(context.obtainPermanentIDsForObjects(context.insertedObjects.allObjects, error: &error)) {
                NSLog("Error obtaining permanent IDs for \(context.insertedObjects.allObjects), \(error)")
            }

            if !(context.save(&error)) {
                NSLog("Unresolved core data error: \(error)")
                abort()
            }
        }
    }
    
    func saveDerivedContext(context: NSManagedObjectContext) {
        context.performBlock() {
            var error: NSError? = nil
            if !(context.obtainPermanentIDsForObjects(context.insertedObjects.allObjects, error: &error)) {
                NSLog("Error obtaining permanent IDs for \(context.insertedObjects.allObjects), \(error)")
            }

            if !(context.save(&error)) {
                NSLog("Unresolved core data error: \(error)")
                abort()
            }

            // While this is needed because we don't observe change notifications for the derived context, it
            // breaks concurrency rules for Core Data.  Provide a mechanism to destroy a derived context that
            // unregisters it from the save notification instead and rely upon that for merging.
            self.saveContext(self.mainContext!)
        }
    }
    
}

var contextManagerSharedInstance: ContextManager!
