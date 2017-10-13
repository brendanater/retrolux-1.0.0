//
//  CoderTests.swift
//  Retrolux
//
//  Created by Brendan Henderson on 9/22/17.
//  Copyright © 2017 Christopher Bryan Henderson. All rights reserved.
//

import Foundation

enum TestEncoderSetupFailure {
    case canEncodeNewValueDoesNotStartWithTrue
    case canEncodeNewValueNotSettingTrue
    case canEncodeNewValueNotSettingFalse
    case referenceNotSetting
    case codingPathNotSetting
    case userInfoNotSetting
    case failedToEncodeEncodable(Error)
    case notReplacingPlaceholderInReferenceOnDeinit
}

fileprivate enum __K__: String, CodingKey {
    case testKey
}

extension EncoderBase {

    static func testSetupCorrectly<T: Encodable & Equatable>(options: Self.Options, encodable: T) -> TestEncoderSetupFailure? {

        let self1 = Self.init(codingPath: [], options: options, userInfo: [:], reference: nil)

        if !self1.codingPath.isEmpty {
            return TestEncoderSetupFailure.codingPathNotSetting
        }

        if !self1.userInfo.isEmpty {
            return TestEncoderSetupFailure.userInfoNotSetting
        }

        if self1.reference != nil {
            return TestEncoderSetupFailure.referenceNotSetting
        }

        if self1.canEncodeNewValue != true {
            return TestEncoderSetupFailure.canEncodeNewValueDoesNotStartWithTrue
        }

        self1.canEncodeNewValue = false

        if self1.canEncodeNewValue != false {
            return TestEncoderSetupFailure.canEncodeNewValueNotSettingFalse
        }

        self1.canEncodeNewValue = true

        if self1.canEncodeNewValue != true {
            return TestEncoderSetupFailure.canEncodeNewValueNotSettingTrue
        }

        let unkeyed = NSMutableArray()

        unkeyed.add("placeholder")

        var self2 = Optional.some(Self.init(codingPath: [__K__.testKey], options: options, userInfo: ["test" : 113], reference: .unkeyed(unkeyed, index: 12341)))

        if !(self2!.codingPath.first is Optional<__K__>) {
            return TestEncoderSetupFailure.codingPathNotSetting
        }

        guard case .unkeyed(let reference, index: let index) = self2!.reference ?? .keyed(NSMutableDictionary(), key: ""),
            index == 12341 && reference === unkeyed else {

            return TestEncoderSetupFailure.referenceNotSetting
        }

        guard self2!.userInfo.first?.key == "test" && self2!.userInfo.first!.value as? Int == 113 else {
            return TestEncoderSetupFailure.userInfoNotSetting
        }

        do {
            try self2!.encode(encodable)
        } catch {
            return TestEncoderSetupFailure.failedToEncodeEncodable(error)
        }

        self2 = nil

        if unkeyed.firstObject as? String == "placeholder" {
            return TestEncoderSetupFailure.notReplacingPlaceholderInReferenceOnDeinit
        }

        return nil
    }
}





