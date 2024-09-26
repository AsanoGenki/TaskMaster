//
//  InlineNavigationBar.swift
//  TaskMaster
//
//  Created by Genki on 9/26/24.
//

import SwiftUI

extension View {
    func inlineNavigationBar() -> some View {
        #if os(macOS)
        self
        #else
        self.navigationBarTitleDisplayMode(.inline)
        #endif
    }
}
