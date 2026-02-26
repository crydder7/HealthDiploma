import Foundation

struct AppUser {
    let id: String
    var name: String
    var surname: String
    var thirdname: String
    var phone: String
    let email: String
    let role: UserRole
}

enum UserRole {
    case patient
    case doctor
    
    init?(rawValue: String) {
        switch rawValue {
        case "patient":
            self = .patient
        case "doctor":
            self = .doctor
        default:
            return nil
        }
    }
}

struct Patient {
    var user: AppUser
    var name: String
    var surname: String
    var thirdname: String
    var gender: String
    var birthday: Date
    var phone: String
    
//    var glucoseLevels: [Int]
}

struct PatientRegistrationData {
    let name: String
    let surname: String
    let thirdname: String
    let birthday: Date
    let gender: String
    let phone: String
}

struct Doctor{
    var user: AppUser
    var name: String
    var surname: String
    var thirdname: String
    var phone: String
}
