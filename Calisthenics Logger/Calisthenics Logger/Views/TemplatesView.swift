//
//  TemplatesView.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 27.09.23.
//

import SwiftUI

struct TemplatesView: View {
    @State private var selectedTab = "Workouts"

    private let userId: String
    
    init(userId: String) {
        self.userId = userId
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("", selection: $selectedTab) {
                    Text("Workouts").tag("Workouts")
                    Text("Exercises").tag("Exercises")
                    Text("Meta Data").tag("Meta Data")
                }
                .pickerStyle(SegmentedPickerStyle())
                
                if selectedTab == "Workouts" {
                    WorkoutTemplatesView(userId: userId)
                }
                if selectedTab == "Exercises" {
                    ExerciseTemplatesView(userId: userId)
                }
                if selectedTab == "Meta Data" {
                    MetaDateTemplatesView(userId: userId)
                }
                
                Spacer()
            }
            .navigationTitle("Templates")
        }
    }
}

#Preview {
    TemplatesView(
        userId: "kHldraThHdSyYWPAEeiu7Wkhm1y1"
    )
}
