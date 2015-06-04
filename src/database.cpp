#include "database.h"

#include <QDir>
#include <QDebug>
#include <QSqlQuery>
#include <QSqlError>
#include <QSqlRecord>
#include <QStandardPaths>

Database::Database(QObject *parent) :
	QObject(parent), dbOpen(false)
{
	if(!QDir().mkpath(QStandardPaths::writableLocation(QStandardPaths::DataLocation)))
		qDebug() << "No se pudo crear carpeta de datos: " << QStandardPaths::writableLocation(QStandardPaths::DataLocation);

	this->file = QDir(QStandardPaths::writableLocation(QStandardPaths::DataLocation)).filePath(DATABASE_FILE);
	this->db = QSqlDatabase::addDatabase("QSQLITE");
	this->db.setDatabaseName(this->file);
}

bool Database::open() {
	if(this->dbOpen)
		return true;

	this->dbOpen = this->db.open();

	if(!this->dbOpen)
		qDebug() << this->db.lastError().text();

	return this->dbOpen;
}

bool Database::createModels() {
	QSqlQuery q(this->db);
	bool ret;
	ret = q.exec(
		"CREATE TABLE IF NOT EXISTS contacts ( "
			"id INTEGER PRIMARY KEY, "
			"username TEXT UNIQUE, "
			"nickname TEXT, "
			"online INTEGER "
		")"
	);

	if(!ret){
		qDebug() << q.lastError();
		return false;
	}

	ret = q.exec(
		"CREATE TABLE IF NOT EXISTS conversations ( "
			"id INTEGER PRIMARY KEY, "
			"name INTEGER UNIQUE "
		")"
	);

	if(!ret){
		qDebug() << q.lastError();
		return false;
	}

	ret = q.exec(
		"CREATE TABLE IF NOT EXISTS messages ( "
			"id INTEGER PRIMARY KEY, "
			"real_id TEXT, "
			"time INTEGER, "
			"arrived INTEGER, "
			"read INTEGER, "
			"message TEXT, "
			"idcontact INTEGER, "
			"idconversation INTEGER, "
			"file TEXT, "
			"file_type INTEGER, "
			"FOREIGN KEY(idcontact) REFERENCES contacts(id), "
			"FOREIGN KEY(idconversation) REFERENCES conversations(id) "
		")"
	);

	if(!ret){
		qDebug() << q.lastError();
		return false;
	}

	return true;
}


QVariantList Database::fetchAll(QSqlQuery& q) const{
	QVariantList list;

	if(!q.exec()){
		qDebug() << this->db.lastError();
		qDebug() << q.lastError();
		qDebug() << "Query: " << q.lastQuery();
		return list;
	}

	while(q.next()){
		QVariantMap map;
		QSqlRecord record = q.record();
		for(int i=0; i < record.count(); ++i)
			map.insert(record.fieldName(i), record.value(i));

		list.append(map);
	}

	return list;
}

QVariantMap Database::fetchOne(QSqlQuery& q) const{
	if(!q.exec()){
		qDebug() << this->db.lastError();
		qDebug() << q.lastError();
		qDebug() << "Query: " << q.lastQuery();
		return QVariantMap();
	}

	if(!q.next())
		return QVariantMap();

	QVariantMap map;
	QSqlRecord record = q.record();
	for(int i=0; i < record.count(); ++i)
		map.insert(record.fieldName(i), record.value(i));

	return map;
}

QVariantList Database::getLastConversations(){
	QSqlQuery q(this->db);
	q.prepare(
		"SELECT "
			"time, "
			"message, "
			"idcontact, "
			"idconversation, "
			"name, "
			"username "
		"FROM messages "
		"JOIN conversations ON idconversation = conversations.id "
		"LEFT JOIN contacts on idcontact = contacts.id "
		"GROUP BY idconversation "
		"ORDER BY time DESC");
	return this->fetchAll(q);
}

QVariantList Database::getContacts(){
	QSqlQuery q(this->db);
	q.prepare("SELECT id, username, nickname, online FROM contacts");
	return this->fetchAll(q);
}

