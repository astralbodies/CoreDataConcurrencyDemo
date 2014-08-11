import UIKit
import XCTest
import CoreData
import CoreDataConcurrencyDemo

class ExampleServiceTests: XCTestCase {
    var exampleService: ExampleService?
    
    override func setUp() {
        super.setUp()

        exampleService = ExampleService(contextManager: ContextManager())
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
        exampleService?.addExample("This Little Piggy", date: NSDate(), count: 12)
        exampleService?.addExample("Little Miss Muffet", date: NSDate(), count: 200)
        exampleService?.addExample("Three Blind Mice", date: NSDate(), count: 0)
        
        let examples = exampleService!.getAllExamples()
        
        XCTAssertEqual(3, examples.count, "There should be three examples")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }

}
