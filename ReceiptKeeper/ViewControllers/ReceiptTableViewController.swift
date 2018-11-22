//
//  ReceiptTableViewController.swift
//  ReceiptKeeper
//
//  Created by Perez Willie Nwobu on 11/5/18.
//  Copyright © 2018 Perez Willie Nwobu. All rights reserved.
//

import UIKit
import CoreData

class ReceiptTableViewController: UITableViewController {

    
    // MARK: - Table view data source

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        
        for reseipt in receipts {
            print("receipt priority : \(reseipt.priority)")
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        return receipts.count
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //define initial state(before animation)
        let rotationTransform = CATransform3DTranslate(CATransform3DIdentity, -500, 100, 0)
        cell.layer.transform = rotationTransform
        
        //define the final state (after animation)
        UIView.animate(withDuration: 1, animations: {
            cell.layer.transform = CATransform3DIdentity })
        
    }
    
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReceiptCell", for: indexPath) as! ReceiptTableViewCell

       let receipt = receipts[indexPath.row]
      
    cell.receiptImage.layer.cornerRadius = 4
        cell.receiptTitle.text = receipt.name
       
        cell.receiptImage.image = UIImage(data: receipt.imageData!)
                return cell
    }
 
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 95.0
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
           let receipt = receipts[indexPath.row]
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
 

  

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowReceiptDetail" {
            let detailVC = segue.destination as! ReceiptDetailViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                detailVC.receipt = receipts[indexPath.row]
            }
        }
    }
    
    var receipts : [Receipt] {
    let fetchRequest : NSFetchRequest<Receipt> = Receipt.fetchRequest()
        let moc = CoreDataStack.shared.mainContext
        do {
            return try moc.fetch(fetchRequest)
        } catch {
            NSLog("Error fetching receipts")
            return []
        }
    }
    
}
