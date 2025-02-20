//
//  SettingsVM.swift
//  Calq
//
//  Created by Kiara on 16.03.23.
//

import Foundation

enum AlertAction {
    case importData
    case deleteData
    case deleteSubject
    case loadDemo
    case none
}

class SettingsViewModel: ObservableObject {
    @Published var settings: AppSettings = Util.getSettings()
    @Published var subjects: [UserSubject] = Util.getAllSubjects()
    @Published var selectedSubjet: UserSubject?
    
    @Published var hasFiveExams = Util.getSettings().hasFiveExams ? 5 : 4
    
    // sheet presnet stuff
    @Published var editSubjectPresented = false
    @Published var weightSheetPresented = false
    @Published var newSubjectSheetPresented = false
    @Published var presentDocumentPicker = false
    
    @Published var deleteAlert = false
    @Published var alertActiontype: AlertAction = .none
    
    @Published var isLoading = false
    
    // import&export
    @Published var importedJson: String = ""
    @Published var importeJsonURL: URL = URL(fileURLWithPath: "")
    
    // Feedback
    @Published var feedbackContent: String = "ABC"
    @Published var showFeedbackSheet = false
    @Published var feedbackError = false
    
    func reloadAndSave() {
        saveCoreData()
        subjects = Util.getAllSubjects()
        settings = Util.getSettings()
    }
    
    func deleteData() {
        Util.deleteSettings()
        subjects = []
        reloadAndSave()
    }
    
    func showDeleteSubAlert(_ sub: UserSubject) {
        selectedSubjet = sub
        alertActiontype = .deleteSubject
        deleteAlert = true
    }
    
    func deleteSubject() {
        guard let sub = selectedSubjet else { return print("Subject not selected")}
        
        Util.deleteSubject(sub)
        alertActiontype = .none
        deleteAlert = false
        reloadAndSave()
    }
    
    func updateColorfulCharts() {
        settings.colorfulCharts = Util.getSettings().colorfulCharts
        saveCoreData()
    }
    
    func updateExamSettings() {
        settings.hasFiveExams = hasFiveExams == 5
        
        if hasFiveExams == 4 {
            let fifthExam = Util.getAllSubjects().filter { $0.examtype == 5}
            fifthExam.forEach { exam in
                exam.examtype = Int16(0)
            }
        }
        saveCoreData()
    }
    
    func onAppear() {
        subjects = Util.getAllSubjects()
        settings = Util.getSettings()
        hasFiveExams = settings.hasFiveExams ? 5 : 4
    }
    
    func selectSubject(_ subject: UserSubject) {
        selectedSubjet = subject
        editSubjectPresented = true
    }
    
    func sendFeedback() {
        if FeedbackService.sendFeedback(feedbackContent) {
            showFeedbackSheet = false
            feedbackContent = "ABC"
            feedbackError = false
        } else {
            feedbackError = true
        }
    }
}
