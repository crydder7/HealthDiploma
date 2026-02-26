import Foundation
import FirebaseAuth
internal import Combine
import FirebaseFirestore

class AuthViewModel: ObservableObject {
    
    @Published var user: User?
    @Published var errorMessage: String?
    
    init() {
        self.user = Auth.auth().currentUser
    }
    
    
    func signUp(email: String, password: String, registrationData: PatientRegistrationData) async throws {
        let result = try await Auth.auth()
            .createUser(withEmail: email, password: password)
        
        let uid = result.user.uid
        let db = Firestore.firestore()
        
        try await db.collection("users")
            .document(uid)
            .setData([
                "name": registrationData.name,
                "surname": registrationData.surname,
                "thirdname": registrationData.thirdname,
                "email": email,
                "phone": registrationData.phone,
                "role": "patient"
            ])
        
        try await db.collection("patientsData")
            .document(uid)
            .setData([
                "birthday": Timestamp(date: registrationData.birthday),
                "gender": registrationData.gender
            ])
        
        try await result.user.sendEmailVerification()
    }
    
    func signIn(email: String, password: String) async throws -> AppUser {
        
        let result = try await Auth.auth()
            .signIn(withEmail: email, password: password)
        
        let user = result.user
        
        guard user.isEmailVerified else {
            try Auth.auth().signOut()
            throw NSError(
                domain: "",
                code: 401,
                userInfo: [NSLocalizedDescriptionKey: "Подтвердите email"]
            )
        }
        
        let db = Firestore.firestore()
        
        let snapshot = try await db.collection("users")
            .document(user.uid)
            .getDocument()
        
        guard let data = snapshot.data(),
              let roleString = data["role"] as? String,
              let role = UserRole(rawValue: roleString)
        else {
            throw NSError(domain: "", code: 404)
        }
        
        return AppUser(
            id: user.uid,
            name: (data["name"] as? String)!,
            surname: (data["surname"] as? String)!,
            thirdname: (data["thirdname"] as? String)!,
            phone: (data["phone"] as? String)!,
            email: user.email!,
            role: role
        )
    }
    
    func signOut() {
        try? Auth.auth().signOut()
        self.user = nil
    }
}


class PatientViewModel: ObservableObject{
    @Published var user: AppUser
    
    init?(user: AppUser?) {
        
        guard let user = user else { return nil}
        self.user = user
    }
    
    func getAge() async throws -> Int {
        let db = Firestore.firestore()
        let snapshot = try await db.collection("patientsData")
            .document(user.id)
            .getDocument()
        
        guard let data = snapshot.data(),
              let birthday = data["birthday"] as? Timestamp
        else {
            throw NSError(domain: "", code: 404)
        }

        let birthDate = birthday.dateValue()
        let now = Date()
        let calendar = Calendar.current
        let age = calendar.dateComponents([.year], from: birthDate, to: now).year ?? 0
        return max(0, age)
    }
}
