#include "batzap.h"

#include <QTimer>
#include <QDebug>
#include <QJsonValue>
#include <QJsonArray>
#include <QJsonObject>
#include <QJsonValueRef>
#include <QJsonDocument>
#include <QSignalMapper>

#include "harbour-batzap.h"

//Q_DECLARE_METATYPE(QNetworkReply*)

BatZap::BatZap(QObject *parent) :
	QObject(parent),
	port(8000),
	host("localhost"),
	token(""),
	user(""),
	settings(ORGANIZATION_NAME, APPLICATION_NAME),
	db(this)
{
	qDebug() << "setting file: "<< this->settings.fileName();
	this->host = this->settings.value("server/host", this->host).toString();
	this->port = this->settings.value("server/port", this->port).toInt();

	// XXX: check errors!
	this->db.open();
	this->db.createModels();
}

void BatZap::auth(const QString &user, const QString &pass){
	qDebug() << "auth: " << user << " " << pass;

	QUrlQuery query;
	query.addQueryItem(QStringLiteral("user"), user);
	query.addQueryItem(QStringLiteral("pass"), pass);
	this->setUser(user);
	QNetworkReply* reply = this->createRequest(QStringLiteral("auth"), &query, BatZap::Post);
	QSignalMapper *mapper = new QSignalMapper(reply);
	connect(reply, SIGNAL(finished()), mapper, SLOT(map()));
	mapper->setMapping(reply, reply);
	connect(mapper, SIGNAL(mapped(QObject*)), this, SLOT(authFinished(QObject*)));
}

void BatZap::setUser(const QString& u){
	this->user = u;
	emit changedUser();
}

void BatZap::signup(const QString &user, const QString &pass){
	qDebug() << "register: " << user << " " << pass;
	QUrlQuery query;
	query.addQueryItem(QStringLiteral("user"), user);
	query.addQueryItem(QStringLiteral("pass"), pass);
	QNetworkReply* reply = this->createRequest(QStringLiteral("signup"), &query, BatZap::Post);
	QSignalMapper *mapper = new QSignalMapper(reply);
	connect(reply, SIGNAL(finished()), mapper, SLOT(map()));
	mapper->setMapping(reply, reply);
	connect(mapper, SIGNAL(mapped(QObject*)), this, SLOT(signupFinished(QObject*)));
}

int BatZap::getPort(){
	return port;
}

void BatZap::setPort(int port){
	this->port = port;
	this->settings.setValue("server/port", this->port);
	emit changedPort();
}

QString BatZap::getHost(){
	return host;
}

QString BatZap::getUser(){
	return user;
}

void BatZap::setHost(const QString& host){
	this->host = host;
	this->settings.setValue("server/host", this->host);
	emit changedHost();
}

QNetworkReply* BatZap::createRequest(const QString& node){
	QUrlQuery query;
	query.addQueryItem(QStringLiteral("access_token"), this->token);
	return this->createRequest(node, &query, BatZap::Get);
}

QNetworkReply* BatZap::createRequest(const QString& node, QUrlQuery *query, BatZap::RequestMethod method){
	QNetworkRequest request;
	QNetworkReply* reply;

	QString urlStr("http://%1:%2/%3");
	urlStr = urlStr.arg(this->host).arg(this->port).arg(node);
	qDebug() << "url: " << urlStr;

	QUrl url(urlStr);

	request.setRawHeader("User-Agent", "BatZap-Client 0.1");

	if(method == BatZap::Post){
		request.setUrl(url);
		request.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-www-form-urlencoded");
		if(query){
			qDebug()<< "Mando post!";
			reply = this->man.post(request, query->toString(QUrl::FullyEncoded).toUtf8());
		}else{
			QByteArray data;
			reply = this->man.post(request, data);
		}
	}else{
		if(query)
			url.setQuery(*query);
		request.setUrl(url);
		if(method == BatZap::Delete)
			reply = this->man.deleteResource(request);
		else
			reply = this->man.get(request);
	}

	/*connect(reply, SIGNAL(finished()), req, SLOT(finished()));
	  connect(reply, SIGNAL(uploadProgress(qint64, qint64)), req, SLOT(upProg(qint64, qint64)));
	  connect(reply, SIGNAL(downloadProgress(qint64,qint64)), req, SLOT(downProg(qint64,qint64)));*/

	return reply;
}

