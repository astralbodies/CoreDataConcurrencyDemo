import UIKit
import CoreData

class FirstViewController: UIViewController {
    
    let contextManager: ContextManager = ContextManager()
    @IBOutlet var mainLabel: UILabel?
    @IBOutlet var backgroundLabel: UILabel?
    @IBOutlet var workerLabel: UILabel?
    @IBOutlet var textView: UITextView?
    var workerContext: NSManagedObjectContext?
                            
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.textView?.text = "Core Data stack initialized."

        self.workerContext = contextManager.newDerivedContext()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "mainContextDidSave:", name: NSManagedObjectContextDidSaveNotification, object: contextManager.mainContext)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "backgroundContextDidSave:", name: NSManagedObjectContextDidSaveNotification, object: contextManager.rootContext)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "workerContextDidSave:", name: NSManagedObjectContextDidSaveNotification, object: self.workerContext)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapMainButton(sender: UIButton) {
        resetButtons()
        
        var text: String! = self.textView!.text
        text = text + "Added entity and saving main context."
        self.textView?.text = text
        
        let when = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC) / 2)
        dispatch_after(when, dispatch_get_main_queue()) {
            var context = self.contextManager.mainContext!
            context.performBlock() {
                var entity: AnyObject = NSEntityDescription.insertNewObjectForEntityForName("TestEntity", inManagedObjectContext: context)
                
                self.contextManager.saveContext(context)
            }
        }
    }
    
    @IBAction func didTapBackgroundButton(sender: UIButton) {
        resetButtons()
        
        var text: String! = self.textView!.text
        text = text + "Added entity and saving background context."
        self.textView?.text = text
        
        let when = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC) / 2)
        dispatch_after(when, dispatch_get_main_queue()) {
            var context = self.contextManager.rootContext!
            context.performBlock() {
                var entity: AnyObject = NSEntityDescription.insertNewObjectForEntityForName("TestEntity", inManagedObjectContext: context)
                
                self.contextManager.saveContext(context)
            }
        }
    }
    
    @IBAction func didTapWorkerButton(sender: UIButton) {
        resetButtons()
        
        var text: String! = self.textView!.text
        text = text + "Added entity and saving worker context."
        self.textView?.text = text
        
        let when = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC) / 2)
        dispatch_after(when, dispatch_get_main_queue()) {
            self.workerContext!.performBlock() {
                var entity: AnyObject = NSEntityDescription.insertNewObjectForEntityForName("TestEntity", inManagedObjectContext: self.workerContext)
                
                self.contextManager.saveDerivedContext(self.workerContext!)
            }
        }
    }
    
    private func resetButtons() {
        self.textView?.text = ""
        mainLabel?.backgroundColor = UIColor.whiteColor()
        backgroundLabel?.backgroundColor = UIColor.whiteColor()
        workerLabel?.backgroundColor = UIColor.whiteColor()
    }
    
    func mainContextDidSave(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue()) {
            var text: String! = self.textView!.text
            text = text + "\nMain Context saved."
            self.textView?.text = text
            
            self.mainLabel!.backgroundColor = UIColor.greenColor()
        }
    }
    
    func backgroundContextDidSave(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue()) {
            var text: String! = self.textView!.text
            text = text + "\nBackground Context saved."
            self.textView?.text = text
            
            self.backgroundLabel!.backgroundColor = UIColor.greenColor()
        }
    }
    
    func workerContextDidSave(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue()) {
            var text: String! = self.textView!.text
            text = text + "\nWorker Context saved."
            self.textView?.text = text
            
            self.workerLabel!.backgroundColor = UIColor.greenColor()
        }
    }
}

