import UIKit
import XCTest
import CoreData
import CoreDataConcurrencyDemo

class CoreDataConcurrencyDemoTests: XCTestCase {
    var coreDataStack: CoreDataStack?
  
    override func setUp() {
        super.setUp()
        coreDataStack = TestCoreDataStack()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testRootSaveWhenMainSaves() {
        var handler: XCNotificationExpectationHandler = {
            notification in
            
            return true
        }
        
        var expectRoot:XCTestExpectation = self.expectationForNotification(NSManagedObjectContextDidSaveNotification, object: coreDataStack!.rootContext, handler: handler)
        
        coreDataStack!.saveContext(coreDataStack!.mainContext!)
        
        self.waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    func testMainSaveThenRootSaveWhenDerivedSaves() {
        var handler: XCNotificationExpectationHandler = {
            notification in
            
            return true
        }
        
        var expectMain = self.expectationForNotification(NSManagedObjectContextDidSaveNotification, object: coreDataStack!.mainContext, handler: handler)
        var expectRoot = self.expectationForNotification(NSManagedObjectContextDidSaveNotification, object: coreDataStack!.rootContext, handler: handler)
        
        let derivedContext = coreDataStack!.newDerivedContext()
        coreDataStack!.saveDerivedContext(derivedContext)
        
        self.waitForExpectationsWithTimeout(2.0, handler: nil)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            self.coreDataStack!.saveContext(self.coreDataStack!.mainContext!)
        }
        
        self
    }
    
}
