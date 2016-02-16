//
//  HighScoreVC.swift
//  ColorMemory
//
//  Created by ArunPrasanth R on 25/01/16.
//  Copyright © 2016 ArunPrasanth R. All rights reserved.
//

import UIKit
import CoreData

class HighScoreVC: UIViewController, UITableViewDataSource {

    let appDelegate =
    UIApplication.sharedApplication().delegate as! AppDelegate
    var managedContext:NSManagedObjectContext!
    let fetchRequest = NSFetchRequest()
    var error: NSError? = nil

    @IBOutlet weak var noDataLabel: UILabel!
    var highScoreArray:NSArray = []

    @IBOutlet weak var highScoreTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchHighscoreCoreData("")          // fetch scores from core data
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return highScoreArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("highScoreTableViewCell", forIndexPath: indexPath) as! HighScoreTableViewCell
        
        let highscoreObj = highScoreArray[indexPath.row] as! HighscoreObj
        cell.nameLabel.text = highscoreObj.name
        cell.scoreLabel.text = NSString(format: "%d", highscoreObj.score) as String
        cell.rankLabel.text = NSString(format: "%d", indexPath.row+1) as String
        
        return cell
        
    }

    @IBAction func onClickBackBtn(sender: AnyObject) {
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    //MARK: - Core Data
    //Fetch
    func fetchHighscoreCoreData(entityName:String) {
        managedContext = appDelegate.managedObjectContext
        
        // Create Entity Description
        let entityDescription = NSEntityDescription.entityForName("Highscore", inManagedObjectContext: managedContext)
        
        // Configure Fetch Request
        fetchRequest.entity = entityDescription
        
        do {
            let result = try managedContext.executeFetchRequest(fetchRequest)
            let sortByScoreArray:NSMutableArray = []
            for i in 0..<result.count {
                let match = result[i] as! NSManagedObject
                
                let highscoreObj = HighscoreObj()
                highscoreObj.name = match.valueForKey(NAME) as? String
                highscoreObj.score = match.valueForKey(SCORE) as! Int
                highscoreObj.date = match.valueForKey(DATE) as? NSDate
                
                sortByScoreArray .addObject(highscoreObj)
            }
            
            if sortByScoreArray.count > 0 {
                let scoreSortDescriptor = NSSortDescriptor(key: "score", ascending: false)
                highScoreArray = (sortByScoreArray as NSArray).sortedArrayUsingDescriptors([scoreSortDescriptor])
                highScoreTable.reloadData()
                noDataLabel.hidden = true

            } else {
                noDataLabel.hidden = false
            }
            
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
    }
}
