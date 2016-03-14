//
//  UIControl+Blocks.swift
//  UIControl-Blocks
//
//  Created by Chris Combs on 20/02/16.
//  Copyright © 2016 Nodes. All rights reserved.
//

import UIKit

private struct AssociatedKeys {
	static var TouchUpInside: NSString = "TouchUpInside"
	static var TouchDown: NSString = "TouchDown"
	static var TouchUpOutside: NSString = "TouchUpOutside"
	static var TouchCancel: NSString = "TouchCancel"
}

extension UIControl {
	

	
	public typealias ControlBlock = (selfRef: AnyObject, sender: UIControl) -> ()
	
	private static let ControlBlockDefaultID = 199299
	
	public func addBlock(block: ControlBlock, withId id: Int = UIControl.ControlBlockDefaultID, forControlEvent event: UIControlEvents, selfRef sender:AnyObject) {
		
//		var eventsDict = ControlBlockManager.sharedInstance.controls[self] ?? [:]
//		var events = eventsDict[event] ?? []
//		events.append(block: block, selfRef: sender)
//		eventsDict[event] = events
//		ControlBlockManager.sharedInstance.controls[self] = eventsDict
		
		var eventString: NSString = ""
		
		switch event {
		case UIControlEvents.TouchUpInside:
			addTarget(self, action: "triggerTouchUpInsideBlocks:", forControlEvents: event)
			eventString = AssociatedKeys.TouchUpInside
		case UIControlEvents.TouchDown:
			addTarget(self, action: "triggerTouchDownBlocks:", forControlEvents: event)
			eventString = AssociatedKeys.TouchDown
		case UIControlEvents.TouchUpOutside:
			addTarget(self, action: "triggerTouchUpOutsideBlocks:", forControlEvents: event)
			eventString = AssociatedKeys.TouchUpOutside
		case UIControlEvents.TouchCancel:
			addTarget(self, action: "triggerCancelBlocks:", forControlEvents: event)
			eventString = AssociatedKeys.TouchCancel
		default:
			//TODO: error
			return
		}
		
		let wrapped = BlockWrapper()
		wrapped.block = block
		print(bridge(eventString))
		var blocks = objc_getAssociatedObject(self, bridge(eventString)) as? [BlockWrapper] ?? []
		blocks.append(wrapped)
		
		objc_setAssociatedObject(self, bridge(eventString), blocks, .OBJC_ASSOCIATION_RETAIN);
		objc_setAssociatedObject(self, bridge(wrapped), sender, .OBJC_ASSOCIATION_ASSIGN);
		
	}
	
	// Can't believe there's no clean way to do this
	func triggerTouchUpInsideBlocks(sender: UIControl) {
		triggerBlockWithSender(sender, eventKey: AssociatedKeys.TouchUpInside)
	}
	
	func triggerTouchDownBlocks(sender: UIControl) {
		triggerBlockWithSender(sender, eventKey: AssociatedKeys.TouchDown)
	}
	
	func triggerTouchUpOutsideBlocks(sender: UIControl) {
		triggerBlockWithSender(sender, eventKey: AssociatedKeys.TouchUpOutside)
	}
	
	func triggerCancelBlocks(sender: UIControl) {
		triggerBlockWithSender(sender, eventKey: AssociatedKeys.TouchCancel)
	}
	
	func triggerBlockWithSender(sender: UIControl, eventKey: NSString) {
//		if let tuples = ControlBlockManager.sharedInstance.controls[sender]?[eventType] {
//			for tuple in tuples {
//				tuple.block(selfRef: tuple.selfRef, sender: sender)
//			}
//		}
		
		var key: NSString = eventKey
		print(key.memory)
	
		guard let wrappedBlocks = objc_getAssociatedObject(self, &key) as? [BlockWrapper] else {
			return
		}
		for wrapped in wrappedBlocks {
			if let selfRef = objc_getAssociatedObject(self, bridge(wrapped)) {
				wrapped.block(selfRef: selfRef, sender: sender)
			}
		}
	}
	
	public func removeBlockWithId(id: Int) {
		
	}
	
	public func removeBlocksForEventType(eventType: UIControlEvents) {
		guard let actions = actionsForTarget(self, forControlEvent: eventType) else {
			return
		}
		for action in actions.filter({$0.containsString("Blocks")}) {
			removeTarget(self, action: NSSelectorFromString(action), forControlEvents: eventType)
		}
	}
}

func bridge<T : AnyObject>(obj : T) -> UnsafePointer<Void> {
	return UnsafePointer(Unmanaged.passUnretained(obj).toOpaque())
	// return unsafeAddressOf(obj) // ***
}

func bridge<T : AnyObject>(ptr : UnsafePointer<Void>) -> T {
	return Unmanaged<T>.fromOpaque(COpaquePointer(ptr)).takeUnretainedValue()
	// return unsafeBitCast(ptr, T.self) // ***
}
/*
	In objc this could be done with associated objects and a dictionary. Swift closures are not
	objects, so they can't be bridged to NSDictionary to store as an associated object. This singleton
	will keep track of the blocks instead.
*/
public class ControlBlockManager: NSObject {
	static let sharedInstance = ControlBlockManager()
	var controls: [UIControl: [UIControlEvents: [(block: UIControl.ControlBlock, selfRef: AnyObject)]]] = [:]
	
}

extension UIControlEvents: Hashable {
	public var hashValue: Int {
		return Int(rawValue)
	}
}

class BlockWrapper: NSObject {
	var block: UIControl.ControlBlock = {_,_ in }
}
