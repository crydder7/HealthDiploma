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
    @State var alertText: String = "Something wrong"
    @State var showAlert: Bool = false
    @State var isVerifyEmailAlert: Bool = false
    @State var sexValues: [String] = ["Male", "Female"]
    @State var isLoading: Bool = false
    @FocusState var isFocused: Bool
    private var isPhoneValid: Bool {
        phoneNumber.count == phoneDigitsLimit
    }
    
    //TODO: -Add error handlers, alerts with them and with email message notification
    
    var body: some View {
        VStack{
            Label("Sign up", systemImage: "cross.fill")
                .font(.title)
                .padding()
            Spacer()
            GlassEffectContainer{
                TextField("Enter your name", text: $name)
                    .focused($isFocused)
                    .padding()
                    .glassEffect()
                    .autocorrectionDisabled()
                TextField("Enter your surname", text: $surname)
                    .focused($isFocused)
                    .padding()
                    .glassEffect()
                    .autocorrectionDisabled()
                TextField("Enter your thirdname", text: $thirdname)
                    .focused($isFocused)
                    .padding()
                    .glassEffect()
                    .autocorrectionDisabled()
                TextField("Enter your phone number", text: $phoneNumber)
                    .focused($isFocused)
                    .padding()
                    .keyboardType(.numberPad)
                    .autocorrectionDisabled()
                    .onChange(of: phoneNumber, { oldValue, newValue in
                        phoneNumber = sanitizePhoneNumber(newValue)
                    })
                    .glassEffect()
                    .overlay {
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(.red, lineWidth: isPhoneValid ? 0 : 1)
                    }
                
                TextField("Enter your e-mail adress", text: $email)
                    .focused($isFocused)
                    .padding()
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .glassEffect()
                    .overlay {
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(.red, lineWidth: validateMail(email) ? 0 : 1)
                    }
                Picker("Gender", selection: $gender) {
                    ForEach(sexValues, id: \.self){ sex in
                        Text(sex).tag(sex)
                    }
                }
                .pickerStyle(.menu)
                DatePicker("Select your birthdate", selection: $birth, displayedComponents: .date)
                    .datePickerStyle(.compact)
                SecureField("Enter your password", text: $password)
                    .focused($isFocused)
                    .padding()
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .glassEffect()
                SecureField("Confirm your password", text: $passwordConfirmation)
                    .focused($isFocused)
                    .padding()
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .glassEffect()
                    .overlay {
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(.red, lineWidth: password==passwordConfirmation ? 0 : 1)
                    }
                Spacer()
                
                Button {
                    patient = PatientRegistrationData(name: name, surname: surname, thirdname: thirdname, birthday: birth, gender: gender, phone: phoneNumber)
                    Task{
                        do{
                            isLoading = true
                            try await authVM.signUp(email: email, password: password, registrationData: patient!)
                            alertText = "Check your email (also spam) to finish verification."
                            isLoading = false
                            showAlert = true
                        } catch {
                            isLoading = false
                            alertText = error.localizedDescription
                            showAlert = true
                        }
                    }
                } label: {
                    Label("Register", systemImage: "checkmark.circle.fill")
                        .frame(maxWidth: .infinity)
                        .frame(height: 30)
                }
                .disabled(!isPhoneValid)
                .buttonStyle(.glass)
                .overlay(content: {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(.circular)
                    }
                })
                .padding()
                .alert(isPresented: $showAlert) {
                    Alert(title: Text(alertText))
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            isFocused = false
        }
        .padding()
    }
}

//#Preview {
//    RegisterView()
//}


