//
//  FirstViewController.swift
//  CoreDataConcurrencyDemo
//
//  Created by Aaron Douglas on 8/3/14.
//  Copyright (c) 2014 Automattic Inc. All rights reserved.
//

import UIKit
import CoreData

class FirstViewController: UIViewController {
    
    @IBOutlet var mainLabel: UILabel?
    @IBOutlet var backgroundLabel: UILabel?
    @IBOutlet var workerLabel: UILabel?
    @IBOutlet var textView: UITextView?
    var workerContext: NSManagedObjectContext?
                            
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.textView?.text = "Core Data stack initialized."

        self.workerContext = contextManagerSharedInstance.newDerivedContext()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "mainContextDidSave:", name: NSManagedObjectContextDidSaveNotification, object: contextManagerSharedInstance.mainContext)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "backgroundContextDidSave:", name: NSManagedObjectContextDidSaveNotification, object: contextManagerSharedInstance.rootContext)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "workerContextDidSave:", name: NSManagedObjectContextDidSaveNotification, object: self.workerContext)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapMainButton(sender: UIButton) {
        resetButtons()
        
        let when = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC) / 2)
        dispatch_after(when, dispatch_get_main_queue()) {
            var context = contextManagerSharedInstance.mainContext!
            context.performBlock() {
                var entity: AnyObject = NSEntityDescription.insertNewObjectForEntityForName("TestEntity", inManagedObjectContext: context)
                
                contextManagerSharedInstance.saveContext(context)
            }
        }
    }
    
    @IBAction func didTapBackgroundButton(sender: UIButton) {
        resetButtons()
        
        let when = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC) / 2)
        dispatch_after(when, dispatch_get_main_queue()) {
            var context = contextManagerSharedInstance.rootContext!
            context.performBlock() {
                var entity: AnyObject = NSEntityDescription.insertNewObjectForEntityForName("TestEntity", inManagedObjectContext: context)
                
                contextManagerSharedInstance.saveContext(context)
            }
        }
    }
    
    @IBAction func didTapWorkerButton(sender: UIButton) {
        resetButtons()

        let when = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC) / 2)
        dispatch_after(when, dispatch_get_main_queue()) {
            self.workerContext!.performBlock() {
                var entity: AnyObject = NSEntityDescription.insertNewObjectForEntityForName("TestEntity", inManagedObjectContext: self.workerContext)
                
                var error: NSError? = nil
                if !(self.workerContext!.obtainPermanentIDsForObjects(self.workerContext!.insertedObjects.allObjects, error: &error)) {
                    NSLog("Error obtaining permanent IDs for \(self.workerContext!.insertedObjects.allObjects), \(error)")
                }
                
                if !(self.workerContext!.save(&error)) {
                    NSLog("Unresolved core data error: \(error)")
                    abort()
                }
            }
        }
    }
    
    private func resetButtons() {
        mainLabel?.backgroundColor = UIColor.whiteColor()
        backgroundLabel?.backgroundColor = UIColor.whiteColor()
        workerLabel?.backgroundColor = UIColor.whiteColor()
    }
    
    func mainContextDidSave(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue()) {
            self.mainLabel!.backgroundColor = UIColor.greenColor()
        }
        
        let when = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC) / 2)
        dispatch_after(when, dispatch_get_main_queue()) {
            var context = contextManagerSharedInstance.rootContext!
            context.performBlock() {
                context.processPendingChanges()
                contextManagerSharedInstance.saveContext(context)
            }
        }
    }
    
    func backgroundContextDidSave(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue()) {
            self.backgroundLabel!.backgroundColor = UIColor.greenColor()
        }
    }
    
    func workerContextDidSave(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue()) {
            self.workerLabel!.backgroundColor = UIColor.greenColor()
        }

        
        let when = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC) / 2)
        dispatch_after(when, dispatch_get_main_queue()) {
            var context = contextManagerSharedInstance.mainContext!
            context.performBlock() {
                context.processPendingChanges()
                contextManagerSharedInstance.saveContext(context)
            }
        }
    }
}

