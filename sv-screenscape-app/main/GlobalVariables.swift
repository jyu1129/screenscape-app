//
//  GlobalVariables.swift
//  sv-screenscape-app
//
//  Created by Poh Shun Yu on 01/03/2024.
//

import Swinject
import CoreData

/// Dependency Injection Container
///
/// This container is used for managing dependencies and providing instances of registered types
let DIContainer = Container()

/// Access to CoreData managed object context from AppDelegate
var managedObjectContext: NSManagedObjectContext {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
        fatalError("Unable to access AppDelegate")
    }
    return appDelegate.managedObjectContext
}