void BatZap::authFinished(QObject* obj){
	QNetworkReply* reply = qobject_cast<QNetworkReply*>(obj);
	QNetworkReply::NetworkError err = reply->error();

	if(err != QNetworkReply::NoError){
		//TODO: check if there is an apiError!
		qDebug() << "Fallo el request n: " << err << " str: '" << reply->errorString() << "'";
		emit authResponse(true, reply->errorString());
		return;
	}

	QByteArray data = reply->readAll();
	QJsonDocument dataDoc(QJsonDocument::fromJson(data));
	this->token = dataDoc.object().value("access_token").toString();
	qDebug() << "New token: " << this->token;

	emit authResponse(false, "");
	reply->close();
	reply->deleteLater();

	this->setNotificationsTimeout();
}

void BatZap::signupFinished(QObject* obj){
	QNetworkReply* reply = qobject_cast<QNetworkReply*>(obj);
	QNetworkReply::NetworkError err = reply->error();
	qDebug() << "signupFinished!";

	if(err != QNetworkReply::NoError){ // TODO: liberar si error!
		int retCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt(0);
		qDebug() << "Fallo el request networkerror: " << err << " str: '" << reply->errorString() << "'";
		QString response(reply->readAll());
		qDebug() << "Http code: " << retCode << "response: " << response;
		emit signupResponse(true, reply->errorString());
		return;
	}

	//QByteArray data = reply->readAll();
	//qDebug() << "End request -- " /*<< data*/;
	//QJsonDocument dataDoc(QJsonDocument::fromJson(data));
	//dataDoc.toVariant()

	//TODO: check if there is an apiError!
	emit signupResponse(false, "");
	reply->close();
	reply->deleteLater();
}


QVariant BatZap::getLastConversations(){
	/*QVariantList list;

#define ADD_MSG(id, from, message, time, weekDaySection) {\
	QVariantMap obj;\
	obj.insert("id", id); \
	obj.insert("from", from); \
	obj.insert("message", message); \
	obj.insert("time", time); \
	obj.insert("weekDaySection", weekDaySection); \
	list << obj; \
}

	ADD_MSG(1, "pepe", "hola", 1431056350, "Today");
	ADD_MSG(3, "adsasd", "otro mensaje largo", 1431056357, "Yesterday");

#undef ADD_MSG

	return QVariant::fromValue(list);*/
	return QVariant::fromValue(this->db.getLastConversations());
}

BatZap::~BatZap() { qDebug() << "detroy"; }

void BatZap::getNotifications() {
	QNetworkReply* reply = this->createRequest(QStringLiteral("notification"));
	QSignalMapper *mapper = new QSignalMapper(reply);
	connect(reply, SIGNAL(finished()), mapper, SLOT(map()));
	mapper->setMapping(reply, reply);
	connect(mapper, SIGNAL(mapped(QObject*)), this, SLOT(notificationsFinished(QObject*)));
}


void BatZap::notificationsFinished(QObject* obj){
	QNetworkReply* reply = qobject_cast<QNetworkReply*>(obj);
	QNetworkReply::NetworkError err = reply->error();

	// TODO: si hay error deja de pedir notificaciones!
	if(err != QNetworkReply::NoError){
		//TODO: check if there is an apiError!
		qDebug() << "Fallo el request n: " << err << " str: '" << reply->errorString() << "'";
		return;
	}

	QString lastNotificationId = "";
	QByteArray data = reply->readAll();
	QJsonDocument dataDoc(QJsonDocument::fromJson(data));
	QJsonObject response = dataDoc.object();
	QJsonArray notifications = response.value("notifications").toArray();
	for(QJsonArray::iterator it = notifications.begin(); it != notifications.end(); it++){
		QJsonObject notif = (*it).toObject();
		QString type = notif.value("type").toString();
		if(type == "message"){
			int messageId = this->db.addMessageFromNotification(notif.value("data").toObject());
			emit newMessage(QVariant(this->db.getMessage(messageId)));
		}else if(type == "ack"){
			qDebug() << "Notificacion ack TBD";
		} else {
			qDebug() << "Notificacion tipo: '" << type << "'' desconocida";
		}
		lastNotificationId = notif.value("id").toString();
	}


	reply->close();
	reply->deleteLater();

	if(lastNotificationId.length())
		this->setNotificationsRead(lastNotificationId);
	else
		this->setNotificationsTimeout();

}


