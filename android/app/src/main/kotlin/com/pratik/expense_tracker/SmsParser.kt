/*
package com.pratik.expense_tracker

object SmsParser {

    fun parseAmount(message: String): Double? {

        val regex = Regex("(?:Rs|INR|₹)\\s?([0-9,]+\\.?[0-9]*)")

        val match = regex.find(message)

        return match?.groupValues?.get(1)
            ?.replace(",", "")
            ?.toDoubleOrNull()
    }

    fun detectType(message: String): String? {

        val msg = message.lowercase()

        return when {

            msg.contains("debited") ||
                    msg.contains("spent") ||
                    msg.contains("withdrawn") ||
                    msg.contains("purchase") -> "debit"

            msg.contains("credited") ||
                    msg.contains("received") ||
                    msg.contains("deposit") -> "credit"

            else -> null
        }
    }
}*/
package com.pratik.expense_tracker

import java.security.MessageDigest

object SmsParser {

    data class Transaction(
        val amount: Double,
        val type: String,
        val merchant: String?,
        val category: String,
        val account: String?,
        val balance: Double?,
        val upi: String?,
        val reference: String?,
        val subscription: Boolean,
        val hash: String
    )

    // ---------------- IGNORE FILTER ----------------

    private val ignoreWords = listOf(
        "otp",
        "one time password",
        "verification code",
        "loan offer",
        "credit limit",
        "minimum due",
        "reward points",
        "cashback offer",
        "promo",
        "sale",
        "discount",
        "pre approved",
        "apply now"
    )

    fun isTransactionSms(message: String): Boolean {

        val msg = message.lowercase()

        return ignoreWords.none { msg.contains(it) }
    }

    // ---------------- REGEX ----------------

    private val amountRegex =
        Regex("(?:rs|inr|₹)\\.?\\s?([0-9,]+\\.?[0-9]*)", RegexOption.IGNORE_CASE)

    private val balanceRegex =
        Regex("(?:bal|balance|avl bal).*?(?:rs|inr|₹)\\.?\\s?([0-9,]+\\.?[0-9]*)", RegexOption.IGNORE_CASE)

    private val upiRegex =
        Regex("[a-zA-Z0-9._-]+@[a-zA-Z]+")

    private val refRegex =
        Regex("(?:utr|ref no|txn id|reference|ref)[: ]*([A-Za-z0-9]+)", RegexOption.IGNORE_CASE)

    private val accountRegex =
        Regex("(?:a/c|acct|account).*?x*([0-9]{2,4})", RegexOption.IGNORE_CASE)

    // ---------------- TYPE DETECTION ----------------

    private val debitKeywords = listOf(
        "debited",
        "spent",
        "withdrawn",
        "purchase",
        "paid",
        "sent",
        "dr",
        "payment",
        "upi payment",
        "transfer to"
    )

    private val creditKeywords = listOf(
        "credited",
        "received",
        "deposit",
        "refund",
        "cashback",
        "cr",
        "transfer from"
    )

    // ---------------- MERCHANT EXTRACTION ----------------

    private val merchantPatterns = listOf(

        Regex("to ([A-Za-z0-9 .&_-]+)", RegexOption.IGNORE_CASE),
        Regex("at ([A-Za-z0-9 .&_-]+)", RegexOption.IGNORE_CASE),
        Regex("from ([A-Za-z0-9 .&_-]+)", RegexOption.IGNORE_CASE),
        Regex("paid to ([A-Za-z0-9 .&_-]+)", RegexOption.IGNORE_CASE),
        Regex("towards ([A-Za-z0-9 .&_-]+)", RegexOption.IGNORE_CASE)
    )

    // ---------------- MERCHANT NORMALIZATION ----------------

