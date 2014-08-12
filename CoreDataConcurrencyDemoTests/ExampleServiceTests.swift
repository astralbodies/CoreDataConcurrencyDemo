import UIKit
import XCTest
import CoreData
import CoreDataConcurrencyDemo

class ExampleServiceTests: XCTestCase {
    let contextManager: ContextManager = ContextManager()
    var exampleService: ExampleService?
    
    override func setUp() {
        super.setUp()

        exampleService = ExampleService(managedObjectContext: contextManager.mainContext!)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testGetExamplesNoData() {
        let examplesNone = exampleService!.getAllExamples()
        
        XCTAssertEqual(0, examplesNone.count, "There should be no examples")
    }

    func testGetExampleWithResults() {
        exampleService?.addExample("This Little Piggy", date: NSDate(), count: 12)
        exampleService?.addExample("Little Miss Muffet", date: NSDate(), count: 200)
        exampleService?.addExample("Three Blind Mice", date: NSDate(), count: 0)
        
        var handler: XCNotificationExpectationHandler = {
            notification in
            
            return true
        }

        let expectation = self.expectationForNotification(NSManagedObjectContextDidSaveNotification, object: contextManager.mainContext, handler: handler)
        
        contextManager.saveContext(contextManager.mainContext!)
        
        self.waitForExpectationsWithTimeout(2.0, handler: nil)
        
        let examplesThree = exampleService!.getAllExamples()
        
        XCTAssertEqual(3, examplesThree.count, "There should be three examples")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }

}
