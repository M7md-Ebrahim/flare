//
// Flare
// Copyright © 2024 Space Code. All rights reserved.
//

import Foundation
import StoreKit

// MARK: - PromotionalOffer

/// A class representing a promotional offer.
public final class PromotionalOffer: NSObject, Sendable {
    // MARK: Properties

    /// The details of an introductory offer or a promotional offer for an auto-renewable subscription.
    public let discount: StoreProductDiscount
    /// The signed discount applied to a payment.
    public let signedData: SignedData

    // MARK: Initialization

    /// Creates a `PromotionalOffer` instance.
    ///
    /// - Parameters:
    ///   - discount: The details of an introductory offer or a promotional offer for an auto-renewable subscription.
    ///   - signedData: The signed discount applied to a payment.
    public init(discount: StoreProductDiscount, signedData: SignedData) {
        self.discount = discount
        self.signedData = signedData
    }
}

// MARK: PromotionalOffer.SignedData

public extension PromotionalOffer {
    /// The signed discount applied to a payment.
    final class SignedData: NSObject, Sendable {
        // MARK: Properties

        /// The identifier agreed upon with the App Store for a discount of your choosing.
        public let identifier: String
        /// The identifier of the public/private key pair agreed upon with the App Store when the keys were generated.
        public let keyIdentifier: String
        /// One-time use random entropy-adding value for security.
        public let nonce: UUID
        /// The cryptographic signature generated by your private key.
        public let signature: String
        /// Timestamp of when the signature is created.
        public let timestamp: Int

        /// Creates a `SignedData` instance.
        ///
        /// - Parameters:
        ///   - identifier: The identifier agreed upon with the App Store for a discount of your choosing.
        ///   - keyIdentifier: The identifier of the public/private key pair agreed upon
        ///                    with the App Store when the keys were generated.
        ///   - nonce: One-time use random entropy-adding value for security.
        ///   - signature: The cryptographic signature generated by your private key.
        ///   - timestamp: Timestamp of when the signature is created.
        public init(identifier: String, keyIdentifier: String, nonce: UUID, signature: String, timestamp: Int) {
            self.identifier = identifier
            self.keyIdentifier = keyIdentifier
            self.nonce = nonce
            self.signature = signature
            self.timestamp = timestamp
        }
    }
}

// MARK: - Convenience Initializators

extension PromotionalOffer.SignedData {
    /// Creates a `SignedData` instance.
    ///
    /// - Parameter paymentDiscount: The signed discount applied to a payment.
    convenience init(paymentDiscount: SKPaymentDiscount) {
        self.init(
            identifier: paymentDiscount.identifier,
            keyIdentifier: paymentDiscount.keyIdentifier,
            nonce: paymentDiscount.nonce,
            signature: paymentDiscount.signature,
            timestamp: paymentDiscount.timestamp.intValue
        )
    }
}

// MARK: - Helpers

extension PromotionalOffer.SignedData {
    var skPromotionalOffer: SKPaymentDiscount {
        SKPaymentDiscount(
            identifier: identifier,
            keyIdentifier: keyIdentifier,
            nonce: nonce,
            signature: signature,
            timestamp: .init(integerLiteral: timestamp)
        )
    }

    @available(iOS 15.0, tvOS 15.0, watchOS 8.0, macOS 12.0, *)
    var promotionalOffer: Product.PurchaseOption {
        get throws {
            guard let data = Data(base64Encoded: signature) else {
                throw IAPError.failedToDecodeSignature(signature: signature)
            }

            return .promotionalOffer(
                offerID: identifier,
                keyID: keyIdentifier,
                nonce: nonce,
                signature: data,
                timestamp: timestamp
            )
        }
    }
}
