package com.pratik.pocketca

import android.content.ContentValues
import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper

class SmsDatabase(context: Context) :
    SQLiteOpenHelper(context, "sms_db", null, 3) {

    override fun onCreate(db: SQLiteDatabase) {
        db.execSQL(
            """
            CREATE TABLE transactions(
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                type TEXT,
                category TEXT,
                amount REAL,
                title TEXT,
                dateTime TEXT,
                source TEXT,
                rawSms TEXT,
                synced INTEGER DEFAULT 0
            )
            """
        )
    }

    override fun onUpgrade(
        db: SQLiteDatabase,
        oldVersion: Int,
        newVersion: Int
    ) {
        if (oldVersion < 3) {
            try { db.execSQL("ALTER TABLE transactions ADD COLUMN title TEXT") } catch (e: Exception) {}
            try { db.execSQL("ALTER TABLE transactions ADD COLUMN dateTime TEXT") } catch (e: Exception) {}
            try { db.execSQL("ALTER TABLE transactions ADD COLUMN source TEXT") } catch (e: Exception) {}
            try { db.execSQL("ALTER TABLE transactions ADD COLUMN rawSms TEXT") } catch (e: Exception) {}

            db.execSQL("UPDATE transactions SET title = merchant WHERE title IS NULL AND merchant IS NOT NULL")
            db.execSQL("UPDATE transactions SET title = sender WHERE title IS NULL AND merchant IS NULL")
            db.execSQL("UPDATE transactions SET dateTime = CAST(time AS TEXT) WHERE dateTime IS NULL")
            db.execSQL("UPDATE transactions SET source = 'SMS' WHERE source IS NULL")
            db.execSQL("UPDATE transactions SET rawSms = message WHERE rawSms IS NULL")
            
            db.execSQL("UPDATE transactions SET type = 'EXPENSE' WHERE LOWER(type) = 'debit'")
            db.execSQL("UPDATE transactions SET type = 'INCOME' WHERE LOWER(type) = 'credit'")
        }
    }

    fun insertTransaction(
        type: String,
        category: String,
        amount: Double,
        title: String,
        dateTime: String,
        source: String,
        rawSms: String
    ): Long {
        val db = writableDatabase
        val values = ContentValues().apply {
            put("type", type)
            put("category", category)
            put("amount", amount)
            put("title", title)
            put("dateTime", dateTime)
            put("source", source)
            put("rawSms", rawSms)
            put("synced", 0)
        }
        return db.insertWithOnConflict(
            "transactions",
            null,
            values,
            SQLiteDatabase.CONFLICT_IGNORE
        )
    }

    fun updateTransaction(
        id: Int,
        type: String,
        category: String,
        amount: Double,
        title: String,
        dateTime: String
    ): Int {
        val db = writableDatabase
        val values = ContentValues().apply {
            put("type", type)
            put("category", category)
            put("amount", amount)
            put("title", title)
            put("dateTime", dateTime)
        }
        return db.update("transactions", values, "id=?", arrayOf(id.toString()))
    }

    fun deleteTransaction(id: Int): Int {
        val db = writableDatabase
        return db.delete("transactions", "id=?", arrayOf(id.toString()))
    }

    fun getUnsynced(): List<Map<String, Any?>> {
        val list = mutableListOf<Map<String, Any?>>()
        val db = readableDatabase
        
        val cursor = db.rawQuery(
            "SELECT id, type, category, amount, title, dateTime, source, rawSms FROM transactions ORDER BY id DESC",
            null
        )

        while (cursor.moveToNext()) {
            val map = HashMap<String, Any?>()
            map["id"] = cursor.getInt(cursor.getColumnIndexOrThrow("id"))
            map["type"] = cursor.getString(cursor.getColumnIndexOrThrow("type"))
            map["category"] = cursor.getString(cursor.getColumnIndexOrThrow("category"))
            map["amount"] = cursor.getDouble(cursor.getColumnIndexOrThrow("amount"))
            map["title"] = cursor.getString(cursor.getColumnIndexOrThrow("title"))
            map["dateTime"] = cursor.getString(cursor.getColumnIndexOrThrow("dateTime"))
            map["source"] = cursor.getString(cursor.getColumnIndexOrThrow("source"))
            map["rawSms"] = cursor.getString(cursor.getColumnIndexOrThrow("rawSms"))
            list.add(map)
        }
        cursor.close()
        return list
    }

    fun markSynced(id: Int) {
        val db = writableDatabase
        val values = ContentValues().apply { put("synced", 1) }
        db.update("transactions", values, "id=?", arrayOf(id.toString()))
    }
}
