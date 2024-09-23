//
//  TaskMasterTests.swift
//  TaskMasterTests
//
//  Created by Genki on 9/23/24.
//

import CoreData
import XCTest
@testable import TaskMaster

class BaseTestCase: XCTestCase {
    var dataController: DataController!
    var managedObjectContext: NSManagedObjectContext!
    override func setUpWithError() throws {
        dataController = DataController(inMemory: true)
        managedObjectContext = dataController.container.viewContext
    }
}
