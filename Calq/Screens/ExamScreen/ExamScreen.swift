//
//  ExamScreen.swift
//  Calq
//
//  Created by Kiara on 02.02.23.
//

import SwiftUI

struct ExamScreen: View {
    @StateObject var settings: AppSettings = getSettings()!
    @State var examSubejcts: [UserSubject] = getAllExamSubjects()
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading){
                BlockView()//.frame(height: 70) //TODO: change points on exam select ect.
                Text("Prüfungsfächer").font(.headline)
                ZStack{
                    RoundedRectangle(cornerRadius: 8).fill(Color.gray.opacity(0.2))
                    VStack{
                        ForEach(1...5, id: \.self){ i in
                            ExamView(subject: getExam(i), type: i).environmentObject(settings)
                        }
                    }
                }
                Spacer()
            }
            .padding()
            .navigationTitle("Prüfungsübersicht")
        }
    }
}


struct ExamView: View { //TODO: filter out already added ones qwq
    @State var subjects: [UserSubject] = getAllSubjects()
    @EnvironmentObject var settings: AppSettings
    @State var subject: UserSubject?
    
    @State var subjectName = "keines ausgewählt"
    @State var sliderText: String = "0"
    @State var sliderValue: Float = 0
    var type: Int
    
    
    var body: some View {
        VStack{
            ZStack{
                Menu {
                    let options = getOptions(lk: (type == 1 || type == 2))
                    if(!options.isEmpty){
                    Section {
                        ForEach(options){sub in
                            Button(sub.name) {
                                subject = sub
                                saveExam(type, sub)
                            }
                        }
                    }
                    Section {
                        Button {
                            removeExam(type)
                            subject = nil
                        } label: {
                            Text("Entfernen/keines").foregroundColor(.red)
                        }
                    }
                    }
                }label: {
                    RoundedRectangle(cornerRadius: 8).fill(subColor()).frame(height: 30)
                }
                
                Text((subject != nil) ? subject!.name : "keines ausgewählt")
            }
            HStack {
                Text(String(sliderValue.rounded()))
                Slider(value: $sliderValue, in: 0...15, onEditingChanged: { data in
                    sliderValue = sliderValue.rounded()
                    subject?.exampoints = Int16(sliderValue)
                    saveCoreData()
                })
                .accentColor(subColor())
                .disabled(subject == nil)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .onAppear{
            subjects = getAllSubjects()
            sliderValue = (subject != nil) ? Float(Int(subject!.exampoints)) : 0
        }
    }
    
    func subColor()-> Color{
        if(subject == nil){return Color.gray}
       return getSubjectColor(subject)
    }
    
    
    func getOptions(lk: Bool = true)-> [UserSubject]{
        return subjects.filter{$0.lk == lk}
    }
}
