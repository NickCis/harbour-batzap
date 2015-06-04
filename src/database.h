#ifndef DATABASE_H
#define DATABASE_H

#include <QObject>
#include <QJsonObject>
#include <QSqlDatabase>

#define DATABASE_FILE "db.sqlite"

class Database : public QObject
{
		Q_OBJECT
	public:
		explicit Database(QObject *parent = 0);
		bool open();
		bool createModels();

		QVariantList getContacts();
		QVariantList getLastConversations();
		QVariantList getConversationMessages(int id, int start=0, int limit=10);

		QVariantMap getMessage(int id);

		QVariantMap getConversation(int id);

		/** @return message id */
		int insertMessage(int idConversation, const QString& message);
		bool updateMessageTime(int idmessage, int time);

		/** @return message id */
		int addMessageFromNotification(const QJsonObject & m);

	signals:

	public slots:

	protected:
		QSqlDatabase db;
		QString file;
		bool dbOpen;
		QVariantList fetchAll(QSqlQuery&) const;
		QVariantMap fetchOne(QSqlQuery&) const;

};

#endif // DATABASE_H
