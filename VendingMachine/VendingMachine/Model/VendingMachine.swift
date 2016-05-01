//
//  VendingMachine.swift
//  VendingMachine
//
//  Created by Dulio Denis on 4/29/16.
//  Copyright © 2016 Dulio Denis. All rights reserved.
//

import UIKit

// MARK: - Vending Machine Protocol
// Protocol defining requirements for what a Vending Machine could be
// A concrete vending machine would implement these to vend different
// items

protocol VendingMachineType {
    // the selection of items to vend
    var selection: [VendingSelection] { get }
    // a selection inventory that the machine contains that conform to the ItemType protocol
    var inventory: [VendingSelection: ItemType] { get set }
    // the machine needs to keep track of how much money the user can use to buy things
    var amountDeposited: Double { get set }
    
    // machine needs to set itself up from a fully constructed inventory source
    init(inventory: [VendingSelection: ItemType])
    // when vending there are many error conditions where things can go wrong 
    // so we'll need to create a throwing function
    func vend(selection: VendingSelection, quantity: Double) throws
    // add cash to the vending machine
    func deposit(amount: Double)
    // convenience function to return the correct item or nil
    func itemForCurrentSelection(selection: VendingSelection) -> ItemType?
}

// MARK: - Item Type Protocol
// Protocol representing what a Vending Item could be

protocol ItemType {
    // price of the item which can not change
    var price: Double { get }
    // quantity of items which can change
    var quantity: Double { get set }
}


// MARK: - Error Types

enum InventoryError: ErrorType {
    case InvalidResource
    case ConversionError
    case InvalidKey
}


enum VendingMachineError: ErrorType {
    case InvalidSelection
    case OutOfStock
    // associated value to let user know how much they need to complete
    case InsufficientFunds(required: Double)
}


// MARK: - Helper Classes

class PlistConverter {
    
    // class or type method
    class func dictionaryFromFile(name: String, ofType type: String) throws -> [String:AnyObject] {
        guard let path = NSBundle.mainBundle().pathForResource(name, ofType: type) else {
            throw InventoryError.InvalidResource
        }
        
        guard let dictionary = NSDictionary(contentsOfFile: path),
            let castedDictionary = dictionary as? [String:AnyObject]
        else {
            throw InventoryError.ConversionError
        }
        
        return castedDictionary
    }
}


class InventoryUnarchiver {
    
    class func vendingInventoryFromDictionary(dictionary: [String : AnyObject]) throws -> [VendingSelection : ItemType] {
        var inventory: [VendingSelection:ItemType] = [ : ] // variable initialized to an empty dictionary
        
        for (key, value) in dictionary {
            if let itemDictionary = value as? [String :  Double],
            let price = itemDictionary["price"],
            let quantity = itemDictionary["quantity"] {
                let item = VendingItem(price: price, quantity: quantity)
                guard let matchedKey = VendingSelection(rawValue: key) else {
                    throw InventoryError.InvalidKey
                }
                
                inventory.updateValue(item, forKey: matchedKey)
            }
        }
        
        return inventory
    }
}


// MARK: - Concrete Vending Selection Enum
// The enum encapsulating the various selection options in a vending machine

enum VendingSelection: String {
    case Soda
    case DietSoda
    case Chips
    case Cookie
    case Sandwich
    case Wrap
    case CandyBar
    case PopTart
    case Water
    case FruitJuice
    case SportsDrink
    case Gum
    
    func icon() -> UIImage {
        if let image = UIImage(named: self.rawValue) {
            return image
        }
        return UIImage(named: "Default")!
    }
}


// MARK: - Vending Item Struct
// The Object to represent a Vending Item which conforms to the ItemType Protocol

struct VendingItem: ItemType {
    var price: Double
    var quantity: Double
}


// MARK: - Vending Machine Class
// The concrete implementation of a Vending Machine conforming to the VendingMachineType Protocol
// This works best as a class that models state and we can maintain a reference to the values

class VendingMachine: VendingMachineType {
    
    var selection: [VendingSelection] = [.Soda, .DietSoda, .Chips, .Cookie, .Sandwich, .Wrap, .CandyBar, .PopTart, .Water, .FruitJuice, .SportsDrink, .Gum]
    
    var inventory: [VendingSelection: ItemType]
    
    var amountDeposited: Double = 10.0
    
    required init(inventory: [VendingSelection : ItemType]) {
        self.inventory = inventory
    }
    
    func vend(selection: VendingSelection, quantity: Double) throws {
        guard var item = inventory[selection] else {
            throw VendingMachineError.InvalidSelection
        }
        
        guard item.quantity > 0 else {
            throw VendingMachineError.OutOfStock
        }
        
        // figure out the required amount (unit price * how much they want)
        let totalPrice = item.price * quantity
        
        // if the user can afford it then purchase it
        if amountDeposited >= totalPrice {
            amountDeposited -= totalPrice
            item.quantity -= quantity
            inventory.updateValue(item, forKey: selection)
        } else { // otherwise let them know how much more they need
            let amountRequired = totalPrice - amountDeposited
            throw VendingMachineError.InsufficientFunds(required: amountRequired)
        }
    }
    
    
    // convenience method to return the correct item or nil
    
    func itemForCurrentSelection(selection: VendingSelection) -> ItemType? {
        return inventory[selection]
    }
    
    
    func deposit(amount: Double) {
        amountDeposited += amount
    }
}