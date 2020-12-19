//
//  GHUser+CoreDataClass.swift
//  githubusers
//
//  Created by Brylle Seraspe on 12/18/20.
//
//

import Foundation
import CoreData

@objc(GHUser)
public class GHUser: NSManagedObject {

    static func allInstances() -> [GHUser] {
        let coredataStack = CoreDataStack.shared
        var frc: NSFetchedResultsController<GHUser>
        
        do {
            // managed context
            let context: NSManagedObjectContext = coredataStack.mainContext
            
            // fetch request
            let fetchRequest: NSFetchRequest<GHUser> = GHUser.fetchRequest()
            
            // sort
            let sortDescriptor1 = NSSortDescriptor(key: #keyPath(GHUser.sortID), ascending: true)
            let sortDescriptor2 = NSSortDescriptor(key: #keyPath(GHUser.login), ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptor1, sortDescriptor2]
            
            // filter
//            fetchRequest.predicate = NSPredicate(format: "%K = %@",
//                                                 argumentArray: [
//                                                    #keyPath(BTStkBidAsk.stk_code), code])
            
            //
            frc = NSFetchedResultsController<GHUser>(fetchRequest: fetchRequest,
                                                         managedObjectContext: context,
                                                         sectionNameKeyPath: nil,
                                                         cacheName: nil)
            
            do {
                try frc.performFetch()
            } catch let error as NSError {
                fatalError("Error: \(error.localizedDescription)")
            }
            
            var fetchedObjects = frc.fetchedObjects
            
            fetchedObjects?.sort(by: { (ghUserA, ghUserB) -> Bool in
                return ghUserA.sortID < ghUserB.sortID
            })
            
            return fetchedObjects ?? []
        }
        
        //return []
    }
    
}
