//
//  Skill_CraftApp.swift
//  Skill Craft
//
//  Created by Sora Izayoi on 8/10/24.
//

import SwiftUI
import Firebase

@main
struct Skill_CraftApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
        }
    }
}
