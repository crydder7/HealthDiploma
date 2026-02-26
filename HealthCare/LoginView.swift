import SwiftUI

struct LoginView: View {
    @State var email: String = ""
    @State var password: String = ""
    var authVM: AuthViewModel = .init()
    @State var isLoggedIn: Bool = false
//    @State var patient: Patient?
    @State var user: AppUser?
    @State var patientVM: PatientViewModel?
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationStack{
            VStack{
                GlassEffectContainer{
//                    NavigationLink {
//                        RegisterView()
//                    } label: {
//                        Label("Doctor login", systemImage: "cross.fill")
//                    }
//                    .buttonStyle(.glass)
//                    .padding()
//                    .foregroundStyle(.blue)
//                    
//                    NavigationLink {
//                        RegisterView()
//                    } label: {
//                        Label("Patient login", systemImage: "person.fill")
//                    }
//                    .buttonStyle(.glass)
//                    .padding()
//                    .foregroundStyle(.blue)
                    TextField("Enter your email", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .padding()
                    SecureField("Enter your password", text: $password)
                        .textFieldStyle(.roundedBorder)
                        .padding()
                    
                    Button {
                        Task {
                            do{
                                try await user = authVM.signIn(email: email, password: password)
                                if let user {
                                    patientVM = PatientViewModel(user: user)
                                    isLoggedIn = true
                                }
                            } catch{
                                
                            }
                           
                        }
                    
                    } label: {
                        Text("Login")
                    }
                    .buttonStyle(.glass)
                    .padding()
                    
                    
                    NavigationLink(isActive: $isLoggedIn) {
                        if let patientVM {
                            MainView(patient: patientVM)
                        } else {
                            EmptyView()
                        }
                    } label: {
                        EmptyView()
                    }

                    NavigationLink{
                        RegisterView()
                    } label: {
                        Label("Sign up for patient", systemImage: "")
                    }
                    .buttonStyle(.glass)
                    .padding()
                }
            }
            .padding()
        }
    }
}

#Preview {
    LoginView()
}
