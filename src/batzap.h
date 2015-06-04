#ifndef BATZAP_H
#define BATZAP_H

#include <QObject>
#include <QUrl>
#include <QUrlQuery>
#include <QVariant>
#include <QSettings>
#include <QNetworkReply>
#include <QNetworkAccessManager>

#include "database.h"

class BatZap : public QObject
{
		Q_OBJECT
		//Q_ENUMS(RequestMethod)

		Q_PROPERTY(int port READ getPort WRITE setPort NOTIFY changedPort)
		Q_PROPERTY(QString host READ getHost WRITE setHost NOTIFY changedHost)
		Q_PROPERTY(QString user READ getUser NOTIFY changedUser)

	public:
		explicit BatZap(QObject *parent = 0);

		Q_INVOKABLE void signup(const QString &user, const QString &pass);
		Q_INVOKABLE void auth(const QString &user, const QString &pass);
		Q_INVOKABLE int getPort();
		Q_INVOKABLE void setPort(int port);
		Q_INVOKABLE QString getHost();
		Q_INVOKABLE QString getUser();
		Q_INVOKABLE void setHost(const QString& host);
		Q_INVOKABLE QVariant getLastConversations();
		Q_INVOKABLE QVariant getConversationMessages(int id, int start=0, int limit=10);

		Q_INVOKABLE int sendMessage(int conversationId, const QString& message);

		~BatZap();

	signals:
		void authResponse(bool error, QString desc);
		void signupResponse(bool error, QString desc);

		void changedPort();
		void changedHost();
		void changedUser();

		void newMessage(QVariant message);

	public slots:
		void authFinished(QObject* o);
		void signupFinished(QObject* o);
		/*void upProg(qint64 bytes, qint64 bytesTotal);
		  void downProg(qint64 bytes, qint64 bytesTotal);*/

		void getNotifications();
		void notificationsFinished(QObject* obj);
		void setNotificationsReadFinished(QObject* obj);

		void sendMessageFinished(QObject* o);

	protected:
		enum RequestMethod {
			Get = 0,
			Post,
			Delete
		};

		int port;
		QString host;
		QString token;
		QString user;
		QNetworkAccessManager man;

		QNetworkReply* createRequest(const QString& node);
		QNetworkReply* createRequest(const QString& node, QUrlQuery* query, BatZap::RequestMethod method);

		void setNotificationsTimeout(int t=3000);
		void setNotificationsRead(const QString &id);

		void setUser(const QString& u);

		QSettings settings;

		Database db;
};

#endif // BATZAP_H
