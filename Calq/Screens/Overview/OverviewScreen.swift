//
//  OverviewScreen.swift
//  Calq
//
//  Created by Kiara on 02.02.23.
//

import SwiftUI

struct OverviewScreen: View {
    @ObservedObject var vm: OverViewViewModel
    
    var body: some View {
        
        NavigationView {
            ScrollView(showsIndicators: false){
                VStack{
                    BarChart(values: $vm.subjectValues, heigth: 200, average: vm.generalAverage, round: true)
                        .padding()
                        .background(CardView())
                    
                    VStack(alignment: .leading, spacing: 5){
                        HStack{
                            Text("OverviewTimeChartTitle")
                            Spacer()
                            Image(systemName: "gearshape").onTapGesture{vm.showGraphEdit.toggle()}
                                .disabled(vm.subjects.count == 0)
                                .foregroundColor(vm.subjects.count == 0 ? .gray : Color(UIColor.label))
                        }
                        
                        LineChart(subjects: $vm.subjects)
                        
                        if(vm.showGraphEdit){
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    
                                    ForEach(vm.subjects) { sub in
                                        let color = sub.showInLineGraph ? getSubjectColor(sub) : .gray
                                        ZStack{
                                            Text(sub.name)
                                                .padding(5)
                                                .font(.footnote)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .stroke(color, lineWidth: 3)
                                                        .background(
                                                            RoundedRectangle(cornerRadius: 8)
                                                                .fill(color.opacity(0.4))
                                                        )
                                                )
                                                .onTapGesture {
                                                    sub.showInLineGraph.toggle()
                                                    saveCoreData()
                                                    vm.updateViews()
                                                }
                                        }.padding(3)
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .background(CardView())
                    
                    VStack(alignment: .leading, spacing: 5){
                        Text("OverViewHalfyearChartTitle")
                        BarChart(values: $vm.halfyears, heigth: 150)
                    }
                    .padding()
                    .background(CardView())
                    
                    VStack{
                        GeometryReader{ geo in
                            HStack(alignment: .center){
                                Text("OverviewPieChartSubjects").frame(width: geo.size.width/3)
                                Spacer()
                                Text("OverviewPieChartSum").frame(width: geo.size.width/3)
                            }
                        }//TODO: Localize
                        HStack(alignment: .center, spacing: 5){
                            CircleChart(perrcent: $vm.averagePercent, textDescription: "Durchschnitt aller Fächer ohne Prüfungsnoten", upperText: $vm.averageText, lowerText: $vm.gradeText).frame(height: 150)
                            CircleChart(perrcent: $vm.blockPercent, textDescription: "Durchschnitt mit Prüfungsnoten)", upperText: $vm.blockCircleText, lowerText: Binding.constant("Ø")).frame(height: 150)
                        }
                    }
                    .padding()
                    .background(CardView())
                }
            }.padding(.horizontal)
                .navigationTitle("OverViewTitle")
                .onAppear{
                    vm.updateViews()
                }
        }
    }
}
