//
//  Home.swift
//  ToDoList
//
//  Created by Илья Казначеев on 04.06.2023.
//

import SwiftUI

struct Home: View {
    
    /// View properties
    @Environment(\.self) private var env
    @State private var filterDate: Date = .init()
    @State private var showPendingTasks: Bool = true
    @State private var showCompletedTasks: Bool = true
    
    
    var body: some View {
        List {
            DatePicker(selection: $filterDate, displayedComponents: [.date]) {
                
            }
            .labelsHidden()
            .datePickerStyle(.graphical)
            
            CustomFilteringDataView(filterDate: $filterDate) { pending, completed in
                DisclosureGroup(isExpanded: $showPendingTasks) {
                    if pending.isEmpty {
                        Text("No Task's Found")
                            .font(.caption)
                            .foregroundColor(.gray)
                    } else {
                        Group {
                            ForEach(pending) {
                                TaskRow(task: $0, isPending: true)
                            }
                        }
                    }
                } label: {
                    Text("Pending Task's \(pending.isEmpty ? "" : "\(pending.count)")")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                DisclosureGroup(isExpanded: $showCompletedTasks) {
                    if completed.isEmpty {
                        Text("No Task's Found")
                            .font(.caption)
                            .foregroundColor(.gray)
                    } else {
                        Group {
                            ForEach(completed) {
                                TaskRow(task: $0, isPending: false)
                            }
                        }
                    }
                } label: {
                    Text("Completed Task's \(completed.isEmpty ? "" : "\(completed.count)")")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button {
                    do {
                        let task = Task(context: env.managedObjectContext)
                        task.id = .init()
                        task.date = filterDate
                        task.isCompleted = false
                        task.title = ""
                        
                        try env.managedObjectContext.save()
                        showPendingTasks = true
                    } catch {
                        print(error.localizedDescription)
                    }
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                        Text("New Task")
                    }
                    .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


struct TaskRow: View {
    
    @ObservedObject var task: Task
    var isPending: Bool
    
    @Environment(\.self) private var env
    @FocusState private var showKeyboard: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Button {
                task.isCompleted.toggle()
                save()
            } label: {
                Image(systemName: !isPending ? "checkmark.circle.fill" : "circle")
                    .font(.title)
                    .foregroundColor(.blue)
            }
            .buttonStyle(.plain)
            VStack(alignment: .leading, spacing: 4) {
                TextField("Task Title", text: .init(get: {
                    return task.title ?? ""
                }, set: { value in
                    task.title = value
                }))
                .focused($showKeyboard)
                .onSubmit {
                    removingEmptyTask()
                    save()
                }
                .foregroundColor(isPending ? .primary : .gray)
                .strikethrough(!isPending, pattern: .solid, color: .primary)
                
                /// Custon datePicker
                Text((task.date ?? .init()).formatted(date: .omitted, time: .shortened))
                    .font(.callout)
                    .foregroundColor(.gray)
                    .overlay {
                        DatePicker(selection: .init(get: {
                            return task.date ?? .init()
                        }, set: { value in
                            task.date = value
                            
                            save()
                        }), displayedComponents: [.hourAndMinute]) {
                            
                        }
                        .labelsHidden()
                        .blendMode(.destinationOver)
                    }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .onDisappear {
            removingEmptyTask()
            save()
        }
        .onAppear {
            if (task.title ?? "").isEmpty {
                showKeyboard = true
            }
        }
        .onChange(of: env.scenePhase) { newValue in
            if newValue != .active {
                showKeyboard = false
                DispatchQueue.main.async {
                    removingEmptyTask()
                    save()
                }
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    env.managedObjectContext.delete(task)
                    save()
                }
            } label: {
                Image(systemName: "trash.fill")
            }
        }
    }
    
    func save() {
        do {
            try env.managedObjectContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func removingEmptyTask() {
        if (task.title ?? "").isEmpty {
            /// Removing empty task
            env.managedObjectContext.delete(task)
        }
    }
    
}