    private val merchantRules = mapOf(

        "swiggy" to "Swiggy",
        "zomato" to "Zomato",
        "amazon" to "Amazon",
        "flipkart" to "Flipkart",
        "uber" to "Uber",
        "ola" to "Ola",
        "myntra" to "Myntra",
        "ajio" to "Ajio",
        "netflix" to "Netflix",
        "spotify" to "Spotify",
        "youtube" to "YouTube",
        "prime" to "Amazon Prime",
        "apple" to "Apple",
        "paytm" to "Paytm",
        "phonepe" to "PhonePe",
        "gpay" to "Google Pay",
        "bharatpe" to "BharatPe",
        "irctc" to "IRCTC"
    )

    // ---------------- CATEGORY ENGINE ----------------

    private fun detectCategory(merchant: String?): String {

        if (merchant == null) return "Others"

        val m = merchant.lowercase()

        return when {

            m.contains("swiggy") ||
                    m.contains("zomato") -> "Food"

            m.contains("uber") ||
                    m.contains("ola") ||
                    m.contains("irctc") -> "Travel"

            m.contains("amazon") ||
                    m.contains("flipkart") ||
                    m.contains("myntra") ||
                    m.contains("ajio") -> "Shopping"

            m.contains("netflix") ||
                    m.contains("spotify") ||
                    m.contains("youtube") ||
                    m.contains("prime") -> "Subscription"

            m.contains("bill") ||
                    m.contains("electricity") ||
                    m.contains("recharge") -> "Bills"

            else -> "Others"
        }
    }

    // ---------------- SUBSCRIPTION DETECTOR ----------------

    private fun detectSubscription(merchant: String?): Boolean {

        if (merchant == null) return false

        val m = merchant.lowercase()

        return m.contains("netflix")
                || m.contains("spotify")
                || m.contains("youtube")
                || m.contains("prime")
                || m.contains("apple")
    }

    // ---------------- MERCHANT PARSER ----------------

    private fun extractMerchant(message: String): String? {

        merchantPatterns.forEach {

            val match = it.find(message)

            if (match != null) {

                return match.groupValues[1]
                    .replace(".", "")
                    .replace(",", "")
                    .trim()
            }
        }

        return null
    }

    private fun normalizeMerchant(merchant: String?): String? {

        if (merchant == null) return null

        val m = merchant.lowercase()

        merchantRules.forEach {

            if (m.contains(it.key))
                return it.value
        }

        return merchant
    }

    // ---------------- DUPLICATE HASH ----------------

    private fun generateHash(
        amount: Double,
        merchant: String?,
        type: String
    ): String {

        val input = "$amount|$merchant|$type"

        val md = MessageDigest.getInstance("MD5")

        val bytes = md.digest(input.toByteArray())

        return bytes.joinToString("") { "%02x".format(it) }
    }

    // ---------------- MAIN PARSER ----------------

    fun parse(message: String): Transaction? {

        if (!isTransactionSms(message)) return null

        val msg = message.lowercase()

        val amount = amountRegex.find(message)
            ?.groupValues?.get(1)
            ?.replace(",", "")
            ?.toDoubleOrNull()
            ?: return null

        val type = when {

            debitKeywords.any { msg.contains(it) } -> "debit"

            creditKeywords.any { msg.contains(it) } -> "credit"

            else -> return null
        }

        val balance = balanceRegex.find(message)
            ?.groupValues?.get(1)
            ?.replace(",", "")
            ?.toDoubleOrNull()

        val upi = upiRegex.find(message)?.value

        val reference =
            refRegex.find(message)?.groupValues?.get(1)

        val account =
            accountRegex.find(message)?.groupValues?.get(1)

        val merchantRaw = extractMerchant(message)

        val merchant = normalizeMerchant(merchantRaw)

        val category = detectCategory(merchant)

        val subscription = detectSubscription(merchant)

        val hash = generateHash(amount, merchant, type)

        return Transaction(
            amount = amount,
            type = type,
            merchant = merchant,
            category = category,
            account = account,
            balance = balance,
            upi = upi,
            reference = reference,
            subscription = subscription,
            hash = hash
        )
    }
}