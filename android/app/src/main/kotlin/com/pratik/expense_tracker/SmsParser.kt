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
/*
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

    // ─────────────────────────────────────────────────────────────
    // IGNORE FILTER  (two-stage: must have promo signal AND no real txn signal)
    // ─────────────────────────────────────────────────────────────

    private val promoOnlyWords = listOf(
        "otp", "one time password", "verification code",
        "loan offer", "pre-approved", "pre approved",
        "apply now", "reward points", "cashback offer",
        "promo", "offer expires", "sale ends", "discount coupon",
        "minimum due", "due date", "statement generated",
        "missed call", "know your", "update your"
    )

    private val realTxnSignals = listOf(
        "debited", "credited", "spent", "withdrawn",
        "transfer", "upi", "imps", "neft", "rtgs",
        "payment", "purchase", "received", "sent"
    )

    fun isTransactionSms(message: String): Boolean {
        val msg = message.lowercase()
        val hasPromo = promoOnlyWords.any { msg.contains(it) }
        val hasTxnSignal = realTxnSignals.any { msg.contains(it) }
        // Block only when promo keyword exists AND no real transaction signal
        return !(hasPromo && !hasTxnSignal)
    }

    // ─────────────────────────────────────────────────────────────
    // AMOUNT  — prioritise the amount near the action keyword,
    //           not the first ₹ in the message (often the balance)
    // ─────────────────────────────────────────────────────────────

    // Anchored: amount immediately after a debit/credit action word
    private val txnAmountRegex = Regex(
        """(?:debited|credited|spent|paid|received|transfer(?:red)?|withdrawn|purchase(?:d)?|sent)\s*(?:of|for|rs|inr|₹)?\.?\s*(?:rs|inr|₹)?\.?\s*([0-9,]+\.?[0-9]*)""",
        RegexOption.IGNORE_CASE
    )

    // Fallback: any ₹ amount
    private val anyAmountRegex = Regex(
        """(?:rs|inr|₹)\.?\s*([0-9,]+\.?[0-9]*)""",
        RegexOption.IGNORE_CASE
    )

    // Balance (kept separate so it's never confused with txn amount)
    private val balanceRegex = Regex(
        """(?:(?:avl|avail(?:able)?)?\.?\s*(?:bal(?:ance)?|limit))[\s:]*(?:rs|inr|₹)?\.?\s*([0-9,]+\.?[0-9]*)""",
        RegexOption.IGNORE_CASE
    )

    private fun parseAmount(message: String): Double? {
        // 1. Try anchored match first
        txnAmountRegex.find(message)?.groupValues?.get(1)
            ?.replace(",", "")?.toDoubleOrNull()
            ?.let { return it }

        // 2. Collect all ₹ matches; exclude the one that matches the balance
        val balanceStr = balanceRegex.find(message)
            ?.groupValues?.get(1)?.replace(",", "")

        val allAmounts = anyAmountRegex.findAll(message)
            .mapNotNull { it.groupValues[1].replace(",", "").toDoubleOrNull() }
            .toList()

        val balanceVal = balanceStr?.toDoubleOrNull()
        // Return first amount that isn't the balance value
        return allAmounts.firstOrNull { it != balanceVal } ?: allAmounts.firstOrNull()
    }

    // ─────────────────────────────────────────────────────────────
    // REFERENCES / ACCOUNT
    // ─────────────────────────────────────────────────────────────

    private val upiRegex = Regex("""[a-zA-Z0-9._\-]+@[a-zA-Z]+""")

    private val refRegex = Regex(
        """(?:utr|ref\.?\s*no|txn\.?\s*id|reference(?:\s*no)?|ref)[:\s]*([A-Za-z0-9]{6,24})""",
        RegexOption.IGNORE_CASE
    )

    private val accountRegex = Regex(
        """(?:a(?:/|c(?:ct)?|ccount))[.\s]*[xX*]+([0-9]{2,4})\b""",
        RegexOption.IGNORE_CASE
    )

    // ─────────────────────────────────────────────────────────────
    // TYPE DETECTION  — credit wins on tie
    // ─────────────────────────────────────────────────────────────

    private val debitKeywords = listOf(
        "debited", "spent", "withdrawn", "purchase", "paid to",
        "sent to", " dr ", "dr.", "debit", "deducted",
        "upi payment to", "transfer to", "trf to", "imps to"
    )

    private val creditKeywords = listOf(
        "credited", "received", "deposit", "refund", "cashback",
        " cr ", "cr.", "credit", "transfer from", "trf from",
        "imps from", "neft from", "payment received", "money received"
    )

    private fun detectType(msg: String): String? {
        val hasCredit = creditKeywords.any { msg.contains(it) }
        val hasDebit  = debitKeywords.any  { msg.contains(it) }
        return when {
            hasCredit && hasDebit -> "credit"  // "payment received" → credit
            hasCredit -> "credit"
            hasDebit  -> "debit"
            else      -> null
        }
    }

    // ─────────────────────────────────────────────────────────────
    // MERCHANT STOP WORDS  — truncate capture at these words
    // ─────────────────────────────────────────────────────────────

    private val merchantStopWords = listOf(
        "ref", "utr", "txn", "transaction", "id", "no.", "no ",
        "on ", "via ", "using ", "through ",
        "bank", "ifsc", "neft", "imps", "upi", "hdfc", "sbi", "icici",
        "axis", "kotak", "paytm", "phonepe", "gpay",
        "ltd", "pvt", "limited", "inc",
        "rs.", "rs ", "inr", "₹",
        "a/c", "acct", "account",
        "dear", "your", "the ", "is ", "has ", "was ", "for ", "are "
    )

    private val merchantPatterns = listOf(
        Regex("""paid\s+to\s+([A-Za-z0-9 .&_\-]+)""", RegexOption.IGNORE_CASE),
        Regex("""transfer(?:red)?\s+to\s+([A-Za-z0-9 .&_\-]+)""", RegexOption.IGNORE_CASE),
        Regex("""trf\s+to\s+([A-Za-z0-9 .&_\-]+)""", RegexOption.IGNORE_CASE),
        Regex("""\bto\s+([A-Za-z0-9 .&_\-]+)""", RegexOption.IGNORE_CASE),
        Regex("""\bat\s+([A-Za-z0-9 .&_\-]+)""", RegexOption.IGNORE_CASE),
        Regex("""towards\s+([A-Za-z0-9 .&_\-]+)""", RegexOption.IGNORE_CASE),
        Regex("""merchant[:\s]+([A-Za-z0-9 .&_\-]+)""", RegexOption.IGNORE_CASE),
        Regex("""info[:\s]+([A-Za-z0-9 .&_\-]+)""", RegexOption.IGNORE_CASE)
    )

    private fun extractMerchant(message: String): String? {
        merchantPatterns.forEach { pattern ->
            val match = pattern.find(message) ?: return@forEach
            var raw = match.groupValues[1].trim()

            // Truncate at any stop word
            for (stop in merchantStopWords) {
                val idx = raw.lowercase().indexOf(stop.lowercase())
                if (idx > 0) raw = raw.substring(0, idx).trim()
            }

            // Must be at least 2 chars and not purely numeric
            if (raw.length >= 2 && !raw.all { it.isDigit() || it == '.' || it == ',' }) {
                return raw
            }
        }
        return null
    }

    // ─────────────────────────────────────────────────────────────
    // MERCHANT NORMALISATION  — covers UPI suffixes like SWIGGYIN
    // ─────────────────────────────────────────────────────────────

    private val merchantRules = listOf(
        "swiggy"    to "Swiggy",
        "zomato"    to "Zomato",
        "amazon"    to "Amazon",
        "flipkart"  to "Flipkart",
        "ubereats"  to "Uber Eats",
        "uber"      to "Uber",
        "rapido"    to "Rapido",
        "ola"       to "Ola",
        "myntra"    to "Myntra",
        "ajio"      to "Ajio",
        "meesho"    to "Meesho",
        "netflix"   to "Netflix",
        "spotify"   to "Spotify",
        "youtube"   to "YouTube",
        "primevideo" to "Amazon Prime",
        "prime"     to "Amazon Prime",
        "hotstar"   to "Hotstar",
        "jiocinema" to "JioCinema",
        "apple"     to "Apple",
        "paytm"     to "Paytm",
        "phonepe"   to "PhonePe",
        "gpay"      to "Google Pay",
        "googlepay" to "Google Pay",
        "bharatpe"  to "BharatPe",
        "irctc"     to "IRCTC",
        "bigbasket"  to "BigBasket",
        "blinkit"   to "Blinkit",
        "grofers"   to "Blinkit",
        "zepto"     to "Zepto",
        "dunzo"     to "Dunzo",
        "nykaa"     to "Nykaa",
        "bookmyshow" to "BookMyShow",
        "makemytrip" to "MakeMyTrip",
        "goibibo"   to "Goibibo",
        "airtel"    to "Airtel",
        "jio"       to "Jio",
        "bsnl"      to "BSNL",
        "vodafone"  to "Vodafone",
        "vi"        to "Vi"
    )

    private fun normalizeMerchant(merchant: String?): String? {
        if (merchant == null) return null
        val m = merchant.lowercase().replace(Regex("[^a-z0-9]"), "")
        for ((key, value) in merchantRules) {
            if (m.contains(key.replace(Regex("[^a-z0-9]"), ""))) return value
        }
        // Title-case fallback
        return merchant.trim().split(" ")
            .joinToString(" ") { it.replaceFirstChar { c -> c.uppercaseChar() } }
    }

    // ─────────────────────────────────────────────────────────────
    // CATEGORY ENGINE
    // ─────────────────────────────────────────────────────────────

    private fun detectCategory(merchant: String?, upi: String?, message: String): String {
        val targets = listOf(
            merchant?.lowercase() ?: "",
            upi?.lowercase() ?: "",
            message.lowercase()
        ).joinToString(" ")

        return when {
            targets.containsAny("swiggy", "zomato", "eatsure", "dominos", "mcdonalds",
                "kfc", "barbeque", "restaurant", "cafe", "food", "hunger") -> "Food"

            targets.containsAny("uber", "ola", "rapido", "irctc", "redbus",
                "makemytrip", "goibibo", "easemytrip", "metro", "fuel", "petrol",
                "diesel", "parking", "fastag", "toll") -> "Travel"

            targets.containsAny("amazon", "flipkart", "myntra", "ajio", "meesho",
                "nykaa", "tatacliq", "snapdeal", "shopsy", "zepto", "blinkit",
                "bigbasket", "grofers", "dmart", "reliance", "jiomart") -> "Shopping"

            targets.containsAny("netflix", "spotify", "youtube", "prime", "hotstar",
                "jiosaavn", "gaana", "jiocinema", "zee5", "sonyliv",
                "apple music", "subscription", "renewal") -> "Subscription"

            targets.containsAny("electricity", "water board", "gas bill", "broadband",
                "recharge", "airtel", "jio", "bsnl", "vi ", "vodafone",
                "bill", "emi", "insurance", "loan repay") -> "Bills & Utilities"

            targets.containsAny("hospital", "clinic", "pharmacy", "medplus",
                "apollo", "practo", "doctor", "medical", "health") -> "Health"

            targets.containsAny("school", "college", "university", "udemy",
                "coursera", "byju", "unacademy", "tuition", "fees") -> "Education"

            targets.containsAny("casino", "dream11", "mpl", "my11circle",
                "rummy", "poker", "gambl", "lottery") -> "Gaming & Betting"

            else -> "Others"
        }
    }

    private fun String.containsAny(vararg keywords: String) =
        keywords.any { this.contains(it) }

    // ─────────────────────────────────────────────────────────────
    // SUBSCRIPTION DETECTOR
    // ─────────────────────────────────────────────────────────────

    private val subscriptionKeywords = listOf(
        "netflix", "spotify", "youtube", "prime", "hotstar",
        "jiosaavn", "gaana", "jiocinema", "zee5", "sonyliv",
        "apple", "subscription", "renewal", "monthly plan", "annual plan"
    )

    private fun detectSubscription(merchant: String?, message: String): Boolean {
        val target = "${merchant?.lowercase() ?: ""} ${message.lowercase()}"
        return subscriptionKeywords.any { target.contains(it) }
    }

    // ─────────────────────────────────────────────────────────────
    // BANK-SPECIFIC PATTERNS  — fast-path for common Indian banks
    // ─────────────────────────────────────────────────────────────

    data class BankParseResult(
        val amount: Double,
        val type: String,
        val account: String?,
        val balance: Double?,
        val reference: String?,
        val merchant: String?
    )

    private val bankPatterns: List<Regex> = listOf(
        // HDFC: "Rs.500.00 debited from a/c XX1234 on 01-01-25. Info: SWIGGYIN. Avl Bal:Rs.10000"
        Regex(
            """(?:Rs|INR|₹)\.?\s*(?<amt>[0-9,]+\.?[0-9]*)\s+(?<type>debited|credited)\s+(?:from|to)\s+(?:a/c|acct)\s*[xX*]*(?<acct>[0-9]{4}).*?info:\s*(?<merch>[A-Za-z0-9 .&_\-]+?)(?:\.|avl|bal|\n|$)""",
            setOf(RegexOption.IGNORE_CASE, RegexOption.DOT_MATCHES_ALL)
        ),
        // SBI: "Your a/c no. XX1234 is debited for Rs. 500 on 01-01-2025. The transaction ref no. is 123456789"
        Regex(
            """a/c\s*no\.?\s*[xX*]*(?<acct>[0-9]{4})\s+is\s+(?<type>debited|credited)\s+for\s+(?:Rs|INR|₹)\.?\s*(?<amt>[0-9,]+\.?[0-9]*)""",
            setOf(RegexOption.IGNORE_CASE)
        ),
        // ICICI: "ICICI Bank Acct XX1234 debited INR 500 on 01-Jan-25; UPI:user@bank"
        Regex(
            """acct\s*[xX*]*(?<acct>[0-9]{4})\s+(?<type>debited|credited)\s+(?:INR|Rs|₹)\.?\s*(?<amt>[0-9,]+\.?[0-9]*)""",
            setOf(RegexOption.IGNORE_CASE)
        )
    )

    private fun tryBankPattern(message: String): BankParseResult? {
        for (pattern in bankPatterns) {
            val m = pattern.find(message) ?: continue
            val amt = m.groups["amt"]?.value?.replace(",", "")?.toDoubleOrNull() ?: continue
            val type = m.groups["type"]?.value?.lowercase() ?: continue
            val acct = m.groups["acct"]?.value
            val merch = m.groups["merch"]?.value?.trim()
            val balance = balanceRegex.find(message)?.groupValues?.get(1)
                ?.replace(",", "")?.toDoubleOrNull()
            val ref = refRegex.find(message)?.groupValues?.get(1)
            return BankParseResult(amt, type, acct, balance, ref, merch)
        }
        return null
    }

    // ─────────────────────────────────────────────────────────────
    // DUPLICATE HASH  — includes reference to prevent false collisions
    // ─────────────────────────────────────────────────────────────

    private fun generateHash(
        amount: Double,
        merchant: String?,
        type: String,
        reference: String?
    ): String {
        // Use reference when available for uniqueness; fall back to amount+merchant
        val input = if (reference != null) {
            "$type|$reference"
        } else {
            "$amount|$merchant|$type"
        }
        val bytes = MessageDigest.getInstance("MD5").digest(input.toByteArray())
        return bytes.joinToString("") { "%02x".format(it) }
    }

    // ─────────────────────────────────────────────────────────────
    // MAIN PARSER
    // ─────────────────────────────────────────────────────────────

    fun parse(message: String): Transaction? {
        if (!isTransactionSms(message)) return null

        val msg = message.lowercase()

        // ── Try bank-specific fast path ──
        val bankResult = tryBankPattern(message)

        val amount: Double
        val type: String
        val account: String?
        val balance: Double?
        val reference: String?
        var rawMerchant: String?

        if (bankResult != null) {
            amount      = bankResult.amount
            type        = bankResult.type
            account     = bankResult.account
            balance     = bankResult.balance
            reference   = bankResult.reference
            rawMerchant = bankResult.merchant
        } else {
            // ── Generic path ──
            amount = parseAmount(message) ?: return null
            type   = detectType(msg) ?: return null

            balance   = balanceRegex.find(message)?.groupValues?.get(1)
                ?.replace(",", "")?.toDoubleOrNull()
            reference = refRegex.find(message)?.groupValues?.get(1)
            account   = accountRegex.find(message)?.groupValues?.get(1)
            rawMerchant = extractMerchant(message)
        }

        val upi      = upiRegex.find(message)?.value
        val merchant = normalizeMerchant(rawMerchant)
            ?: upi?.substringBefore("@")?.let { normalizeMerchant(it) }

        val category     = detectCategory(merchant, upi, message)
        val subscription = detectSubscription(merchant, message)
        val hash         = generateHash(amount, merchant, type, reference)

        return Transaction(
            amount       = amount,
            type         = type,
            merchant     = merchant,
            category     = category,
            account      = account,
            balance      = balance,
            upi          = upi,
            reference    = reference,
            subscription = subscription,
            hash         = hash
        )
    }
}
