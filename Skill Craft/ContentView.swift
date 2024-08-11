//
//  ContentView.swift
//  Skill Craft
//
//  Created by Sora Izayoi on 8/9/24.
//

import Foundation
import SwiftUI

// ========== GPT ===========

// Define the structure of the function call
struct GPTFunctionCall: Codable {
    let name: String
    let arguments: String
    
    func decodedArguments() -> [String: String]? {
        guard let data = arguments.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode([String: String].self, from: data)
    }
}

// Define the structure of the GPT response
struct GPTResponse: Codable {
    let choices: [Choice]

    struct Choice: Codable {
        let message: Message
        let functionCall: GPTFunctionCall?

        struct Message: Codable {
            let content: String?
            let function_call: GPTFunctionCall?
        }
    }
}

class GPTService {
    let apiKey = "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"
    
    func callGPTWithFunction(taskName: String, completion: @escaping (String?) -> Void) {
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        // Define the function details
        let functionDetails: [String: Any] = [
            "name": "generateCongratulationMessage",
            "description": "Inform user the skill they have leveld up.",
            "parameters": [
                "type": "object",
                "properties": [
                    "skill": [
                        "type": "string",
                        "description": "The name of the skill user level up by doing the task."
                    ]
                ],
                "required": ["skill"]
            ]
        ]

        // Define the messages
        let messages: [[String: String]] = [
            ["role": "system", "content": "For the task user has completed, find one skill that user level up from doing the task."],
            ["role": "user", "content": "The user has completed the task: \(taskName). Please call the function 'generateCongratulationMessage'."]
        ]

        // Now, combine them into the final body
        let body: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": messages,
            "functions": [functionDetails],
            "function_call": "auto" // Automatically call the function
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            do {
                let gptResponse = try JSONDecoder().decode(GPTResponse.self, from: data)
                if let functionCall = gptResponse.choices.first?.message.function_call {
                    let message = self.generateCongratulationMessage(from: functionCall)
                    completion(message)
                } else {
                    completion(nil)
                }
            } catch {
                completion(nil)
            }
        }
        
        task.resume()
    }
    
    // This function simulates the result of the function call
    func generateCongratulationMessage(from functionCall: GPTFunctionCall) -> String {
        guard let decodedArguments = functionCall.decodedArguments(),
              let skill = decodedArguments["skill"] else {
            return "Congratulations for completing the task!"
        }
        return "Leveled up skill: \(skill)"
    }
}


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
    var onTaskCompleted: () -> Void

    var body: some View {
        HStack {
            // Checkbox Button
            // action
            // - mark task completed
            // - onTaskCompleted()
            Button(
                action: {
                    task.isCompleted.toggle()
                    if task.isCompleted {
                        onTaskCompleted()
                    }
            }) {
                // Check box
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24)) // Size
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
        @State private var showCongratulationPopup = false // State to show the congratulation popup
        @State private var congratulationMessage = "Congratulations for completing the task!"
        
        let gptService = GPTService()

        var body: some View {
            ZStack {
                TabView(selection: $selectedTab) {
                    todoPage
                        .tabItem {
                            Image(systemName: "list.bullet")
                            Text("To-Do")
                        }
                        .tag(0)

                    items
                        .tabItem {
                            Image(systemName: "square.grid.2x2")
                            Text("Items")
                        }
                        .tag(1)
                }

                // Pop-Up Overlay
                if showCongratulationPopup {
                    VStack {
                        Spacer()
                        Text(congratulationMessage)
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
                            .transition(.opacity)
                            .padding(.bottom, 100)
                    }
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation {
                                showCongratulationPopup = false
                            }
                        }
                    }
                }
            }
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
                                TaskRow(task: $task, onTaskCompleted: {
                                    handleTaskCompletion(taskName: task.title)
                                })
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
                                TaskRow(task: $task, onTaskCompleted: {
                                    handleTaskCompletion(taskName: task.title)
                                })
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
    
    private func handleTaskCompletion(taskName: String) {
            gptService.callGPTWithFunction(taskName: taskName) { response in
                DispatchQueue.main.async {
                    if let response = response {
                        congratulationMessage = response
                    } else {
                        congratulationMessage = "Congratulations for completing the task!"
                    }
                    showPopup()
                }
            }
        }
    
    private func showPopup() {
        withAnimation {
            showCongratulationPopup = true
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
