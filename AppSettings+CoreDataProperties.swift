//
//  AppSettings+CoreDataProperties.swift
//  Calq
//
//  Created by Kiara on 03.09.23.
//
//

import Foundation
import CoreData


extension AppSettings {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AppSettings> {
        return NSFetchRequest<AppSettings>(entityName: "AppSettings")
    }

    @NSManaged public var colorfulCharts: Bool
    @NSManaged public var weightBigGrades: String?
    @NSManaged public var hasFiveExams: Bool
    @NSManaged public var gradetypes: NSSet?
    @NSManaged public var usersubjects: [UserSubject]?

}

// MARK: Generated accessors for gradetypes
extension AppSettings {

    @objc(addGradetypesObject:)
    @NSManaged public func addToGradetypes(_ value: GradeType)

    @objc(removeGradetypesObject:)
    @NSManaged public func removeFromGradetypes(_ value: GradeType)

    @objc(addGradetypes:)
    @NSManaged public func addToGradetypes(_ values: NSSet)

    @objc(removeGradetypes:)
    @NSManaged public func removeFromGradetypes(_ values: NSSet)

}

// MARK: Generated accessors for usersubjects
extension AppSettings {

    @objc(addUsersubjectsObject:)
    @NSManaged public func addToUsersubjects(_ value: UserSubject)

    @objc(removeUsersubjectsObject:)
    @NSManaged public func removeFromUsersubjects(_ value: UserSubject)

    @objc(addUsersubjects:)
    @NSManaged public func addToUsersubjects(_ values: NSSet)

    @objc(removeUsersubjects:)
    @NSManaged public func removeFromUsersubjects(_ values: NSSet)

}

extension AppSettings : Identifiable {

}
