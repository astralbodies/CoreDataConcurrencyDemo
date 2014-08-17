import Foundation
import CoreData

public class ExampleService {
    var managedObjectContext: NSManagedObjectContext
    
    public init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
    }
    
    public func getAllExamples() -> Array<Example> {
        let fetchRequest = NSFetchRequest(entityName: "Example")
        
        return managedObjectContext.executeFetchRequest(fetchRequest, error: nil) as Array<Example>
    }
    
    public func addExample(name: String, date: NSDate, count: Int16) -> Example? {
        let example: Example = NSEntityDescription.insertNewObjectForEntityForName("Example", inManagedObjectContext: managedObjectContext) as Example
        example.name = name
        example.date = date
        example.count = NSNumber.numberWithShort(count)
        
        return example
    }
    
    public func getExample(name: String) -> Example? {
        let predicate: NSPredicate = NSPredicate(format: "name = %@", argumentArray: [name])
        let fetchRequest: NSFetchRequest = NSFetchRequest(entityName: "Example")
        fetchRequest.predicate = predicate
        
        var error: NSError?
        let results = managedObjectContext.executeFetchRequest(fetchRequest, error: &error) as Array<Example>
        
        if (error == nil && results.count > 0) {
            return results[0]
        }
        
        return nil
    }
}