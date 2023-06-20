//
//  Util.swift
//  Calq
//
//  Created by Kiara on 10.02.23.
//

import CoreData
import SwiftUI
import WidgetKit

public enum ModelKit {
    public static let bundle = Bundle.main
}


let UD_firstLaunchKey = "notFirstLaunch"
let UD_primaryType = "primaryGradeType"

let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?.?.?"
let buildVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "?.?.?"

//for testing CoreData
protocol ImplementsCoreDataStack {
    static var sharedContext: NSManagedObjectContext { get }
}

func saveCoreData(){
    try! Util.getContext().save()
    WidgetCenter.shared.reloadAllTimelines()
}

struct Util {
    private static var context = CoreDataStack.sharedContext
    
    static func setContext(_ newContext: NSManagedObjectContext){
        context = newContext
    }
    
    static func getContext() -> NSManagedObjectContext {
        return context
    }
    
    static func checkString(_ str: String) -> Bool{
        if(str.isEmpty){ return true }
        let regex = try! NSRegularExpression(pattern: "^[a-zA-Z_ ]*$")
        let range = NSRange(location: 0, length: str.utf16.count)
        return regex.firstMatch(in: str, options: [], range: range) == nil
    }
    
    // MARK: Average Functions
    static func average (_ values: [Int]) -> Double {
        if (values.count < 1) {return 0}
        
        var avg = 0
        for i in 0..<values.count {
            avg += values[i];
        }
        return (Double(avg) / Double(values.count))
    }
    
    static private func average (_ values: [Double]) -> Double {
        if (values.count < 1) {return 0}
        
        var avg = Double(0);
        for i in 0..<values.count {
            avg += values[i];
        }
        return (Double(avg) / Double(values.count))
    }
    
    static private func average (_ values: [Int], from: Int = 0, to: Int = -1) -> Double {
        return self.average(values.map { Double($0)} as [Double], from: from, to: to)
    }
    
    static private func average (_ values: [Double], from: Int = 0, to: Int = -1) -> Double {
        if (from > values.count) {return 0;}
        
        var sum = Double(0);
        if (to<0){for i in from..<values.count {
            sum += values[i];
        }} else {for i in from..<to {
            sum += values[i];
        }}
        
        return (Double(sum) / Double(values.count))
    }
    
    /// Returns the average of an array of tests.
    static func testAverage(_ tests: [UserTest]) -> Double {
        var gradeWeights = 0.0
        var avgArr: [Double] = []
        
        for type in getTypes() {
            let filteredTests = tests.filter {$0.type == type.id}
            if !filteredTests.isEmpty {
                let weight = Double(Double(type.weigth)/100)
                gradeWeights += weight
                let avg = Util.average(filteredTests.map{Int($0.grade)})
                avgArr.append(Double(avg * weight))
            }
        }
        
        if avgArr.isEmpty { return 0 }
        let num = avgArr.reduce(0, +)/gradeWeights
        
        if num.isNaN { return 0 }
        return num
    }
    
    /// Returns the average of all grades from one subject
    static func getSubjectAverage(_ sub: UserSubject) -> Double{
        let tests = filterTests(sub)
        if(tests.count == 0){return 0.0}
        
        var count = 0.0
        var subaverage = 0.0
        
        for e in 1...4 {
            let yearTests = tests.filter{$0.year == Int16(e)}
            if(yearTests.count == 0) {continue}
            count += 1
            subaverage += Util.testAverage(yearTests)
        }
        let average = (subaverage / count)
        return Double(String(format: "%.2f", average).padding(toLength: 4, withPad: "0", startingAt: 0))!
    }
    
    /// Returns the average of all grades from one subject
    static func getSubjectAverage(_ sub: UserSubject, year: Int, filterinactve: Bool = true) -> Double{
        let tests = filterTests(sub, checkinactive: filterinactve).filter{$0.year == year};
        if(tests.count == 0){return 0.0}
        return testAverage(tests)
    }
    
