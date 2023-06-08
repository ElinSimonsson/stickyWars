//
//  ContentView.swift
//  stickyWars
//
//  Created by josefin hellgren on 2023-01-10.
//

import SwiftUI
import FirebaseAuth

struct StartView : View {
    @ObservedObject var userModel: UserModel = .shared
    
    var body: some View {
        
        if userModel.userIsLoggedIn {
            MainView()
        } else {
            LoginView()
                .onAppear() {
                    let currentUser = Auth.auth().currentUser
                    
                    if currentUser != nil {
                        userModel.toogleUserIsLoggedIn()
                    }
                }
        }
    }
}




