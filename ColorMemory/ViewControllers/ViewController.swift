//
//  ViewController.swift
//  ColorMemory
//
//  Created by ArunPrasanth R on 21/01/16.
//  Copyright © 2016 ArunPrasanth R. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var nameTxtHolderVw: UIView!
    @IBOutlet weak var colorsCollectionView: UICollectionView!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var saveYourScoreLabel: UILabel!
    @IBOutlet weak var nameTxtField: UITextField!
    @IBOutlet weak var highScoreBtn: UIButton!
    var points:Int!
    var imageTapTime:Int!
    var prevSelectedImageStr:String!
    var prevSelectedIndex:NSIndexPath!
    var highScoreArray:NSArray = []
    var selectedArray:NSMutableArray = []
    var colorsImageArray = [String]()
    let appDelegate =
    UIApplication.sharedApplication().delegate as! AppDelegate
    var managedContext:NSManagedObjectContext!
    let fetchRequest = NSFetchRequest()
    var error: NSError? = nil
    let clickSoundURL =  NSBundle.mainBundle().URLForResource("click", withExtension: "mp3")!
    let matchSoundURL =  NSBundle.mainBundle().URLForResource("match", withExtension: "mp3")!
    var audioPlayer = AVAudioPlayer()
    
    var logoImages = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialize()
        restart()       //Start or restart the game
    }
    
    func initialize() {
        colorsImageArray = [
            "Color1",  "Color2", "Color3",
            "Color4",  "Color5", "Color6",
            "Color7", "Color8","Color1",  "Color2", "Color3",
            "Color4",  "Color5", "Color6",
            "Color7", "Color8"]
        
        nameTxtHolderVw.layer.cornerRadius = 4
        nameTxtHolderVw.layer.borderWidth = 0.5
        nameTxtHolderVw.layer.borderColor = UIColor(colorLiteralRed: 243.0/255.0, green: 243.0/255.0, blue: 243.0/255.0, alpha: 1).CGColor
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "onClickDismissKeyboard")
        overlayView.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //MARK: - UITextfield Delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        onClickDismissKeyboard()
        return true
    }
    
    //MARK: - UIcollectionview Datasource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return colorsImageArray.count   //tile count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ColorsCell", forIndexPath: indexPath) as! ColorsCollectionViewCell
        
        cell.colorCardImgVw.image = UIImage(imageLiteral: "Cardbg")
        cell.colorsImgVw.image = UIImage(imageLiteral: colorsImageArray[indexPath.row])
        cell.colorsImgVw.accessibilityIdentifier = colorsImageArray[indexPath.row] as String
        
        if selectedArray .containsObject(indexPath) {
            cell.colorsImgVw.hidden = false
            cell.colorCardImgVw.hidden = true
        } else {
            cell.colorsImgVw.hidden = true
            cell.colorCardImgVw.hidden = false
        }

        if selectedArray .containsObject(indexPath) {
            cell.colorsImgVw.hidden = true
            cell.colorCardImgVw.hidden = true
        }
        
        cell.colorCardImgVw.contentMode = .ScaleAspectFit
        cell.colorsImgVw.contentMode = .ScaleAspectFit
        
        //Two lines needed if we use contraints
        cell.contentView.frame = cell.bounds
        cell.contentView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        return cell
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return CGSizeMake(collectionView.frame.size.width/4-3, collectionView.frame.size.height/4-3)
        
    }
    
    //MARK: - UIcollectionview Delegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! ColorsCollectionViewCell
        
        cell.colorCardImgVw.image = UIImage(imageLiteral: colorsImageArray[indexPath.row])

        if prevSelectedIndex != indexPath {
            cell.colorCardImgVw.hidden = true

            UIView.transitionWithView(cell.colorsImgVw,
                duration:0.35,
                options:.TransitionFlipFromRight,
                animations:
                { () -> Void in
                    cell.colorsImgVw.hidden = false
                },
                completion: nil);

            imageTapTime = imageTapTime+1

            if imageTapTime == 1 {      // 1st image tap
                prevSelectedIndex = indexPath
                prevSelectedImageStr = cell.colorsImgVw.accessibilityIdentifier
                
                playSound(true)
                self.colorsCollectionView.userInteractionEnabled = true

            } else {                    // 2nd image tap
                
                if prevSelectedImageStr == cell.colorsImgVw.accessibilityIdentifier {
                    // both the images are same
                    reset(true, currentIndex: indexPath)
                    self.colorsCollectionView.userInteractionEnabled = true
                } else {
                    // images are different
                    reset(false, currentIndex: indexPath)
                    
                    self.colorsCollectionView.userInteractionEnabled = false
                    let seconds = 1.0                           // 1 second delay to reset the selected image
                    let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
                    let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                    
                    dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                        
                        // collectionview reload perfomed with delay
                        self.colorsCollectionView.reloadData()
                        self.colorsCollectionView.userInteractionEnabled = true

                    })
                }
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        if selectedArray .containsObject(indexPath) {   // disable selection option
            return false
        }
        return true
    }
    
    //MARK: - Developer Function
    
    func reset(isEqual:Bool,currentIndex:NSIndexPath) {
        imageTapTime = 0
        if isEqual == true {
            playSound(false)
            points = points+2
            selectedArray .addObject(prevSelectedIndex)
            selectedArray .addObject(currentIndex)
            
            colorsCollectionView.reloadData()
            
            if selectedArray.count == 16 {
                overlayView.hidden = false
                saveYourScoreLabel.text = "Do you wish to save your score ?"
            }

        } else {
            playSound(true)
            points = points-1
        }
        pointsLabel.text = "Your score : "+(NSString(format: "%d", points)as String)
        prevSelectedImageStr = ""

    }

    func restart() {
        self.colorsCollectionView.userInteractionEnabled = false
        imageTapTime = 0
        points = 0
        prevSelectedImageStr = ""
        pointsLabel.text = "Your score :"+(NSString(format: "%d", points)as String)

        colorsImageArray.shuffle()
        selectedArray .removeAllObjects()
        self.colorsCollectionView.reloadData()
        overlayView.hidden = true
        
        let seconds = 0.75                           // 1 second delay to reset the selected image
        let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
        let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            self.colorsCollectionView.userInteractionEnabled = true

        })
    }
    
    //MARK: - UIButton Action
    
    @IBAction func onClickResetBtn(sender: AnyObject) {
            restart()
    }
    
    @IBAction func onClickHighScoreBtn(sender: AnyObject) {
            loadHighScoreView()
    }
    
    @IBAction func onClickSaveBtn(sender: AnyObject) {

        if nameTxtField.text?.trimWhite() != "" {
            overlayView.hidden = true
            self.insertHighscoreToCoreData(self.nameTxtField.text!.trimWhite(), score: self.points)
            nameTxtField.text = ""
            restart()
            self.colorsCollectionView.reloadData()

        } else {
            showAlertView("Alert", message: "Please enter your name.")
        }
    }
    
    func onClickDismissKeyboard () {
        UIView.beginAnimations("", context: nil)
        UIView.setAnimationDuration(0.5)
        
        self.view.endEditing(true)
        UIView.commitAnimations()
    }
    
    //MARK: - UINavigation Methods
    func loadHighScoreView() {
        let highScoreVC = self.storyboard?.instantiateViewControllerWithIdentifier("highScoreVC") as? HighScoreVC
        self.presentViewController(highScoreVC!, animated: true, completion: nil)
        
    }
    
    //MARK: - CoreData
    //Insert
    func insertHighscoreToCoreData(name:String,score:Int?) {
        managedContext = appDelegate.managedObjectContext
        
        // Create Entity Description
        let entityDescription = NSEntityDescription.entityForName("Highscore", inManagedObjectContext: managedContext)
        
        let score = NSManagedObject(entity: entityDescription!,
            insertIntoManagedObjectContext: managedContext)
        
            //set values
            score.setValue(name, forKey: NAME)
            score.setValue(points, forKey: SCORE)
            score.setValue(NSDate(), forKey: DATE)
        
            do {
                try managedContext.save()
                loadHighScoreView()

            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
    }
    
    //Delete
    func deleteHighscoreFromCoreData(entityName:String)
    {
        managedContext = appDelegate.managedObjectContext
        do
        {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            for managedObject in results
            {
                let managedObjectData:NSManagedObject = managedObject as! NSManagedObject
                managedContext.deleteObject(managedObjectData)
            }
        } catch let error as NSError {
            print("Detele all data in \(entityName) error : \(error) \(error.userInfo)")
        }
    }
    
    //MARK: - UIAlertview
    func showAlertView(title:NSString,message:NSString) {
        let alert = UIAlertController(title: title as String, message: message as String, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }

    //MARK: - Auiod player
    func playSound(isClick:Bool){
        
        if isClick == true {
            do {
                audioPlayer = try AVAudioPlayer(contentsOfURL: clickSoundURL)
                // use audioPlayer
            } catch {
                // handle error
            }
            
        } else {
            do {
                audioPlayer = try AVAudioPlayer(contentsOfURL: matchSoundURL)
                // use audioPlayer
            } catch {
                // handle error
            }
        }
        audioPlayer.prepareToPlay()
        audioPlayer.play()
    }
}