    /// Returns the average of all grades from all subjects.
    static func generalAverage() -> Double{
        let allSubjects = getAllSubjects()
        
        if(allSubjects.count == 0) { return 0.0}
        var a = 0.0
        var subjectCount = Double(allSubjects.count)
        
        for sub in allSubjects{
            if(sub.subjecttests == nil){subjectCount-=1;continue}
            let tests = filterTests(sub)
            if(tests.count == 0){subjectCount-=1;continue}
            a += round(getSubjectAverage(sub))
        }
        
        if((a / subjectCount).isNaN) {return 0.0}
        return a / subjectCount
    }
    
    /// Filtering the tests so you get only the ones which are in active halfyears
    
    
    /// Returns the average of all grades from all subjects in a specific halfyear
    static func generalAverage(_ year: Int) -> Double{
        let allSubjects = getAllSubjects()
        if(allSubjects.count == 0) { return 0.0}
        var count = 0.0;
        var grades = 0.0;
        
        for sub in allSubjects {
            if(sub.subjecttests == nil){continue}
            let tests = filterTests(sub).filter{Int($0.year) == year}
            if(tests.count == 0){continue}
            let multiplier = sub.lk ? 2.0 : 1.0
            
            count += multiplier * 1
            grades += multiplier * round(Util.testAverage(tests))
        }
        if(grades == 0.0){ return 0.0}
        return grades / count
    }
    
    /// Converts the points(0-15) representation of a grade to the more common 1-6 scale.
    static func grade(number: Double) -> Double {
        if(number == 0.0){ return 0.0}
        return ((17 - abs(number)) / 3.0)
    }
    
    /// Generates a convient String that shows the grades of the subject.
    static func averageString(_ subject: UserSubject) -> String{
        var str: String = ""
        if(subject.subjecttests == nil) {return str}
        let tests = subject.subjecttests!.allObjects as! [UserTest]
        
        for i in 1...4 {
            let arr = tests.filter({$0.year == i});
            if(arr.count == 0) {str += "-- ";continue}
            str += String(Int(round(Util.testAverage(arr))))
            if(i != 4){ str += " "}
        }
        return str
    }
    
    //MARK: Get Settings
    ///Returns fresh new settings and deletes everything
    @discardableResult static func deleteSettings()-> AppSettings{
        let request: NSFetchRequest<AppSettings> = AppSettings.fetchRequest()
        
        do {
            let items: [NSManagedObject] = try context.fetch(request)
            items.forEach { i in
                context.delete(i)
            }
        }
        catch { print("Failed to delete Data") }
        saveCoreData()
        return Util.getSettings()
    }
    
    ///Returns the apps settings
    static func getSettings()-> AppSettings {
        do {
            let requestResult: [NSManagedObject] = try Util.getContext().fetch(AppSettings.fetchRequest())
            
            if(requestResult.isEmpty){
                let item =  AppSettings(context: Util.getContext())
                item.colorfulCharts = false
                setTypes(item)
                saveCoreData()
                return item
            } else {
                let settings = requestResult[0] as! AppSettings
                if settings.gradetypes?.count == 0 {
                    setTypes(settings)
                    saveCoreData()
                }
                return settings
            }
            
        } catch (let err) { print("Failed to load settings", err) }
        
        print("THIS SHOULD NOT HAPPEN HELP")
        let item =  AppSettings(context: Util.getContext())
        item.colorfulCharts = false
        setTypes(item)
        saveCoreData()
        return item
    }
    
    /// add default grade types
    static func setTypes(_ settings: AppSettings,_ deleted: Bool = false){
        let type1 = GradeType(context: context)
        type1.id = 0
        type1.name = "Test"
        type1.weigth = 50
        
        let type2 = GradeType(context: context)
        type2.id = 1
        type2.name = "Klausur"
        type2.weigth = 50
        
        settings.addToGradetypes(type1)
        settings.addToGradetypes(type2)
        
        saveCoreData()
    }
    
