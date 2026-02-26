import SwiftUI

struct RegisterView: View {
    private let phoneDigitsLimit = 11
    
    @State var name: String = ""
    @State var surname: String = ""
    @State var thirdname: String = ""
    @State var phoneNumber: String = ""
    @State var email: String = ""
    @State var birth: Date = Date()
    @State var gender: String = "Male"
    @State var password: String = ""
    @State var passwordConfirmation: String = ""
    @ObservedObject var authVM = AuthViewModel()
    @State var patient: PatientRegistrationData?
    
    private var isPhoneValid: Bool {
        phoneNumber.count == phoneDigitsLimit
    }
    
    var body: some View {
        VStack{
            Label("Patient sign up", systemImage: "cross.fill")
                .padding()
            GlassEffectContainer{
                TextField("Enter your name", text: $name)
                    .textFieldStyle(.roundedBorder)
                TextField("Enter your surname", text: $surname)
                    .textFieldStyle(.roundedBorder)
                TextField("Enter your thirdname", text: $thirdname)
                    .textFieldStyle(.roundedBorder)
                TextField("Enter your phone number", text: $phoneNumber)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
                    .onChange(of: phoneNumber) { newValue in
                        phoneNumber = sanitizePhoneNumber(newValue)
                    }
                TextField("Enter your e-mail adress", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                Picker("Gender", selection: $gender) {
                    Text("Male")
                    Text("Female")
                }
                .pickerStyle(.menu)
                DatePicker("Select your birthdate", selection: $birth, displayedComponents: .date)
                    .datePickerStyle(.compact)
                SecureField("Enter your password", text: $password)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.never)
                SecureField("Confirm your password", text: $passwordConfirmation)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.never)
                Button("Register") {
                    patient = PatientRegistrationData(name: name, surname: surname, thirdname: thirdname, birthday: birth, gender: gender, phone: phoneNumber)
                    Task{
                        do{
                            try await authVM.signUp(email: email, password: password, registrationData: patient!)
                        } catch{
                            
                        }
                    }
                }
                .disabled(!isPhoneValid)
                .buttonStyle(.glass)
                .padding()
            }
        }
        .padding()
    }
}

#Preview {
    RegisterView()
}

private func sanitizePhoneNumber(_ value: String) -> String {
    let digitsOnly = value.filter(\.isNumber)
    return String(digitsOnly.prefix(11))
}
