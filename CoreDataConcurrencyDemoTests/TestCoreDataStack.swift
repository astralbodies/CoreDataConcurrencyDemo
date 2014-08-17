import CoreDataConcurrencyDemo
import Foundation
import CoreData

class TestCoreDataStack: CoreDataStack {
    override lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        NSLog("Providing in-memory persistent store coordinator")
        var options = [NSInferMappingModelAutomaticallyOption: true, NSMigratePersistentStoresAutomaticallyOption: true]
        var psc: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        var error: NSError? = nil

        var ps = psc!.addPersistentStoreWithType(NSInMemoryStoreType, configuration:nil, URL: nil, options: options, error: &error)
       
        if (ps == nil) {
            abort()
        }
        
        return psc
    }()

    override func saveDerivedContext(context: NSManagedObjectContext) {
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

