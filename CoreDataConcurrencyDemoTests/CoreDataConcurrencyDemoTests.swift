//
//  CoreDataConcurrencyDemoTests.swift
//  CoreDataConcurrencyDemoTests
//
//  Created by Aaron Douglas on 8/3/14.
//  Copyright (c) 2014 Automattic Inc. All rights reserved.
//

import UIKit
import XCTest
import CoreData
import CoreDataConcurrencyDemo

class CoreDataConcurrencyDemoTests: XCTestCase {
//    let contextManager: Conte
    var contextManager: ContextManager = ContextManager()
  
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        var handler: XCNotificationExpectationHandler = {
            notification in
            
            return true
        }
        
        var expectRoot = self.expectationForNotification(NSManagedObjectContextDidSaveNotification, object: contextManager.rootContext, handler: handler)
        // This is an example of a functional test case.
        
        contextManager.saveContext(contextManager.mainContext!)
        
        self.waitForExpectationsWithTimeout(2, handler: nil)
        XCTAssert(true, "Pass")
    }
    
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measureBlock() {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
}
