//
//  FetchRequest.swift
//  ThinkBox
//
//  Created by sudhanshu kumar on 07/09/25.
//
import Foundation
import CoreData

extension BoxFolder {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BoxFolder> {
        return NSFetchRequest<BoxFolder>(entityName: "BoxFolder")
    }

    @NSManaged public var createdAt: Date?
    @NSManaged public var name: String?
    @NSManaged public var box: NSSet?   // Folder -> Items relation
}

// MARK: Generated accessors for box
extension BoxFolder {

    @objc(addBoxObject:)
    @NSManaged public func addToBox(_ value: BoxItem)

    @objc(removeBoxObject:)
    @NSManaged public func removeFromBox(_ value: BoxItem)

    @objc(addBox:)
    @NSManaged public func addToBox(_ values: NSSet)

    @objc(removeBox:)
    @NSManaged public func removeFromBox(_ values: NSSet)
}

extension BoxFolder: Identifiable { }


extension BoxItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BoxItem> {
        return NSFetchRequest<BoxItem>(entityName: "BoxItem")
    }

    @NSManaged public var createdAt: Date?
    @NSManaged public var name: String?
    @NSManaged public var note: String?
    @NSManaged public var folder: BoxFolder?   // Item -> Folder relation
}

extension BoxItem: Identifiable { }
