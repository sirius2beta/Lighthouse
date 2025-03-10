#include "dnqmlobjectlistmodel.h"

#include <QDebug>
#include <QQmlEngine>


const int DNQmlObjectListModel::ObjectRole = Qt::UserRole;
const int DNQmlObjectListModel::TextRole = Qt::UserRole + 1;

DNQmlObjectListModel::DNQmlObjectListModel(QObject* parent)
    : QAbstractListModel        (parent)
    , _dirty                    (false)
    , _skipDirtyFirstItem       (false)
    , _externalBeginResetModel  (false)
{

}

DNQmlObjectListModel::~DNQmlObjectListModel()
{

}

QObject* DNQmlObjectListModel::get(int index)
{
    if (index < 0 || index >= _objectList.count()) {
        return nullptr;
    }
    return _objectList[index];
}

int DNQmlObjectListModel::rowCount(const QModelIndex& parent) const
{
    Q_UNUSED(parent);

    return _objectList.count();
}

QVariant DNQmlObjectListModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid()) {
        return QVariant();
    }

    if (index.row() < 0 || index.row() >= _objectList.count()) {
        return QVariant();
    }

    if (role == ObjectRole) {
        return QVariant::fromValue(_objectList[index.row()]);
    } else if (role == TextRole) {
        return QVariant::fromValue(_objectList[index.row()]->objectName());
    } else {
        return QVariant();
    }
}

QHash<int, QByteArray> DNQmlObjectListModel::roleNames(void) const
{
    QHash<int, QByteArray> hash;

    hash[ObjectRole] = "object";
    hash[TextRole] = "text";

    return hash;
}

bool DNQmlObjectListModel::setData(const QModelIndex& index, const QVariant& value, int role)
{
    if (index.isValid() && role == ObjectRole) {
        _objectList.replace(index.row(), value.value<QObject*>());
        emit dataChanged(index, index);
        return true;
    }

    return false;
}

bool DNQmlObjectListModel::insertRows(int position, int rows, const QModelIndex& parent)
{
    Q_UNUSED(parent);

    if (position < 0 || position > _objectList.count() + 1) {
        qWarning() << "Invalid position position:count" << position << _objectList.count();
    }

    beginInsertRows(QModelIndex(), position, position + rows - 1);
    endInsertRows();

    emit countChanged(count());

    return true;
}

bool DNQmlObjectListModel::removeRows(int position, int rows, const QModelIndex& parent)
{
    Q_UNUSED(parent);

    if (position < 0 || position >= _objectList.count()) {
        qWarning() << "Invalid position position:count" << position << _objectList.count();
    } else if (position + rows > _objectList.count()) {
        qWarning() << "Invalid rows position:rows:count" << position << rows << _objectList.count();
    }

    beginRemoveRows(QModelIndex(), position, position + rows - 1);
    for (int row=0; row<rows; row++) {
        _objectList.removeAt(position);
    }
    endRemoveRows();

    emit countChanged(count());

    return true;
}

void DNQmlObjectListModel::move(int from, int to)
{
    if(0 <= from && from < count() && 0 <= to && to < count() && from != to) {
        // Workaround to allow move item to the bottom. Done according to
        // beginMoveRows() documentation and implementation specificity:
        // https://doc.qt.io/qt-5/qabstractitemmodel.html#beginMoveRows
        // (see 3rd picture explanation there)
        if(from == to - 1) {
            to = from++;
        }
        beginMoveRows(QModelIndex(), from, from, QModelIndex(), to);
        _objectList.move(from, to);
        endMoveRows();
    }
}

QObject* DNQmlObjectListModel::operator[](int index)
{
    if (index < 0 || index >= _objectList.count()) {
        return nullptr;
    }
    return _objectList[index];
}

const QObject* DNQmlObjectListModel::operator[](int index) const
{
    if (index < 0 || index >= _objectList.count()) {
        return nullptr;
    }
    return _objectList[index];
}

void DNQmlObjectListModel::clear()
{
    if (!_externalBeginResetModel) {
        beginResetModel();
    }
    _objectList.clear();
    if (!_externalBeginResetModel) {
        endResetModel();
        emit countChanged(count());
    }
}

