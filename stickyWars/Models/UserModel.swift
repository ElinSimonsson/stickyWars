//
//  ProfileViewModel.swift
//  stickyWars
//
//  Created by josefin hellgren on 2023-02-21.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth



class UserModel: ObservableObject {
    
    static let shared = UserModel()
    @Published var user: User?
    @Published var userIsLoggedIn = false
    
    private var db = Firestore.firestore()
    
    func fetchUserData() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("UserInfo").document(userId).getDocument { (snapshot, error) in
            guard let snapshot = snapshot, snapshot.exists, let data = snapshot.data() else {
                print("Error fetching user data: \(error?.localizedDescription ?? "unknown error")")
                return
            }
            
            let user = User (
                name: data["name"] as? String ?? "",
                email: data["email"] as? String ?? "",
                score : data["score"] as? Int ?? 0
            )
            self.user = user
        }
    }
    
    func updateScore() {
        guard let currentUser = Auth.auth().currentUser?.uid else {
            return
        }
        
        if let user = user {
            let newScore = user.score + 1
            db.collection("UserInfo").document(currentUser).updateData(["score": newScore]) { error in
                if let error = error {
                    print("Error updating user score: \(error.localizedDescription)")
                }
            }
        }
    }
    
        func signUp(email: String, password: String, nickName : String){
    
            Auth.auth().createUser(withEmail: email, password: password) {authresult, error in
    
                if (authresult?.user.uid != nil){
                    self.userIsLoggedIn.toggle()
                    let currentUser = Auth.auth().currentUser?.uid ?? ""
    
                    let user = User(name: nickName, email: email, score: 0)
                    try? self.db.collection("UserInfo").document(currentUser).setData(from: user)
                } else {
                    print("error with creating user")
                }
            }
        }
    
    func logIn (email : String , password : String) {
        
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            
            if error != nil {
                print(error?.localizedDescription ?? "")
            } else {
                self.fetchUserData()
                self.userIsLoggedIn.toggle()
            }
        }
    }
    
    func signOutUser() {
        let firebaseAuth = Auth.auth()
        
        do {
            try firebaseAuth.signOut()
            userIsLoggedIn = false
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    func toogleUserIsLoggedIn() {
        userIsLoggedIn.toggle()
    }
}




