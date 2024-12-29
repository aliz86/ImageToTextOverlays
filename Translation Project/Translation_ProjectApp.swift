//
//  Translation_ProjectApp.swift
//  Translation Project
//
//  Created by Ali on 12/29/24.
//

import SwiftUI

@main
struct Translation_ProjectApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
