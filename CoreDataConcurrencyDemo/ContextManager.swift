import Foundation
import CoreData

public class ContextManager {

    public init() {
        
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    public var managedObjectModel: NSManagedObjectModel = {
        var modelPath = NSBundle.mainBundle().pathForResource("CoreDataDemo", ofType: "momd")
        var modelURL = NSURL.fileURLWithPath(modelPath)
        var model = NSManagedObjectModel(contentsOfURL: modelURL)
        
        return model
    }()

    var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.automattic.TestCoreDataMasterDetail" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as NSURL
    }()

    public lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        NSLog("Providing SQLite persistent store coordinator")
        
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
    
    public lazy var rootContext: NSManagedObjectContext? = {
        var context: NSManagedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        context.persistentStoreCoordinator = self.persistentStoreCoordinator
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return context
    }()
    
    public lazy var mainContext: NSManagedObjectContext? = {
        var mainContext: NSManagedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
        mainContext.parentContext = self.rootContext
        mainContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "mainContextDidSave:", name: NSManagedObjectContextDidSaveNotification, object: mainContext)

        return mainContext
    }()

    public func newDerivedContext() -> NSManagedObjectContext {
        var context: NSManagedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        context.parentContext = self.mainContext
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return context
    }

    public func saveContext(context: NSManagedObjectContext) {
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
    
    public func saveDerivedContext(context: NSManagedObjectContext) {
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
            let when = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC) / 2)
            dispatch_after(when, dispatch_get_main_queue()) {
                self.saveContext(self.mainContext!)
            }
        }
    }

    @objc func mainContextDidSave(notification: NSNotification) {
        let when = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC) / 2)
        dispatch_after(when, dispatch_get_main_queue()) {
            self.saveContext(self.rootContext!)
        }
    }
    
}