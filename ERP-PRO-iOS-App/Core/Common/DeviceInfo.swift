//
//  DeviceInfo.swift
//  ERP-PRO-iOS-App
//

import UIKit

public struct DeviceInfo {
    public static var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    public static var isMacCatalyst: Bool {
        #if targetEnvironment(macCatalyst)
        return true
        #else
        return false
        #endif
    }
}
