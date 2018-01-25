//
//  SirenAlertMessaging.swift
//  Siren
//
//  Created by Arthur Sabintsev on 12/6/17.
//  Copyright © 2017 Sabintsev iOS Projects. All rights reserved.
//

import Foundation

// MARK: - Siren Alert Messaging Customization

/// Allows the overriding of all the `UIAlertController` and `UIActionSheet` Strings to which Siren defaults.
///
/// - Warning: Overriding any of these keys will result in the loss of the built-in internationalization that Siren provides.
///
/// As SirenAlertMessaging is a Struct, one _or_ more keys can be modified. Overriding only one string will result in the other keys retaining their default (and internationalizable) values.
public struct SirenAlertMessaging {

    public struct Constants {
        public static let nextTime = "В следующий раз"
        public static let skipVersion = "Пропустить версию"
        public static let updateMessage = "Доступна новая версия %@. Пожалуйста обновитесь до последней версии %@."
        public static let updateTitle = "Доступно обновление"
        public static let updateNow = "Обновить"
    }

    let nextTimeButtonMessage: String
    let skipVersionButtonMessage: String
    let updateButtonMessage: String
    let updateMessage: String
    let updateTitle: String

    /// The public initializer
    ///
    /// - Parameters:
    ///   - title: The title field of the `UIAlertController`.
    ///   - message: The `message` field of the `UIAlertController`.
    ///   - updateButtonMessage: The `title` field of the Update Button `UIAlertAction`.
    ///   - nextTimeButtonMessage: The `title` field of the Next Time Button `UIAlertAction`.
    ///   - skipVersionButtonMessage: The `title` field of the Skip Button `UIAlertAction`.
    public init(updateTitle title: String = Constants.updateTitle,
                updateMessage message: String = Constants.updateMessage,
                updateButtonMessage: String = Constants.updateNow,
                nextTimeButtonMessage: String = Constants.nextTime,
                skipVersionButtonMessage: String = Constants.skipVersion) {
        self.updateTitle = title
        self.nextTimeButtonMessage = nextTimeButtonMessage
        self.updateButtonMessage = updateButtonMessage
        self.updateMessage = message
        self.skipVersionButtonMessage = skipVersionButtonMessage
    }

}
