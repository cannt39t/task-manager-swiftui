//
//  ToDoListApp.swift
//  ToDoList
//
//  Created by Илья Казначеев on 04.06.2023.
//

import SwiftUI

@main
struct ToDoListApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