int Database::addMessageFromNotification(const QJsonObject & m){
	QSqlQuery q(this->db);
	QString username = m.value("from").toString();
	q.prepare("INSERT OR IGNORE INTO conversations (name) VALUES (:name)");
	q.bindValue(":name", username);
	if(!q.exec()){
		qDebug() << "Fallo crear el contacto: " << q.lastError();
		return 0;
	}

	q.prepare("INSERT OR IGNORE INTO contacts (username) VALUES (:name)");
	q.bindValue(":name", username);
	if(!q.exec()){
		qDebug() << "Fallo crear la conversacion: " << q.lastError();
		return 0;
	}

	q.prepare(
		"INSERT INTO messages ( "
			"time, "
			"message, "
			"idcontact, "
			"idconversation "
		") SELECT "
		  ":time, "
		  ":message, "
		  "contacts.id, "
		  "conversations.id "
		"FROM "
			"contacts, conversations "
		"WHERE "
			"contacts.username = :name AND conversations.name = :name"
	);

	// TODO: resto de valores
	q.bindValue(":time", m.value("time").toInt());
	q.bindValue(":message", m.value("message").toString());
	q.bindValue(":name", username);

	if(!q.exec()){
		qDebug() << "Fallo al insertar el mensaje: " << q.lastError();
		qDebug() << "Query: " << q.lastQuery();
		return 0;
	}

	return q.lastInsertId().toInt();
}

QVariantList Database::getConversationMessages(int id, int start, int limit){
	QSqlQuery q(this->db);
	q.prepare(
		"SELECT "
			"messages.id as id, "
			"messages.real_id as real_id, "
			"messages.time as time, "
			"messages.arrived as arrived, "
			"messages.read as read, "
			"messages.message as message, "
			"messages.idcontact as idcontact, "
			"contacts.username as `from`, "
			"contacts.nickname as from_nickname, "
			"messages.file as file, "
			"messages.file_type as file_type "
		"FROM messages "
		"LEFT JOIN contacts ON messages.idcontact = contacts.id "
		"WHERE messages.idconversation = :idconversation "
		"ORDER BY "
			"messages.time DESC, "
			"messages.id DESC "
		//"LIMIT :start, :limit"
	);
	q.bindValue(":idconversation", id);
	q.bindValue(":start", start);
	q.bindValue(":limit", limit);

	return this->fetchAll(q);
}


QVariantMap Database::getMessage(int id){
	QSqlQuery q(this->db);
	q.prepare(
		"SELECT "
			"messages.id as id, "
			"messages.real_id as real_id, "
			"messages.time as time, "
			"messages.arrived as arrived, "
			"messages.read as read, "
			"messages.message as message, "
			"messages.idcontact as idcontact, "
			"messages.idconversation as idconversation, "
			"contacts.username as `from`, "
			"contacts.nickname as from_nickname, "
			"messages.file as file, "
			"messages.file_type as file_type, "
			"conversations.name as name "
		"FROM messages "
		"LEFT JOIN contacts ON messages.idcontact = contacts.id "
		"LEFT JOIN conversations ON messages.idconversation = conversations.id "
		"WHERE messages.id = :idmessage "
	);
	q.bindValue(":idmessage", id);

	return this->fetchOne(q);
}

QVariantMap Database::getConversation(int id){
	QSqlQuery q(this->db);
	q.prepare(
		"SELECT "
			"conversations.id as id, "
			"conversations.name as name "
		"FROM conversations "
		"WHERE conversations.id = :id "
	);
	q.bindValue(":id", id);

	return this->fetchOne(q);
}

int Database::insertMessage(int idConversation, const QString& message){
	QSqlQuery q(this->db);
	q.prepare(
		"INSERT INTO messages ( "
			"message, "
			"idconversation "
		") VALUES ( "
			":message, "
			":idconversation "
		")"
	);
	q.bindValue(":message", message);
	q.bindValue(":idconversation", idConversation);

	if(!q.exec()){
		qDebug() << q.lastError();
		qDebug() << "Query: " << q.lastQuery();
		return 0;
	}

	return q.lastInsertId().toInt();
}

bool Database::updateMessageTime(int idMessage, int time){
	QSqlQuery q(this->db);
	q.prepare(
		"UPDATE messages "
		"SET "
			"time = :time "
		"WHERE "
			"id = :id "
	);
	q.bindValue(":time", time);
	q.bindValue(":id", idMessage);

	if(!q.exec()){
		qDebug() << q.lastError();
		qDebug() << "Query: " << q.lastQuery();
		return false;
	}

	return true;
}