    //MARK: Get Subject
    /// Returns all Subjects as Array
    static func getAllSubjects()-> [UserSubject]{
        var allSubjects: [UserSubject] = []
        let settings = Util.getSettings()
        
        if(settings.usersubjects != nil){
            allSubjects = settings.usersubjects!.allObjects as! [UserSubject]
            return sortSubjects(allSubjects)
        }
        return allSubjects
    }
    
    /// sort all subjects sorted after type and name
    static func sortSubjects(_ subs: [UserSubject])-> [UserSubject]{
        let arr1 = subs.filter{$0.lk}.sorted(by: {$0.name < $1.name })
        let arr2 = subs.filter{!$0.lk}.sorted(by: {$0.name < $1.name })
        return arr1+arr2
    }
    
    /// Returns one Subject
    static func getSubject(_ subject: UserSubject) -> UserSubject? {
        let all = self.getAllSubjects()
        let filtered = all.filter{$0.objectID == subject.objectID}
        if (filtered.count < 1) {return nil}
        return filtered[0]
    }
    
    /// Returns one Subject after ID
    static func getSubject(_ id: NSManagedObjectID) -> UserSubject? {
        let all = self.getAllSubjects()
        let filtered = all.filter{$0.objectID == id}
        if (filtered.count < 1) {return nil}
        return filtered[0]
    }
    
    ///Returns all Subjectnames
    static func getAllSubjectNames() -> [String] {
        var subjects = Util.getAllSubjects()
        subjects = subjects.sorted(by: {$0.name < $1.name })
        return subjects.map{$0.name}
    }
    
    static func deleteSubject(_ subject: UserSubject){
        context.delete(subject)
    }
    
    //MARK: Years
    static func getinactiveYears(_ sub: UserSubject)-> [String]{
        if(sub.inactiveYears.isEmpty){return []}
        let arr: [String] = sub.inactiveYears.components(separatedBy: " ")
        return arr
    }
    
    /// Check if year is inactive
    static func checkinactiveYears(_ arr: [String], _ num: Int)-> Bool {
        return !arr.contains(String(num))
    }
    
    /// Remove  inactive halfyear
    @discardableResult static func removeYear(_ sub: UserSubject, _ num: Int) -> UserSubject{
        let arr = getinactiveYears(sub)
        
        sub.inactiveYears = arrToString(arr.filter{$0 != String(num)})
        saveCoreData()
        return sub
    }
    
    /// Add inactive halfyear
    @discardableResult static func addYear(_ sub: UserSubject, _ num: Int) -> UserSubject{
        var arr = getinactiveYears(sub)
        
        arr.append(String(num))
        sub.inactiveYears = arrToString(arr)
        saveCoreData()
        return sub
    }
    
    /// returns last active year of a subject
    static func lastActiveYear(_ sub: UserSubject) -> Int{
        var num = 1
        
        for i in 1...4 {
            let tests = filterTests(sub, checkinactive: false).filter{$0.year == i}
            if(tests.count > 0){ num = i}
        }
        return num
    }
    
    private static func arrToString(_ arr: [String]) -> String{
        return arr.joined(separator: " ")
    }
    
    //MARK: Dates
    /// Returns the last date when a grade was added
    static func calcMaxDate() -> Date {
        let allSubjects = self.getAllSubjects().filter{$0.subjecttests?.count != 0}
        if(allSubjects.count == 0) {return Date()}
        
        let allDates = allSubjects.map{
            ($0.subjecttests?.allObjects as? [UserTest] ?? [])}
            .map{
                $0.map{
                    $0.date.timeIntervalSince1970
                }.sorted(by: {$0 > $1})[0]
            }
        if(allDates.count == 0) {return Date(timeIntervalSince1970: 0.0)}
        
        return Date(timeIntervalSince1970: allDates.sorted(by: {$0 > $1})[0])
    }
    
