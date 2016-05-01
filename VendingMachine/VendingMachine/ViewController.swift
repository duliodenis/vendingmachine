//
//  ViewController.swift
//  VendingMachine
//
//  Created by Dulio Denis on 4/29/16.
//  Copyright © 2016 Dulio Denis. All rights reserved.
//

import UIKit

private let reuseIdentifier = "vendingItem"
private let screenWidth = UIScreen.mainScreen().bounds.width

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var stepper: UIStepper!
    
    // Vending Machine Stored Property using the type of the protocol that defines Vending Machines
    let vendingMachine: VendingMachineType
    
    // the current selection (optional)
    var currentSelection: VendingSelection?
    
    // the quantity to purchase
    var quantity: Double = 1.0
    
    
    required init?(coder aDecoder: NSCoder) {
        // encapsulate the vending machine inside a do catch statement since initializing may throw errors
        do {
            let dictionary = try PlistConverter.dictionaryFromFile("VendingInventory", ofType: "plist")
            let inventory = try InventoryUnarchiver.vendingInventoryFromDictionary(dictionary)
            self.vendingMachine = VendingMachine(inventory: inventory)
        } catch let error {
            fatalError("\(error)")
        }
        
        super.init(coder: aDecoder)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionViewCells()
        setupViews()
    }

    
    func setupViews() {
        updateQuantityLabel()
        updateBalanceLabel()
    }
    
    
    // MARK: - UICollectionView 

    func setupCollectionViewCells() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 10, right: 0)
        let padding: CGFloat = 10
        layout.itemSize = CGSize(width: (screenWidth / 3) - padding, height: (screenWidth / 3) - padding)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        
        collectionView.collectionViewLayout = layout
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return vendingMachine.selection.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! VendingItemCell
        
        // display the item's icon by assigning to the CollectionView's custom cell's iconView
        let item = vendingMachine.selection[indexPath.row]
        cell.iconView.image = item.icon()
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        updateCellBackgroundColor(indexPath, selected: true)
        
        resetLabels()
        currentSelection = vendingMachine.selection[indexPath.row]
        
        updateTotalPriceLabel()
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        updateCellBackgroundColor(indexPath, selected: false)
    }
    
    func collectionView(collectionView: UICollectionView, didHighlightItemAtIndexPath indexPath: NSIndexPath) {
        updateCellBackgroundColor(indexPath, selected: true)
    }
    
    func collectionView(collectionView: UICollectionView, didUnhighlightItemAtIndexPath indexPath: NSIndexPath) {
        updateCellBackgroundColor(indexPath, selected: false)
    }
    
    func updateCellBackgroundColor(indexPath: NSIndexPath, selected: Bool) {
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) {
            cell.contentView.backgroundColor = selected ? UIColor(red: 41/255.0, green: 211/255.0, blue: 241/255.0, alpha: 1.0) : UIColor.clearColor()
        }
    }
    
    
    // MARK: - Helper Methods
    
    @IBAction func purchase() {
        if let pickedSelection = currentSelection {
            do {
                try vendingMachine.vend(pickedSelection, quantity: quantity)
                updateBalanceLabel()
                resetLabels()
            } catch {
                // FIXME: Error Handling Code.
            }
        } else {
            // FIXME: Alert user to no selection.
        }
    }
    
    
    @IBAction func updateQuantity(sender: UIStepper) {
        quantity = sender.value
        updateTotalPriceLabel()
        updateQuantityLabel()
    }
    
    
    func updateTotalPriceLabel() {
        if let pickedSelection = currentSelection,
            let item = vendingMachine.itemForCurrentSelection(pickedSelection) {
                totalLabel.text = "$ \(item.price * quantity)"
        }
    }
    
    
    func updateQuantityLabel() {
        quantityLabel.text = "\(quantity)"
    }
    
    
    func updateBalanceLabel() {
        balanceLabel.text = "$ \(vendingMachine.amountDeposited)"
    }
    
    
    func resetLabels() {
        quantity = 1
        stepper.value = 1
        updateTotalPriceLabel()
        updateQuantityLabel()
    }
}

