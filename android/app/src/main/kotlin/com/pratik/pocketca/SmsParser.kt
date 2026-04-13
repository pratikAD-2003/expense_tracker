package com.pratik.pocketca

object SmsParser {

    data class Transaction(
        val amount: Double,
        val type: String,
        val category: String,
        val title: String,
        val rawSms: String
    )

    private val promoWords = listOf(
        "otp", "verification", "code", "loan offer", "pre-approved", 
        "apply now", "reward", "cashback offer", "promo", "discount coupon", 
        "due date", "missed call", "know your", "alert"
    )
    
    private val realTxnSignals = listOf(
        "debited", "credited", "spent", "withdrawn", "transfer", "upi", 
        "imps", "neft", "rtgs", "payment", "purchase", "received", "sent", 
        "dr ", "cr ", "deducted"
    )

    private fun isTransactionSms(message: String): Boolean {
        val msg = message.lowercase()
        val hasPromo = promoWords.any { msg.contains(it) }
        val hasTxnSignal = realTxnSignals.any { msg.contains(it) }
        return !(hasPromo && !hasTxnSignal)
    }

    private val amountRegex = Regex("""(?:rs|inr|₹)\.?\s*([0-9,]+\.?[0-9]*)""", RegexOption.IGNORE_CASE)
    private val primaryAmountRegex = Regex("""(?:debited|credited|spent|paid|received|sent|withdrawn)(?:\s+(?:for|of))?\s*(?:rs|inr|₹)?\.?\s*([0-9,]+\.?[0-9]*)""", RegexOption.IGNORE_CASE)
    
    private val debitKeywords = listOf("debited", "spent", "withdrawn", "purchase", "paid", "sent", " dr ", "debit", "deducted")
    private val creditKeywords = listOf("credited", "received", "deposit", "refund", "cashback", " cr ", "credit", "payment received")

    fun parse(message: String): Transaction? {
        if (!isTransactionSms(message)) return null

        val msg = message.lowercase()

        // 1. Extract Amount
        var amount: Double? = primaryAmountRegex.find(message)?.groupValues?.get(1)?.replace(",", "")?.toDoubleOrNull()
        if (amount == null) {
            val allAmounts = amountRegex.findAll(message).mapNotNull { it.groupValues[1].replace(",", "").toDoubleOrNull() }.toList()
            amount = allAmounts.maxOrNull() // Largest currency amount is typically the transaction amount if primary fails
        }
        if (amount == null) return null // Must have amount to be considered a valid transaction record

        // 2. Detect Type
        val isCredit = creditKeywords.any { msg.contains(it) }
        val isDebit = debitKeywords.any { msg.contains(it) }
        val type = when {
            isCredit && !isDebit -> "INCOME"
            isDebit -> "EXPENSE"
            else -> "EXPENSE" // Safest fallback
        }

        // 3. Detect Category
        val category = when {
            msg.contains("atm") || msg.contains("cash withdrawal") -> "ATM"
            msg.contains("upi") || msg.contains("vpa") -> "UPI"
            msg.contains("recharge") || msg.contains("prepaid") -> "RECHARGE"
            msg.contains("bill") || msg.contains("electricity") || msg.contains("postpaid") || msg.contains("broadband") -> "BILL"
            listOf("netflix", "spotify", "prime", "hotstar", "youtube", "subscription").any { msg.contains(it) } -> "SUBSCRIPTION"
            listOf("swiggy", "zomato", "restaurant", "food").any { msg.contains(it) } -> "FOOD"
            listOf("amazon", "flipkart", "myntra", "shopping", "mart").any { msg.contains(it) } -> "SHOPPING"
            msg.contains("card") -> "CARD"
            else -> "OTHERS"
        }

        // 4. Extract Title
        var title = "Transaction"
        val toMatch = Regex("""(?:to|info:|merchant|at)\s+([A-Za-z0-9 .]+?)(?:\s+(?:on|ref|avl|bal|upi)|$)""", RegexOption.IGNORE_CASE).find(message)
        
        if (toMatch != null && toMatch.groupValues[1].isNotBlank()) {
            title = toMatch.groupValues[1].trim()
        } else {
            val upiMatch = Regex("""([a-zA-Z0-9.\-_]+@[a-zA-Z]+)""").find(message)
            if (upiMatch != null) {
                title = upiMatch.groupValues[1].substringBefore("@")
            } else if (category == "ATM") {
                title = "ATM Withdrawal"
            }
        }
        
        val stopWords = listOf("rs", "inr", "is", "a/c", "acct", "your")
        for (stop in stopWords) {
            val idx = title.lowercase().indexOf(" $stop")
            if (idx > 0) title = title.substring(0, idx).trim()
        }
        
        title = title.replace(Regex("[^A-Za-z0-9 ]"), "").trim()
        if (title.length < 2 || title.all { it.isDigit() }) title = "Transaction"
        
        title = title.split(" ").joinToString(" ") { 
            if (it.isNotEmpty()) it.replaceFirstChar { c -> c.uppercase() } else "" 
        }

        return Transaction(
            amount = amount,
            type = type,
            category = category,
            title = title,
            rawSms = message
        )
    }
}
