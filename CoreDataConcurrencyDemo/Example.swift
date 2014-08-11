import Foundation
import CoreData

public class Example: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var date: NSDate
    @NSManaged var count: NSNumber

}
