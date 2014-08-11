import Foundation
import CoreData

public class ExampleService {
    var contextManager: ContextManager
    
    public init(contextManager: ContextManager) {
        self.contextManager = contextManager
    }
    
    public func getAllExamples() -> Array<Example> {
        return Array<Example>()
    }
    
    public func addExample(name: String, date: NSDate, count: Int16) -> Example? {
        return nil
    }
    
    public func getExample(name: String) -> Example? {
        return nil
    }
}