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
        "due date", "missed call", "know your", "alert", "click to", "congratulations"
    )
    
    private val realTxnSignals = listOf(
        "debited", "credited", "spent", "withdrawn", "transfer", "upi", 
        "imps", "neft", "rtgs", "payment", "purchase", "received", "sent", 
        "dr ", "cr ", "deducted", "trf", "txn"
    )

    private fun isTransactionSms(message: String): Boolean {
        val msg = message.lowercase()
        val hasPromo = promoWords.any { msg.contains(it) }
        val hasTxnSignal = realTxnSignals.any { msg.contains(it) }
        
        // If it has txn signals and looks like a real alert (contains account/balance info), keep it
        if (hasTxnSignal && (msg.contains("a/c") || msg.contains("acct") || msg.contains("bal") || msg.contains("avl"))) return true
        
        return !(hasPromo && !hasTxnSignal)
    }

    private val amountRegex = Regex("""(?i)(?:rs|inr|₹)\.?\s*([0-9,]+\.?[0-9]*)""")
    private val balanceRegex = Regex("""(?i)(?:avl|available|bal|balance|limit|bal[:\s]|updated|new)\s*(?:rs|inr|₹)?\.?\s*([0-9,]+\.?[0-9]*)""")
    
    private val primaryAmountRegexes = listOf(
        // Keyword followed by Amount: "debited for Rs 500", "spent 100"
        Regex("""(?i)(?:debited|credited|spent|paid|received|sent|withdrawn|deducted|trf|txn of)(?:\s+(?:for|of|by|from|to))?\s*(?:rs|inr|₹)?\.?\s*([0-9,]+\.?[0-9]*)"""),
        // Amount followed by Keyword: "Rs 500 debited", "100 spent"
        Regex("""(?i)(?:rs|inr|₹)?\.?\s*([0-9,]+\.?[0-9]*)\s+(?:debited|credited|spent|paid|received|sent|withdrawn|deducted|trf)""")
    )
    
    private val debitKeywords = listOf("debited", "spent", "withdrawn", "purchase", "paid", "sent", " dr ", "debit", "deducted")
    private val creditKeywords = listOf("credited", "received", "deposit", "refund", "cashback", " cr ", "credit", "payment received")

    fun parse(message: String): Transaction? {
        if (!isTransactionSms(message)) return null

        val msg = message.lowercase()

        // 1. Extract Amount
        var amount: Double? = null
        
        // Try primary regexes (contextual)
        for (regex in primaryAmountRegexes) {
            val match = regex.find(message)
            if (match != null) {
                amount = match.groupValues[1].replace(",", "").toDoubleOrNull()
                if (amount != null) break
            }
        }

        // Fallback: Find all amounts and exclude balance amounts
        if (amount == null) {
            val balanceAmounts = balanceRegex.findAll(message).map { it.groupValues[1].replace(",", "") }.toSet()
            val allAmounts = amountRegex.findAll(message)
                .map { it.groupValues[1].replace(",", "") }
                .filter { it !in balanceAmounts }
                .mapNotNull { it.toDoubleOrNull() }
                .toList()
            
            amount = allAmounts.firstOrNull()
        }
        
        if (amount == null) return null

        // 2. Detect Type
        val isCredit = creditKeywords.any { msg.contains(it) }
        val isDebit = debitKeywords.any { msg.contains(it) }
        val type = when {
            isCredit && !isDebit -> "INCOME"
            isDebit -> "EXPENSE"
            else -> "EXPENSE" 
        }

        // 3. Detect Category
        val category = detectCategory(msg)

        // 4. Extract Title
        val title = extractTitle(message, category)

        return Transaction(
            amount = amount,
            type = type,
            category = category,
            title = title,
            rawSms = message
        )
    }

    private fun detectCategory(msg: String): String {
        return when {
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
    }

    private fun extractTitle(message: String, category: String): String {
        // Priority prefixes for title extraction
        val prefixes = listOf("merchant", "at", "info:", "trf to", "to", "by", "from")
        
        for (prefix in prefixes) {
            val regex = Regex("""(?i)$prefix\s+([A-Za-z0-9 ./-]{2,})(?:\s+(?:on|at|ref|refno|avl|bal|upi|vpa|from|if|is|for|trf)|$)""")
            val match = regex.find(message)
            if (match != null) {
                var candidate = match.groupValues[1].trim()
                
                // Skip generic account titles
                if (candidate.lowercase().startsWith("a/c") || candidate.lowercase().startsWith("acct")) {
                    continue
                }
                
                // Clean up method prefixes like UPI/ or NEFT/
                val cleanRegex = Regex("""(?i)^(?:upi|neft|imps|rtgs|trf)/""")
                candidate = candidate.replace(cleanRegex, "")
                
                if (candidate.length >= 2) {
                    return formatTitle(candidate)
                }
            }
        }

        val upiMatch = Regex("""([a-zA-Z0-9.\-_]+@[a-zA-Z]+)""").find(message)
        if (upiMatch != null) {
            return formatTitle(upiMatch.groupValues[1].substringBefore("@"))
        }

        return when (category) {
            "ATM" -> "ATM Withdrawal"
            "UPI" -> "UPI Transaction"
            else -> "Transaction"
        }
    }

    private fun formatTitle(title: String): String {
        var t = title
        val stopWords = listOf("rs", "inr", "is", "a/c", "acct", "your", "by", "debited", "credited", "refno", "on", "at")
        for (stop in stopWords) {
            val lower = t.lowercase()
            val idx = lower.indexOf(" $stop ")
            if (idx != -1) {
                t = t.substring(0, idx).trim()
            } else if (lower.endsWith(" $stop")) {
                t = t.substring(0, t.length - stop.length - 1).trim()
            }
        }
        
        t = t.replace(Regex("[^A-Za-z0-9 ]"), "").trim()
        
        if (t.length < 2 || t.all { it.isDigit() }) return "Transaction"
        
        return t.split(" ").filter { it.isNotBlank() }.joinToString(" ") { word ->
            word.lowercase().replaceFirstChar { if (it.isLowerCase()) it.titlecase() else it.toString() }
        }
    }
}
