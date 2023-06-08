//
//  LoginView.swift
//  stickyWars
//
//  Created by josefin hellgren on 2023-02-02.
//

import SwiftUI


struct SignUpView: View{
    @ObservedObject var userModel: UserModel = .shared
    @State var email : String = ""
    @State var nickName : String = ""
    @State var password : String = ""
    
    var body: some View{
        
        ZStack{
            LinearGradient(colors: [Color.green.opacity(0.5) , Color.brown.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            
            VStack{
                Image("soffanform")
                    .resizable()
                    .scaledToFit()
                Text("SIGN UP")
                    .foregroundColor(.white)
                    .font(.largeTitle)
                TextField("Nick name", text: $nickName)
                    .padding(15.0)
                    .background(RoundedRectangle(cornerRadius: 4.0, style: .continuous)
                        .stroke(.black, lineWidth: 2.0)
                        .shadow(radius: 20)
                        .background(.white)
                    )
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
                        .stroke(.black, lineWidth: 2.0).shadow(radius: 20)
                        .background(.white))
                    .padding()
                
                Button(action: {
                    userModel.signUp(email: email, password: password,nickName: nickName )
                }){
                    Text("signUp")
                }
                .background(RoundedRectangle(cornerRadius: 5.0,style: .continuous) .fill(LinearGradient(colors: [.white,.white], startPoint: .top, endPoint: .bottomTrailing)).frame(width: 70, height: 30, alignment: .center))
                .foregroundColor(.black.opacity(0.8))
            }
        }
    }
}


