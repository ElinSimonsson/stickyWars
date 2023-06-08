//
//  LoginView.swift
//  stickyWars
//
//  Created by Elin Simonsson on 2023-06-05.
//

import SwiftUI

struct LoginView: View {
    @State var email = ""
    @State var password = ""
    @ObservedObject var userModel: UserModel = .shared
    @State var showSignUpView = false
    
    
    var body: some View {
        
        ZStack{
            LinearGradient(colors: [Color.purple.opacity(0.5) , Color.yellow.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Image("globform")
                    .resizable()
                    .scaledToFit()
                
                TextField("email", text: $email)
                    .padding(15.0)
                    .background(RoundedRectangle(cornerRadius: 4.0, style: .continuous)
                        .stroke(.black, lineWidth: 2.0)
                        .shadow(radius: 20)
                        .background(.white)
                    )
                    .padding()
                
                SecureField("password", text: $password)
                    .padding(15.0)
                    .background(RoundedRectangle(cornerRadius: 4.0, style: .continuous)
                        .stroke(.black, lineWidth: 2.0)
                        .shadow(radius: 20)
                        .background(.white)
                    )
                    .padding()
                
                Button(action: {
                    userModel.logIn(email: email, password: password)}){
                        Text("Login")
                    }.background(RoundedRectangle(cornerRadius: 5.0,style: .continuous) .fill(LinearGradient(colors: [.white,.white], startPoint: .top, endPoint: .bottomTrailing)).frame(width: 70, height: 30, alignment: .center))
                    .foregroundColor(.black)
                
                HStack{
                    Text("Not yet signed up? ")
                    
                        .foregroundColor(.white)
                    Button(action: {showSignUpView = true}){
                        Text("Sign Up")
                    }
                    .foregroundColor(.white)
                    .padding()
                    .sheet(isPresented: $showSignUpView, content: {
                        SignUpView()
                    })
                }
            }
        }
    }
}
