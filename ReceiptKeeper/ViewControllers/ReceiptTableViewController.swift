//
//  ReceiptTableViewController.swift
//  ReceiptKeeper
//
//  Created by Perez Willie Nwobu on 11/5/18.
//  Copyright © 2018 Perez Willie Nwobu. All rights reserved.
//

import UIKit
import CoreData

class ReceiptTableViewController: UITableViewController , NSFetchedResultsControllerDelegate{

   
    // MARK: - Table view data source

    //Title of section header
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return fetchResultsController.sections?[section].name.capitalized
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchResultsController.sections?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchResultsController.sections?[section].numberOfObjects ?? 0
    }
    

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReceiptCell", for: indexPath) as! ReceiptTableViewCell
  
       let receipt = fetchResultsController.object(at: indexPath)
      
    cell.receiptImage.layer.cornerRadius = 4
        cell.receiptTitle.text = receipt.name
       
        cell.receiptImage.image = UIImage(data: receipt.imageData!)
        
        //Date
        if let timeStamp = receipt.date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        let date = dateFormatter.string(from: timeStamp)
        
        cell.receiptDate.text = date
        }
                return cell
    }
   
    
 
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 95.0
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
           let receipt = fetchResultsController.object(at: indexPath)
            let moc = CoreDataStack.shared.mainContext
            moc.delete(receipt)
            
            do {
                try moc.save()
            } catch{
                moc.reset()
            }
          tableView.reloadData()
        }
    }
 
    //Mark: - NSFetchedResultControllerDelegate
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
  
    //Changing section Info - Adding & Removing sections
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
        default:
            break
        }
    }
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert :
            guard let newIndexPath = newIndexPath else {return}
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .delete :
            guard let indexPath = indexPath else {return}
            tableView.deleteRows(at: [indexPath], with: .automatic)
        case .move :
            guard let oldIndexPath = indexPath,
            let newIndexPath = newIndexPath else {return}
            tableView.deleteRows(at: [oldIndexPath], with: .automatic)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
            
        case .update :
            guard let indexPath = indexPath else {return}
            tableView.reloadRows(at: [indexPath], with: .automatic)
            
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowReceiptDetail" {
            let detailVC = segue.destination as! ReceiptDetailViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                detailVC.receipt =  fetchResultsController.object(at: indexPath)
            }
        }
    }
    
    
    lazy var fetchResultsController : NSFetchedResultsController<Receipt> = {
        let fetchRequest : NSFetchRequest<Receipt> = Receipt.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let moc = CoreDataStack.shared.mainContext
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                             managedObjectContext: moc, sectionNameKeyPath: "priority",
                                             cacheName: nil)
        
        frc.delegate = self
      try!  frc.performFetch()
        return frc
    }()
    
}
