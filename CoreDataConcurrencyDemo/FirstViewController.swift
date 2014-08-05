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
                            
    override func viewDidLoad() {
        super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "mainContextDidSave:", name: NSManagedObjectContextDidSaveNotification, object: contextManagerSharedInstance.mainContext)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "backgroundContextDidSave:", name: NSManagedObjectContextDidSaveNotification, object: contextManagerSharedInstance.rootContext)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapMainButton(sender: UIButton) {
        resetButtons()
        
        let when = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC) / 2)
        dispatch_after(when, dispatch_get_main_queue()) {
            var context = contextManagerSharedInstance.mainContext
            context.performBlock() {
                var entity: AnyObject = NSEntityDescription.insertNewObjectForEntityForName("TestEntity", inManagedObjectContext: context)
                
                self.saveContext(context)
            }
        }
    }
    
    @IBAction func didTapBackgroundButton(sender: UIButton) {
        resetButtons()
        
        let when = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC) / 2)
        dispatch_after(when, dispatch_get_main_queue()) {
            var context = contextManagerSharedInstance.rootContext
            context.performBlock() {
                var entity: AnyObject = NSEntityDescription.insertNewObjectForEntityForName("TestEntity", inManagedObjectContext: context)
                
                self.saveContext(context)
            }
        }
    }
    
    @IBAction func didTapWorkerButton(sender: UIButton) {
        resetButtons()

        let when = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC) / 2)
        dispatch_after(when, dispatch_get_main_queue()) {
            var context = contextManagerSharedInstance.newDerivedContext()
            context.performBlock() {
                var entity: AnyObject = NSEntityDescription.insertNewObjectForEntityForName("TestEntity", inManagedObjectContext: context)
                
                self.saveContext(context)
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
            var context = contextManagerSharedInstance.rootContext
            context.performBlock() {
                context.processPendingChanges()
                self.saveContext(context)
            }
        }
    }
    
    func backgroundContextDidSave(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue()) {
            self.backgroundLabel!.backgroundColor = UIColor.greenColor()
        }
    }
    

    func saveContext(context: NSManagedObjectContext) {
        context.performBlock() {
            var error: NSError?
            if(!context.obtainPermanentIDsForObjects(context.insertedObjects.allObjects, error: &error)) {
                NSLog("Error obtaining permanent object IDs for \(context.insertedObjects.allObjects), \(error)")
            }
            
            if(!context.save(&error)) {
                NSLog("Unresolved core data error\n\(error)")
                abort()
            }
        }
    }
}

