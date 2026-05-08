import Foundation
import FirebaseAuth
internal import Combine
import FirebaseFirestore
import Charts
import CoreML

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
        
//        let snapshot = try await db.collection("doctorEmails")
//            .document("emails")
//            .getDocument()
        
        
        
        
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
    
    func signIn(email: String, password: String) async throws -> UserData {
        
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
            throw NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Some error, try again later"])
        }
        
        return UserData(
            id: user.uid,
            name: (data["name"] as? String)!,
            surname: (data["surname"] as? String)!,
            thirdname: (data["thirdname"] as? String) ?? "",
            phone: (data["phone"] as? String)!,
            email: user.email!,
            role: role
        )
    }
    
    func authorizeRole(_ user:UserData)-> (any UserProtocol)?{
        if user.role == .patient {
            let patientVM = PatientViewModel(user: user)
            return patientVM
        } else if user.role == .doctor{
            let doctorVM = DoctorViewModel(user: user)
            return doctorVM
        } else {
            return nil
        }
    }
    
    func signOut() {
        try? Auth.auth().signOut()
        self.user = nil
        UserDefaults.standard.setValue(false, forKey: "isLoggedIn")
    }
}


class PatientViewModel: ObservableObject, UserProtocol {
    @Published var user: UserData
    @Published var date: Date = Date()
    @Published var measurements: [RawMeasurement] = []
    
    init?(user: UserData?) {
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
    
    func getTodayData(date: Date) async throws {
        let uid = user.id
        let db = Firestore.firestore()
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let formatted = df.string(from: date)
        let docRef = db.collection("patientsData").document(uid).collection("glucose").document(formatted)
        let snapshot = try await docRef.getDocument()  // async/await вместо замыкания
        guard let data = snapshot.data(), let measurements = data["measurements"] else { return }
        guard let jsonData = try? JSONSerialization.data(withJSONObject: measurements) else { return }
            let decoder = JSONDecoder()
            let rawMeasurements = try decoder.decode([RawMeasurement].self, from: jsonData)
            self.measurements = rawMeasurements
    }
}

class DoctorViewModel: ObservableObject, UserProtocol{
    @Published var user: UserData
    
    init?(user: UserData?) {
        guard let user = user else { return nil}
        self.user = user
    }

    
}

protocol UserProtocol: ObservableObject{
    var user: UserData{ get set }
}


class ModelPredictViewModel: ObservableObject {
    @Published var user: UserData
    @Published var measurements: [RawMeasurement]
    private var lags: [Double] = [0, 0, 0, 0, 0, 0, 0]
    private var velocities: [Double] = [0, 0]
    private var acceleration: Double = 0
    private var meanRecent: Double = 0
    private var model = glucose_model()
    
    
    init(user: UserData, measurements: [RawMeasurement]) {
        self.user = user
        self.measurements = measurements
    }
    
    func createLags(){
        let last = measurements.last
        let prev = measurements[measurements.count-2]
        let lastDate = Date(timeIntervalSince1970: TimeInterval(last!.timestamp))
        let prevDate = Date(timeIntervalSince1970: TimeInterval(prev.timestamp))
        let lastTime = lastDate.formatted(date: .omitted, time: .shortened)
        let prevTime = prevDate.formatted(date: .omitted, time: .shortened)
        
        let minutesLast = lastTime.components(separatedBy: ":").map { Int($0)! }.reduce(0, { $0*60 + $1 })
        let minutesPrev = prevTime.components(separatedBy: ":").map { Int($0)! }.reduce(0, { $0*60 + $1 })
        
        let diff = minutesPrev - minutesLast
        var minutes = [minutesLast, 0, 0, 0, 0, minutesPrev]
//        
//        if diff > 45 {
//            //TODO: - Evaluate lags for big time gap
//            
//        } else {
        
            let points: Int = diff/5
            for i in 1...4{
                minutes[i] = minutes[i-1] + points
            }
            self.lags[0] = (last?.glucose.value)!
            
            for i in 1...4 {
                let x: Double = Double((minutes[i] - minutes[i-1]) / (minutes[5] - minutes[i]))
                let y = (lags[5] - lags[i-1]) * x
                lags[i] = lags[i-1] + y
            }
            
            self.lags[5] = prev.glucose.value
//
//        }
        
    }
    
    func createVelocity(){
        velocities[0] = lags[0] - lags[1]
        velocities[1] = lags[1] - lags[2]
    }
    
    func createAcceleration(){
        acceleration = velocities[0] - velocities[1]
    }
    
    func createMeanRecent(){
        meanRecent = (lags[0] + lags[1] + lags[2]) / 3
    }
    
    func forecast(minutes: Int) -> RawMeasurement {
        var predict = 0.0
        do {
            let p = try model.prediction(lag_1: lags[0], lag_2: lags[1], lag_3: lags[2], lag_4: lags[3], lag_5: lags[4], lag_6: lags[5], time_to_predict: Double(minutes), velocity_1: velocities[0], velocity_2: velocities[1], acceleration: acceleration, mean_recent: meanRecent, sex_female: 0, isDiabet: 0)
            predict = p.prediction
        } catch  {
            
        }
        let glucose = GlucoseData(unit: "mmol/L", value: predict)
        let forecasted = RawMeasurement(glucose: glucose, timestamp: measurements.last!.timestamp + minutes*60)
        return forecasted
    }
}
