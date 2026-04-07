/*
package com.pratik.expense_tracker

import android.content.ContentValues
import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper

class SmsDatabase(context: Context) :
    SQLiteOpenHelper(context, "sms_db", null, 1) {

    override fun onCreate(db: SQLiteDatabase) {

        db.execSQL(
            """
            CREATE TABLE transactions(
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                sender TEXT,
                amount REAL,
                type TEXT,
                message TEXT,
                time INTEGER,
                synced INTEGER DEFAULT 0
            )
            """
        )
    }

    override fun onUpgrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) {}

    fun insertTransaction(
        sender: String,
        amount: Double,
        type: String,
        message: String,
        time: Long
    ) {

        val db = writableDatabase

        val values = ContentValues()

        values.put("sender", sender)
        values.put("amount", amount)
        values.put("type", type)
        values.put("message", message)
        values.put("time", time)
        values.put("synced", 0)

        db.insert("transactions", null, values)
    }

    fun getUnsynced(): List<Map<String, Any>> {

        val list = mutableListOf<Map<String, Any>>()

        val db = readableDatabase

        val cursor = db.rawQuery(
            "SELECT * FROM transactions WHERE synced = 0",
            null
        )

        while (cursor.moveToNext()) {

            val map = HashMap<String, Any>()

            map["id"] = cursor.getInt(0)
            map["sender"] = cursor.getString(1)
            map["amount"] = cursor.getDouble(2)
            map["type"] = cursor.getString(3)
            map["message"] = cursor.getString(4)
            map["time"] = cursor.getLong(5)

            list.add(map)
        }

        cursor.close()

        return list
    }

    fun markSynced(id: Int) {

        val db = writableDatabase

        val values = ContentValues()

        values.put("synced", 1)

        db.update("transactions", values, "id=?", arrayOf(id.toString()))
    }
}*/
package com.pratik.expense_tracker

import android.content.ContentValues
import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper

class SmsDatabase(context: Context) :
    SQLiteOpenHelper(context, "sms_db", null, 2) {

    override fun onCreate(db: SQLiteDatabase) {

        db.execSQL(
            """
            CREATE TABLE transactions(
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                sender TEXT,
                amount REAL,
                type TEXT,
                merchant TEXT,
                category TEXT,
                account TEXT,
                balance REAL,
                message TEXT,
                time INTEGER,
                hash TEXT UNIQUE,
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

        if (oldVersion < 2) {

            db.execSQL("ALTER TABLE transactions ADD COLUMN merchant TEXT")
            db.execSQL("ALTER TABLE transactions ADD COLUMN category TEXT")
            db.execSQL("ALTER TABLE transactions ADD COLUMN account TEXT")
            db.execSQL("ALTER TABLE transactions ADD COLUMN balance REAL")
            db.execSQL("ALTER TABLE transactions ADD COLUMN hash TEXT")
        }
    }

    fun insertTransaction(
        sender: String,
        amount: Double,
        type: String,
        merchant: String?,
        category: String?,
        account: String?,
        balance: Double?,
        message: String,
        time: Long,
        hash: String
    ) {

        val db = writableDatabase

        val values = ContentValues().apply {

            put("sender", sender)
            put("amount", amount)
            put("type", type)
            put("merchant", merchant)
            put("category", category)
            put("account", account)
            put("balance", balance)
            put("message", message)
            put("time", time)
            put("hash", hash)
            put("synced", 0)
        }

        db.insertWithOnConflict(
            "transactions",
            null,
            values,
            SQLiteDatabase.CONFLICT_IGNORE
        )
    }

    fun getUnsynced(): List<Map<String, Any?>> {

        val list = mutableListOf<Map<String, Any?>>()

        val db = readableDatabase

        val cursor = db.rawQuery(
            "SELECT * FROM transactions WHERE synced = 0 ORDER BY time DESC",
            null
        )

        while (cursor.moveToNext()) {

            val map = HashMap<String, Any?>()

            map["id"] = cursor.getInt(cursor.getColumnIndexOrThrow("id"))
            map["sender"] = cursor.getString(cursor.getColumnIndexOrThrow("sender"))
            map["amount"] = cursor.getDouble(cursor.getColumnIndexOrThrow("amount"))
            map["type"] = cursor.getString(cursor.getColumnIndexOrThrow("type"))
            map["merchant"] = cursor.getString(cursor.getColumnIndexOrThrow("merchant"))
            map["category"] = cursor.getString(cursor.getColumnIndexOrThrow("category"))
            map["account"] = cursor.getString(cursor.getColumnIndexOrThrow("account"))
            map["balance"] = cursor.getDouble(cursor.getColumnIndexOrThrow("balance"))
            map["message"] = cursor.getString(cursor.getColumnIndexOrThrow("message"))
            map["time"] = cursor.getLong(cursor.getColumnIndexOrThrow("time"))

            list.add(map)
        }

        cursor.close()

        return list
    }

    fun markSynced(id: Int) {

        val db = writableDatabase

        val values = ContentValues()

        values.put("synced", 1)

        db.update(
            "transactions",
            values,
            "id=?",
            arrayOf(id.toString())
        )
    }
}