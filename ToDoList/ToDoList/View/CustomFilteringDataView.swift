//
//  CustomFilteringDataView.swift
//  ToDoList
//
//  Created by Илья Казначеев on 04.06.2023.
//

import SwiftUI

struct CustomFilteringDataView<Content: View>: View {
    
    var content: ([Task], [Task]) -> Content
    
    @FetchRequest private var result: FetchedResults<Task>
    @Binding private var filterDate: Date
    
    init(filterDate: Binding<Date>, @ViewBuilder content: @escaping ([Task], [Task]) -> Content) {
        self.content = content
        self._filterDate = filterDate
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: filterDate.wrappedValue)
        let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: startOfDay)!
        let predicate = NSPredicate(format: "date >= %@ AND date <= %@", argumentArray: [startOfDay, endOfDay])
        _result = FetchRequest(
            entity: Task.entity(),
            sortDescriptors: [
                NSSortDescriptor(keyPath: \Task.date, ascending: false)
            ],
            predicate: predicate,
            animation: .easeInOut
        )
    }
    
    var body: some View {
        content(separateTasks().0, separateTasks().1)
            .onChange(of: filterDate) { newValue in
                result.nsPredicate = nil
                
                let calendar = Calendar.current
                let startOfDay = calendar.startOfDay(for: newValue)
                let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: startOfDay)!
                let predicate = NSPredicate(format: "date >= %@ AND date <= %@", argumentArray: [startOfDay, endOfDay])
                
                result.nsPredicate = predicate
            }
    }
    
    func separateTasks() -> ([Task], [Task]) {
        let pending = result.filter( { !$0.isCompleted } )
        let completed = result.filter( { $0.isCompleted } )
        return (pending, completed)
    }
}
