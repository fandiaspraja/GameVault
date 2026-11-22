//
//  FavoriteStore.swift
//  Favorite
//
//  Core Data stack. Model didefinisikan lewat kode (bukan .xcdatamodeld)
//  supaya aman dipakai di dalam Swift Package dan di CI.
//

import CoreData
import os

final class FavoriteGameObject: NSManagedObject {
  @NSManaged var id: Int64
  @NSManaged var name: String?
  @NSManaged var imageURL: String?
  @NSManaged var rating: Double
  @NSManaged var released: String?
  @NSManaged var genre: String?
  @NSManaged var addedAt: Date?
}

public final class FavoriteStore {
  static let entityName = "FavoriteGameObject"
  private static let logger = Logger(subsystem: "GameVault.Favorite", category: "CoreData")

  /// Satu instance model untuk seluruh aplikasi (mencegah entitas ganda saat test).
  static let model: NSManagedObjectModel = {
    let entity = NSEntityDescription()
    entity.name = FavoriteStore.entityName
    entity.managedObjectClassName = NSStringFromClass(FavoriteGameObject.self)
    entity.properties = [
      FavoriteStore.attribute("id", .integer64AttributeType, optional: false, defaultValue: 0),
      FavoriteStore.attribute("name", .stringAttributeType),
      FavoriteStore.attribute("imageURL", .stringAttributeType),
      FavoriteStore.attribute("rating", .doubleAttributeType, optional: false, defaultValue: 0.0),
      FavoriteStore.attribute("released", .stringAttributeType),
      FavoriteStore.attribute("genre", .stringAttributeType),
      FavoriteStore.attribute("addedAt", .dateAttributeType)
    ]
    entity.uniquenessConstraints = [["id"]]

    let model = NSManagedObjectModel()
    model.entities = [entity]
    return model
  }()

  let container: NSPersistentContainer

  /// - Parameter inMemory: `true` untuk pengujian (data tidak ditulis ke disk).
  public init(inMemory: Bool = false) {
    container = NSPersistentContainer(name: "GameVault", managedObjectModel: Self.model)
    if let description = container.persistentStoreDescriptions.first {
      if inMemory {
        description.url = URL(fileURLWithPath: "/dev/null")
      }
      description.shouldMigrateStoreAutomatically = true
      description.shouldInferMappingModelAutomatically = true
    }
    container.loadPersistentStores { _, error in
      if let error {
        Self.logger.error("Gagal memuat store: \(error.localizedDescription, privacy: .public)")
      }
    }
    container.viewContext.automaticallyMergesChangesFromParent = true
    container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
  }

  func newBackgroundContext() -> NSManagedObjectContext {
    let context = container.newBackgroundContext()
    context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    return context
  }

  func entityDescription(in context: NSManagedObjectContext) -> NSEntityDescription? {
    NSEntityDescription.entity(forEntityName: Self.entityName, in: context)
  }

  private static func attribute(
    _ name: String,
    _ type: NSAttributeType,
    optional: Bool = true,
    defaultValue: Any? = nil
  ) -> NSAttributeDescription {
    let attribute = NSAttributeDescription()
    attribute.name = name
    attribute.attributeType = type
    attribute.isOptional = optional
    attribute.defaultValue = defaultValue
    return attribute
  }
}
