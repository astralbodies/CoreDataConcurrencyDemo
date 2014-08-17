import UIKit
import XCTest
import CoreData
import CoreDataConcurrencyDemo

class ExampleServiceTests: XCTestCase {
    let coreDataStack: CoreDataStack = TestCoreDataStack()
    var exampleService: ExampleService?
    
    override func setUp() {
        super.setUp()

        exampleService = ExampleService(managedObjectContext: coreDataStack.mainContext!)
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

        let expectation = self.expectationForNotification(NSManagedObjectContextDidSaveNotification, object: coreDataStack.mainContext, handler: handler)
        
        coreDataStack.saveContext(coreDataStack.mainContext!)
        
        self.waitForExpectationsWithTimeout(2.0, handler: nil)
        
        let examplesThree = exampleService!.getAllExamples()
        
        XCTAssertEqual(3, examplesThree.count, "There should be three examples")
    }
    
    func testGetExampleWithName() {
        let example: Example? = exampleService!.getExample("Maple Bacon Yummies")
        
        XCTAssertNil(example, "There should be no Maple Bacon Yummies")
        
        let example2 = exampleService?.addExample("Maple Bacon Yummies", date: NSDate(), count: 1)
        coreDataStack.saveContext(coreDataStack.mainContext!)
        
        var example3: Example? = exampleService?.getExample("Maple Bacon Yummies")
        XCTAssertNotNil(example3, "There should now be a Maple Bacon Yummies")
        XCTAssertEqual("Maple Bacon Yummies", example3!.name, "Name should match")
    }
}
