//
//  TaskMasterWidgetBundle.swift
//  TaskMasterWidget
//
//  Created by Genki on 9/25/24.
//

import WidgetKit
import SwiftUI

@main
struct TaskMasterWidgetBundle: WidgetBundle {
    var body: some Widget {
        SimpleTaskMasterWidget()
        ComplexTaskMasterWidget()
    }
}