void BatZap::setNotificationsTimeout(int t){
	QTimer::singleShot(t, this, SLOT(getNotifications()));
}

void BatZap::setNotificationsRead(const QString& id){
	QUrlQuery query;
	query.addQueryItem(QStringLiteral("access_token"), this->token);
	query.addQueryItem(QStringLiteral("id"), id);

	QNetworkReply* reply = this->createRequest(QStringLiteral("notification"), &query, BatZap::Delete);
	QSignalMapper *mapper = new QSignalMapper(reply);
	connect(reply, SIGNAL(finished()), mapper, SLOT(map()));
	mapper->setMapping(reply, reply);
	connect(mapper, SIGNAL(mapped(QObject*)), this, SLOT(setNotificationsReadFinished(QObject*)));
}

void BatZap::setNotificationsReadFinished(QObject* obj){
	QNetworkReply* reply = qobject_cast<QNetworkReply*>(obj);
	//QNetworkReply::NetworkError err = reply->error();

	/*// TODO: si hay error deja de pedir notificaciones!
	if(err != QNetworkReply::NoError){
		//TODO: check if there is an apiError!
		qDebug() << "Fallo el request n: " << err << " str: '" << reply->errorString() << "'";
		return;
	}*/

	reply->close();
	reply->deleteLater();

	this->setNotificationsTimeout();
}

QVariant BatZap::getConversationMessages(int id, int start, int limit){
	return this->db.getConversationMessages(id, start, limit);
}

int BatZap::sendMessage(int idConversation, const QString &message){
	qDebug() << "send message: " << idConversation << " " << message;
	QVariantMap conversation = this->db.getConversation(idConversation);
	if(conversation.value("id").toInt() != idConversation)
		return 0;

	int messageId = this->db.insertMessage(idConversation, message);
	if(messageId == 0)
		return 0;

	QString url("/user/%1/messages");
	url = url.arg(conversation.value("name").toString());

	QUrlQuery query;
	query.addQueryItem(QStringLiteral("access_token"), this->token);
	query.addQueryItem(QStringLiteral("message"), message);

	QNetworkReply* reply = this->createRequest(url, &query, BatZap::Post);
	QSignalMapper *mapper = new QSignalMapper(reply);

	connect(reply, SIGNAL(finished()), mapper, SLOT(map()));

	reply->setProperty("messageId", messageId);
	mapper->setMapping(reply, reply);

	connect(mapper, SIGNAL(mapped(QObject*)), this, SLOT(sendMessageFinished(QObject*)));
	return messageId;
}


void BatZap::sendMessageFinished(QObject* obj){
	QNetworkReply* reply = qobject_cast<QNetworkReply*>(obj);
	int messageId = reply->property("messageId").toInt();

	QNetworkReply::NetworkError err = reply->error();
	qDebug() << "sendMessageFinished!";

	if(err != QNetworkReply::NoError){ // TODO: liberar si error!
		int retCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt(0);
		qDebug() << "Fallo el request networkerror: " << err << " str: '" << reply->errorString() << "'";
		QString response(reply->readAll());
		qDebug() << "Http code: " << retCode << "response: " << response;
		return;
	}

	QByteArray data = reply->readAll();
	QJsonDocument dataDoc(QJsonDocument::fromJson(data));
	QJsonObject response = dataDoc.object();
	this->db.updateMessageTime(messageId, response.value("time").toInt());

	reply->close();
	reply->deleteLater();
}
