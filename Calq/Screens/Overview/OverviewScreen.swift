//
//  OverviewScreen.swift
//  Calq
//
//  Created by Kiara on 02.02.23.
//

import SwiftUI

struct OverviewScreen: View {
    @State var gradeText = ""
    @State var blockCircleText = ""
    @State var blockPoints: Double = Double(generateBlockOne()) + Double(generateBlockTwo())
    @State var blockPercent = 0.0
    
    @State var averageText: String = String(format: "%.2f", Util.generalAverage())
    @State var averagePercent: Double = Util.generalAverage() / 15
    
    @State var halfyears = getHalfyears()
    @State var generalAverage = Util.generalAverage()
    @State var subjectValues: [BarEntry] = createSubjectBarData()
   
    @State var subjects = Util.getAllSubjects()
    
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false){
                VStack{
                    ZStack{
                        RoundedRectangle(cornerRadius: 8).fill(Color.gray.opacity(0.2))
                        BarChart(values: $subjectValues, heigth: 200, average: generalAverage, round: true).padding()
                    }
                    
                    ZStack{
                        RoundedRectangle(cornerRadius: 8).fill(Color.gray.opacity(0.2))
                        VStack(alignment: .leading, spacing: 5){
                        Text("Verlauf")
                        LineChart(subjects: subjects)
                        }.padding()
                    }
                    
                    ZStack{
                        RoundedRectangle(cornerRadius: 8).fill(Color.gray.opacity(0.2))
                        VStack(alignment: .leading, spacing: 5){
                            Text("Halbjahre")
                            BarChart(values: $halfyears, heigth: 150)
                        }.padding()
                    }
                    
                    ZStack{
                        RoundedRectangle(cornerRadius: 8).fill(Color.gray.opacity(0.2))
                        VStack{
                                GeometryReader{ geo in
                                    HStack(alignment: .center){
                                    Text("Fächerschnitt").frame(width: geo.size.width/3)
                                    Spacer()
                                    Text("Abischnitt").frame(width: geo.size.width/3)
                                }
                            }
                            HStack(alignment: .center, spacing: 5){
                                CircleChart(perrcent: $averagePercent, textDescription: "Durchschnitt aller Fächer ohne Prüfungsnoten", upperText: $averageText, lowerText: $gradeText).frame(height: 150)
                                CircleChart(perrcent: $blockPercent, textDescription: "Durchschnitt mit Prüfungsnoten)", upperText: $blockCircleText, lowerText: Binding.constant("Ø")).frame(height: 150)
                            }
                        }.padding()
                       
                    }
                }
            }.padding(.horizontal)
                .navigationTitle("Übersicht")
                .onAppear{
                    halfyears = getHalfyears()
                    subjects = Util.getAllSubjects()
                    
                    subjectValues = createSubjectBarData()
                    
                    blockPoints = Double(generateBlockOne()) + Double(generateBlockTwo())
                    blockPercent = Double((blockPoints/900.0))
                    blockCircleText = getGradeData()
                    
                    averagePercent = Util.generalAverage() / 15
                    averageText = String(format: "%.2f", Util.generalAverage())
                    gradeText = grade()
                }
        }
    }
    
    func grade()->String{
        return String(format: "%.2f", Util.grade(number: Util.generalAverage()))
    }
    
    func getGradeData()-> String{
        let blockGrade = Util.grade(number: Double(blockPoints * 15 / 900))
        return  String(format: "%.2f", blockGrade)
    }
}

func getHalfyears() -> [BarEntry]{
   return [BarEntry(value: Util.generalAverage(1)),BarEntry(value: Util.generalAverage(2)),BarEntry(value: Util.generalAverage(3)),BarEntry(value: Util.generalAverage(4))]
}
