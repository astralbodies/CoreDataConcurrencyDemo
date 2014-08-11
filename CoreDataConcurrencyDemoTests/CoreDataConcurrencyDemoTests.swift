import UIKit
import XCTest
import CoreData
import CoreDataConcurrencyDemo

class CoreDataConcurrencyDemoTests: XCTestCase {
    var contextManager: ContextManager?
  
    override func setUp() {
        super.setUp()
        contextManager = TestContextManager()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testRootSaveWhenMainSaves() {
        var handler: XCNotificationExpectationHandler = {
            notification in
            
            return true
        }
        
        var expectRoot = self.expectationForNotification(NSManagedObjectContextDidSaveNotification, object: contextManager!.rootContext, handler: handler)
        
        contextManager!.saveContext(contextManager!.mainContext!)
        
        self.waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    func testMainSaveThenRootSaveWhenDerivedSaves() {
        var handler: XCNotificationExpectationHandler = {
            notification in
            
            return true
        }
        
        var expectMain = self.expectationForNotification(NSManagedObjectContextDidSaveNotification, object: contextManager!.mainContext, handler: handler)
        var expectRoot = self.expectationForNotification(NSManagedObjectContextDidSaveNotification, object: contextManager!.rootContext, handler: handler)
        
        let derivedContext = contextManager!.newDerivedContext()
        contextManager!.saveDerivedContext(derivedContext)
        
        self.waitForExpectationsWithTimeout(2.0, handler: nil)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            self.contextManager!.saveContext(self.contextManager!.mainContext!)
        }
        
        self
    }
    
}
