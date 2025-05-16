//
//  teleprompterXApp.swift
//  teleprompterX
//
//  Created by Fausto César Reyes on 16/05/25.
//

import SwiftUI
import CoreData

@main
struct TeleprompterXApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            let repo = CoreDataDocumentRepository(
                context: persistenceController.container.viewContext
            )
            DocumentListView(repository: repo)
                .environment(
                    \.managedObjectContext,
                    persistenceController.container.viewContext
                )
        }
    }
}


