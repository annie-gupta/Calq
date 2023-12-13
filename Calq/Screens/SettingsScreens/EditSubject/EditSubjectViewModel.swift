//
//  EditSubjectViewModel.swift
//  Calq
//
//  Created by Kiara on 13.12.23.
//

import Foundation
import UIKit
import SwiftUI

enum EditAlertType {
    case delete
    case nameInvalid
}

class EditSubjectViewModel: ObservableObject {
    @Published var subject: UserSubject
    @Published var subjectName = ""
    @Published var lkSubject = 0
    @Published var selectedColor: Color = .accentColor
    @Published var hasTest = false
    
    @Published var deleteAlert = false
    @Published var alertType: EditAlertType = .nameInvalid
    
    init(subject: UserSubject) {
        self.subject = subject
    }
    
    func update() {
        subjectName = subject.name
        lkSubject = subject.lk ? 1 : 0
        selectedColor = Color(hexString: subject.color)
        
        hasTest = (subject.subjecttests!.allObjects as! [UserTest]).count > 0
    }
    
    func changeName() {
        if Util.isStringInputInvalid(subjectName) {
            alertType = .nameInvalid
            subjectName = subject.name
            deleteAlert = true
        } else {
            subject.name = subjectName
            saveCoreData()
        }
    }
    
    func changeType() {
        subject.lk = lkSubject == 1 ? true : false
        saveCoreData()
    }
    
    func changeColor() {
        subject.color = UIColor(selectedColor).toHexString()
        saveCoreData()
    }
    
    func showDeleteSubject() {
        alertType = .delete
        deleteAlert = true
    }
    
    func deleteSubject() {
        Util.deleteSubject(subject)
    }
}
