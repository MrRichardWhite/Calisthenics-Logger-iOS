//
//  ProfileView.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 27.09.23.
//

import SwiftUI

struct ProfileView: View {
    @StateObject var viewModel = ProfileViewViewModel()
    
    init() {}

    var body: some View {
        NavigationView {
            VStack {
                if let user = viewModel.user {
                    profile(user: user)
                } else {
                    Text("Loading Profile ...")
                }
                
            }
            .navigationTitle("Profile")
        }
        .onAppear {
            viewModel.fetchUser()
        }
    }
    
    @ViewBuilder
    func profile(user: User) -> some View {
        Spacer()
        
        Image(systemName: "person.circle")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(Color.blue)
            .frame(width: 125, height: 125)
            .padding()
        
        let memberSince = Date(timeIntervalSince1970: user.joined)
            .formatted(date: .abbreviated, time: .shortened)
        
        Form {
            infoField(title: "Full Name", content: user.name)
            infoField(title: "Athlete Name", content: user.athleteName)
            infoField(title: "Email", content: user.email)
            infoField(title: "Member Since", content: "\(memberSince)")
            
            CLButton(title: "Log Out", background: .red) {
                viewModel.logOut()
            }
            .padding()
        }
        
        Spacer()
    }
    
    @ViewBuilder
    func infoField(title: String, content: String) -> some View {
        VStack {
            HStack {
                Text(title)
                    .bold()
                Spacer()
            }
            HStack {
                Spacer()
                Text(content)
            }
        }
    }
}

#Preview {
    ProfileView()
}
