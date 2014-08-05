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
    lazy var managedObjectModel: NSManagedObjectModel? = {
        var modelPath = NSBundle.mainBundle().pathForResource("CoreDataDemo", ofType: "momd")
        var modelURL = NSURL.fileURLWithPath(modelPath)
        var model = NSManagedObjectModel(contentsOfURL: modelURL)
        
        return model
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        var documentsDirectory = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as String
        var storeURL = NSURL(fileURLWithPath: documentsDirectory.stringByAppendingPathComponent("CoreDataDemo.sqlite"))
        var options = [NSInferMappingModelAutomaticallyOption: true, NSMigratePersistentStoresAutomaticallyOption: true]
        var error: NSError?
        
        var model = self.managedObjectModel
        var psc: NSPersistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        var ps = psc.addPersistentStoreWithType(NSSQLiteStoreType, configuration:nil, URL: storeURL, options: options, error: &error)
        
        if (ps == nil) {
            NSLog("Error opening the database. \(error)\nDeleting the file and trying again")
            abort()
        }
        
        return psc
    }()
    
    lazy var rootContext: NSManagedObjectContext = {
        var context: NSManagedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        context.persistentStoreCoordinator = self.persistentStoreCoordinator
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return context
    }()
    
    lazy var mainContext: NSManagedObjectContext = {
        var context: NSManagedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        context.parentContext = self.rootContext
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return context
    }()

    init() {
        
    }
    
    func newDerivedContext() -> NSManagedObjectContext {
        var context: NSManagedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        context.parentContext = self.mainContext
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return context
    }

    func saveContext(context: NSManagedObjectContext) {
        if context.parentContext == self.mainContext {
            saveDerivedContext(context)
            return
        }
        
        
    }
    
    func saveDerivedContext(context: NSManagedObjectContext) {
        
    }
    
}

var contextManagerSharedInstance: ContextManager!