QObject* DNQmlObjectListModel::removeAt(int i)
{
    QObject* removedObject = _objectList[i];
    if(removedObject) {
        // Look for a dirtyChanged signal on the object
        if (_objectList[i]->metaObject()->indexOfSignal(QMetaObject::normalizedSignature("dirtyChanged(bool)")) != -1) {
            if (!_skipDirtyFirstItem || i != 0) {
                QObject::disconnect(_objectList[i], SIGNAL(dirtyChanged(bool)), this, SLOT(_childDirtyChanged(bool)));
            }
        }
    }
    removeRows(i, 1);
    setDirty(true);
    return removedObject;
}

void DNQmlObjectListModel::insert(int i, QObject* object)
{
    if (i < 0 || i > _objectList.count()) {
        qWarning() << "Invalid index index:count" << i << _objectList.count();
    }
    if(object) {
        QQmlEngine::setObjectOwnership(object, QQmlEngine::CppOwnership);
        // Look for a dirtyChanged signal on the object
        if (object->metaObject()->indexOfSignal(QMetaObject::normalizedSignature("dirtyChanged(bool)")) != -1) {
            if (!_skipDirtyFirstItem || i != 0) {
                QObject::connect(object, SIGNAL(dirtyChanged(bool)), this, SLOT(_childDirtyChanged(bool)));
            }
        }
    }
    _objectList.insert(i, object);
    insertRows(i, 1);
    setDirty(true);
}

void DNQmlObjectListModel::insert(int i, QList<QObject*> objects)
{
    if (i < 0 || i > _objectList.count()) {
        qWarning() << "Invalid index index:count" << i << _objectList.count();
    }

    int j = i;
    for (QObject* object: objects) {
        QQmlEngine::setObjectOwnership(object, QQmlEngine::CppOwnership);

        // Look for a dirtyChanged signal on the object
        if (object->metaObject()->indexOfSignal(QMetaObject::normalizedSignature("dirtyChanged(bool)")) != -1) {
            if (!_skipDirtyFirstItem || j != 0) {
                QObject::connect(object, SIGNAL(dirtyChanged(bool)), this, SLOT(_childDirtyChanged(bool)));
            }
        }

        _objectList.insert(j, object);
        j++;
    }

    insertRows(i, objects.count());

    setDirty(true);
}

void DNQmlObjectListModel::append(QObject* object)
{
    insert(_objectList.count(), object);
}

void DNQmlObjectListModel::append(QList<QObject*> objects)
{
    insert(_objectList.count(), objects);
}

QObjectList DNQmlObjectListModel::swapObjectList(const QObjectList& newlist)
{
    QObjectList oldlist(_objectList);
    if (!_externalBeginResetModel) {
        beginResetModel();
    }
    _objectList = newlist;
    if (!_externalBeginResetModel) {
        endResetModel();
        emit countChanged(count());
    }
    return oldlist;
}

int DNQmlObjectListModel::count() const
{
    return rowCount();
}

void DNQmlObjectListModel::setDirty(bool dirty)
{
    if (_dirty != dirty) {
        _dirty = dirty;
        if (!dirty) {
            // Need to clear dirty from all children
            for(QObject* object: _objectList) {
                if (object->property("dirty").isValid()) {
                    object->setProperty("dirty", false);
                }
            }
        }
        emit dirtyChanged(_dirty);
    }
}

void DNQmlObjectListModel::_childDirtyChanged(bool dirty)
{
    _dirty |= dirty;
    // We want to emit dirtyChanged even if the actual value of _dirty didn't change. It can be a useful
    // signal to know when a child has changed dirty state
    emit dirtyChanged(_dirty);
}

void DNQmlObjectListModel::deleteListAndContents()
{
    for (int i=0; i<_objectList.count(); i++) {
        _objectList[i]->deleteLater();
    }
    deleteLater();
}

void DNQmlObjectListModel::clearAndDeleteContents()
{
    beginResetModel();
    for (int i=0; i<_objectList.count(); i++) {
        _objectList[i]->deleteLater();
    }
    clear();
    endResetModel();
}

void DNQmlObjectListModel::beginReset()
{
    if (_externalBeginResetModel) {
        qWarning() << "DNQmlObjectListModel::beginReset already set";
    }
    _externalBeginResetModel = true;
    beginResetModel();
}

void DNQmlObjectListModel::endReset()
{
    if (!_externalBeginResetModel) {
        qWarning() << "DNQmlObjectListModel::endReset begin not set";
    }
    _externalBeginResetModel = false;
    endResetModel();
}
