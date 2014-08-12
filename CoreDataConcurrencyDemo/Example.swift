import Foundation
import CoreData

public class Example: NSManagedObject {

    @NSManaged public var name: String
    @NSManaged public var date: NSDate
    @NSManaged public var count: NSNumber

}
