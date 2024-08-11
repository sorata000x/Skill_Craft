//
//  ContentView.swift
//  Skill Craft
//
//  Created by Sora Izayoi on 8/9/24.
//

import Foundation

struct Task: Identifiable {
    let id = UUID()
    var title: String
    var isCompleted: Bool
}

import SwiftUI

class TaskViewModel: ObservableObject {
    @Published var tasks: [Task] = [
        Task(title: "Run for 1 mile", isCompleted: false),
        Task(title: "Clean up room", isCompleted: false),
        Task(title: "Review and reply to emails", isCompleted: false),
        Task(title: "Read 20 pages of a book", isCompleted: false),
        Task(title: "Review monthly budget", isCompleted: true),
    ]
}

import SwiftUI

struct TaskRow: View {
    @Binding var task: Task
    @StateObject private var viewModel = TaskViewModel() // Reference to ViewModel
    
    var body: some View {
        HStack {
            // Checkbox Button
            Button(action: {
                task.isCompleted.toggle()
            }) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24)) // Set size of checkbox
                    .foregroundColor(task.isCompleted ? .blue : .gray)
            }
            .buttonStyle(PlainButtonStyle()) // Disable button's default style to avoid background highlight
            
            // Task Title
            Text(task.title)
                .strikethrough(task.isCompleted)
                .foregroundColor(task.isCompleted ? .gray : .primary)
            
            Spacer()
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle()) // Make the entire row tappable for selection purposes, but not affecting the checkbox
        .swipeActions(edge: .trailing) { // Add swipe actions
            Button(role: .destructive) {
                if let index = viewModel.tasks.firstIndex(where: { $0.id == task.id }) {
                    viewModel.tasks.remove(at: index)
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}


struct CustomProgressBar: View {
    var value: Double
    var height: CGFloat

    var body: some View {
        ZStack(alignment: .leading) {
            // Background
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: height)
            
            // Progress
            Rectangle()
                .fill(Color.blue)
                .frame(width: CGFloat(value) * 200, height: height) // 200 is a placeholder width; adjust accordingly
        }
    }
}

// Item page
struct ItemRow: View {
    var item: String
    var exp: String
    var level: String
    var progressValue: Double
    @StateObject private var viewModel = TaskViewModel() // Reference to ViewModel
    
    var body: some View {
        HStack {
            // Left Image (placeholder for now)
            Image(systemName: "square.fill")
                .resizable()
                .frame(width: 64, height: 64)
                .background(Color.gray)
            
            VStack(alignment: .leading, spacing: 5) {
                // Item Title
                Text(item)
                    .font(.headline)
                
                // Custom Progress Bar
                CustomProgressBar(value: progressValue, height: 10)
                
                // EXP and Level
                HStack {
                    Text(exp)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Text(level)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            
        }
        .background(Color(UIColor.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
        .padding(.vertical, 0)
        .contentShape(Rectangle())
        .swipeActions(edge: .trailing) { // Add swipe actions
            Button(role: .destructive) {
                // Implement deletion action here, if using TaskViewModel or other data source
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}


struct CongratulationCard: View {
    var body: some View {
        Text("Congratulations for completing the task!")
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
            .padding(.horizontal, 20)
    }
}


import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TaskViewModel()
    @State private var isAddingTask = false // State to toggle between button and input
    @State private var newTaskTitle = "" // State to store the new task name
    @State private var selectedTab = 1
    @State private var showCongratulationCards = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // First Tab - To-Do List
            todoPage
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("To-Do")
                }
                .tag(0)
            
            // Second Tab - Empty Page
            items
                .tabItem {
                    Image(selectedTab == 1 ? "skill_icon_selected" : "skill_icon")
                        .renderingMode(.original)
                    Text("Skills")
                }
                .tag(1)
        }
        .overlay(
                ZStack {
                    if showCongratulationCards {
                        VStack(spacing: 10) {
                            CongratulationCard()
                            CongratulationCard()
                            CongratulationCard()
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .animation(.easeInOut(duration: 0.5), value: showCongratulationCards)
                    }
                }
                .padding(.bottom, isAddingTask ? 70 : 40), // Adjust according to the height of the "Add a Task" button
                alignment: .bottom
            )
    }
    
    // To-Do Page
    private var todoPage: some View {
        NavigationView {
            VStack {
                List {
                    // To Do Section
                    Section(header: Text("To Do")
                                .font(.largeTitle)
                                .bold()
                                .textCase(nil)) {
                        ForEach($viewModel.tasks.filter { !$0.isCompleted.wrappedValue }) { $task in
                            TaskRow(task: $task)
                        }
                    }
                    
                    // Completed Section
                    Section(header: HStack {
                        Text("Completed")
                            .font(.headline)
                            .textCase(nil) // Disable automatic capitalization
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(.blue)
                    }) {
                        ForEach($viewModel.tasks.filter { $0.isCompleted.wrappedValue }) { $task in
                            TaskRow(task: $task)
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .listRowSpacing(6.0)
                
                if isAddingTask {
                    // Custom TextField for adding a new task
                    TextField("Enter task name", text: $newTaskTitle, onCommit: addTask)
                        .padding(.vertical, 12) // Increase vertical padding
                        .padding(.horizontal, 20) // Increase horizontal padding
                        .background(Color(UIColor.systemGray6)) // Use a light background color
                        .cornerRadius(10) // Rounded corners
                        .font(.system(size: 18)) // Set a larger font size
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)
                        .onTapGesture {
                            // Prevent TextField from being dismissed when tapping inside it
                        }
                        .onDisappear {
                            // Clear the input when the TextField disappears
                            newTaskTitle = ""
                        }
                } else {
                    // "+ Add a Task" Button
                    Button(action: {
                        isAddingTask = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add a Task")
                                .fontWeight(.medium)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading) // Match task tab width and align left
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(10)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                }
            }
            .navigationBarTitle("Lists", displayMode: .inline)
            .background( // Adding a background tap handler
                Color.clear.onTapGesture {
                    // Dismiss the TextField and return to "+ Add a Task" button if tapped outside
                    if isAddingTask {
                        isAddingTask = false
                        newTaskTitle = ""
                    }
                }
            )
        }
    }
    
    // Items Page (replacing emptyPage)
    private var items: some View {
        
        NavigationView {
            List {
                Section {
                    ItemRow(item: "Item 1", exp: "1,234 / 5,230 EXP", level: "LV. 43", progressValue: 0.5)
                    ItemRow(item: "Item 2", exp: "1,234 / 5,230 EXP", level: "LV. 43", progressValue: 0.6)
                    ItemRow(item: "Item 3", exp: "1,234 / 5,230 EXP", level: "LV. 43", progressValue: 0.7)
                }.listRowInsets(.init()) // remove insets
                // Add more rows as needed
            }
            .listStyle(PlainListStyle()) // Or any other style that suits your design
            .listRowSpacing(8)
            .listRowInsets(EdgeInsets())
            .padding(5)
            .navigationBarTitle("Items", displayMode: .inline)
        }
    }
    
    
    private func addTask() {
        // Add the new task to the list
        if !newTaskTitle.isEmpty {
            viewModel.tasks.append(Task(title: newTaskTitle, isCompleted: false))
        }
        // Reset the state
        newTaskTitle = ""
        isAddingTask = false
    }
}

#Preview {
    ContentView()
}
