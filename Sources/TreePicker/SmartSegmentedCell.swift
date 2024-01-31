//
//  File.swift
//  
//
//  Created by Alessio Moiso on 27.01.24.
//

import AppKit

/// A subclass of `NSSegmentedCell` that invokes a closure when
/// `selectedSegment` changes.
///
/// In a segmented control, as per default implementation,
/// items that have a menu do not show it if the segmented control is configured
/// with an action, unless the user does a long-press on them.
///
/// As this is not the desired behavior, we are working around it by not setting
/// an action on the segmented control and observing this property instead.
///
/// - seealso: https://developer.apple.com/documentation/appkit/nssegmentedcontrol/1528853-setmenu
/// - seealso: https://stackoverflow.com/a/29898916/925537
final class SmartSegmentedCell: NSSegmentedCell {
	var changeAction: ((Int) -> ())?
	
	override var selectedSegment: Int {
		didSet {
			changeAction?(selectedSegment)
		}
	}
}