    /// Returns the first date when a grade was added
    static func calcMinDate() -> Date {
        let allSubjects = self.getAllSubjects().filter{$0.subjecttests?.count != 0}
        if(allSubjects.count == 0){return Date()}
        
        let allDates = allSubjects.map{
            ($0.subjecttests?.allObjects as? [UserTest] ?? [])}
            .map{
                $0.map{
                    $0.date.timeIntervalSince1970
                }.sorted(by: {$0 < $1})[0]
            }
        if(allDates.count == 0) { return Date(timeIntervalSince1970: 0.0) }
        
        return Date(timeIntervalSince1970: allDates.sorted(by: {$0 < $1})[0])
    }
    
    //MARK: Tests
    static func filterTests(_ sub: UserSubject, checkinactive: Bool = true)-> [UserTest]{
        if(sub.subjecttests == nil){return []}
        var tests = sub.subjecttests!.allObjects as! [UserTest]
        
        for year in [1,2,3,4]{
            if(checkinactive){
                if(!checkinactiveYears(getinactiveYears(sub), year)){
                    tests = tests.filter{$0.year != year}
                }
            }
        }
        return tests
    }
    
    static func deleteTest(_ test: UserTest){
        test.testtosubbject.removeFromSubjecttests(test)
        saveCoreData()
    }
    
    // MARK: Managed GradeTypes
    static func addType(name: String, weigth: Int) {
        let existingTypes = getTypes().map{$0.id}
        let newType = GradeType(context: context)
        newType.name = name
        newType.weigth = Int16(weigth)
        newType.id = getNewIDQwQ(existingTypes)
        
        let new = getTypes().map {Int($0.weigth)}.reduce(0, +)
        if new + weigth > 100 {
            newType.weigth = 0
        }
        let settings = Util.getSettings()
        settings.addToGradetypes(newType)
        saveCoreData()
    }
    
    private static func getNewIDQwQ(_ ids: [Int16]) -> Int16 {
        for i in 0...(ids.max() ?? Int16(ids.count)) {
            if !ids.contains(Int16(i)) { return Int16(i) }
        }
        return Int16(ids.count + 1)
    }
    
    static func deleteType(type: Int16) {
        let t = getTypes().filter{$0.id == type}[0]
        t.gradetosettings!.removeFromGradetypes(t)
        saveCoreData()
    }
    
    static func deleteType(type: GradeType) {
        type.gradetosettings?.removeFromGradetypes(type)
        saveCoreData()
    }
    
    static func getTypes() -> [GradeType] {
        let types = getSettings().gradetypes!.allObjects as! [GradeType]
        if types.count >= 2 { return types}
        
        if types.count == 1 {
            addType(name: "default type", weigth: 0)
        } else if types.isEmpty {
            setTypes(Util.getSettings())
        }
        saveCoreData()
        return getSettings().gradetypes!.allObjects as! [GradeType]
    }
    
    static func highestType() -> Int16 {
        return getTypes().sorted(by: {$0.id > $1.id})[0].id
    }
    
    static func getTypeGrades(_ type: Int16) -> [UserTest] {
        var arr: [UserTest] = []
        for sub in Util.getAllSubjects() {
            for test in sub.subjecttests!.allObjects as! [UserTest] {
                if test.type != type { continue }
                arr.append(test)
            }
        }
        return arr
    }
    
    static func isPrimaryType(_ type: GradeType) -> Bool {
        return isPrimaryType(type.id)
    }
    
    static func isPrimaryType(_ type: Int16) -> Bool {
        let types = getTypes().map { $0.id}
        if !types.contains(type) {setPrimaryType(types[0])}
        return type == UserDefaults.standard.integer(forKey: UD_primaryType)
    }
    
    static func setPrimaryType(_ type: Int16) {
        UserDefaults.standard.set(type, forKey: UD_primaryType)
    }
    
}
