import CoreData

class CoreDataStack {
    
    static let shared = CoreDataStack("githubusers")
    
    // MARK: Properties
    private let modelName: String
    
    lazy var mainContext: NSManagedObjectContext = {
        return self.storeContainer.viewContext
    }()
    
    lazy var storeContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: self.modelName)
        
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        return container
    }()
    
    // MARK: Initializers
    init(_ modelName: String) {
        self.modelName = modelName
    }
}

// MARK: Internal
extension CoreDataStack {
    
    func saveContext () {
        guard mainContext.hasChanges else { return }
        
        do {
            mainContext.mergePolicy = NSOverwriteMergePolicy
            
            try mainContext.save()
        } catch let nserror as NSError {
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
}
