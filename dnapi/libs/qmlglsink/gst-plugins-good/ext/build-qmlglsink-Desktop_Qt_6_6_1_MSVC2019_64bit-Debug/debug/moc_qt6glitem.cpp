/****************************************************************************
** Meta object code from reading C++ file 'qt6glitem.h'
**
** Created by: The Qt Meta Object Compiler version 68 (Qt 6.6.1)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../qt6/qt6glitem.h"
#include <QtCore/qmetatype.h>

#if __has_include(<QtCore/qtmochelpers.h>)
#include <QtCore/qtmochelpers.h>
#else
QT_BEGIN_MOC_NAMESPACE
#endif


#include <memory>

#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'qt6glitem.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 68
#error "This file was generated using the moc from 6.6.1. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

#ifndef Q_CONSTINIT
#define Q_CONSTINIT
#endif

QT_WARNING_PUSH
QT_WARNING_DISABLE_DEPRECATED
QT_WARNING_DISABLE_GCC("-Wuseless-cast")
namespace {

#ifdef QT_MOC_HAS_STRINGDATA
struct qt_meta_stringdata_CLASSQt6GLVideoItemInterfaceENDCLASS_t {};
static constexpr auto qt_meta_stringdata_CLASSQt6GLVideoItemInterfaceENDCLASS = QtMocHelpers::stringData(
    "Qt6GLVideoItemInterface",
    "QML.Element",
    "auto"
);
#else  // !QT_MOC_HAS_STRING_DATA
struct qt_meta_stringdata_CLASSQt6GLVideoItemInterfaceENDCLASS_t {
    uint offsetsAndSizes[6];
    char stringdata0[24];
    char stringdata1[12];
    char stringdata2[5];
};
#define QT_MOC_LITERAL(ofs, len) \
    uint(sizeof(qt_meta_stringdata_CLASSQt6GLVideoItemInterfaceENDCLASS_t::offsetsAndSizes) + ofs), len 
Q_CONSTINIT static const qt_meta_stringdata_CLASSQt6GLVideoItemInterfaceENDCLASS_t qt_meta_stringdata_CLASSQt6GLVideoItemInterfaceENDCLASS = {
    {
        QT_MOC_LITERAL(0, 23),  // "Qt6GLVideoItemInterface"
        QT_MOC_LITERAL(24, 11),  // "QML.Element"
        QT_MOC_LITERAL(36, 4)   // "auto"
    },
    "Qt6GLVideoItemInterface",
    "QML.Element",
    "auto"
};
#undef QT_MOC_LITERAL
#endif // !QT_MOC_HAS_STRING_DATA
} // unnamed namespace

Q_CONSTINIT static const uint qt_meta_data_CLASSQt6GLVideoItemInterfaceENDCLASS[] = {

 // content:
      12,       // revision
       0,       // classname
       1,   14, // classinfo
       0,    0, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       0,       // signalCount

 // classinfo: key, value
       1,    2,

       0        // eod
};

Q_CONSTINIT const QMetaObject Qt6GLVideoItemInterface::staticMetaObject = { {
    QMetaObject::SuperData::link<QObject::staticMetaObject>(),
    qt_meta_stringdata_CLASSQt6GLVideoItemInterfaceENDCLASS.offsetsAndSizes,
    qt_meta_data_CLASSQt6GLVideoItemInterfaceENDCLASS,
    qt_static_metacall,
    nullptr,
    qt_metaTypeArray<
        // Q_OBJECT / Q_GADGET
        Qt6GLVideoItemInterface
    >,
    nullptr
} };

void Qt6GLVideoItemInterface::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    (void)_o;
    (void)_id;
    (void)_c;
    (void)_a;
}

const QMetaObject *Qt6GLVideoItemInterface::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *Qt6GLVideoItemInterface::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_meta_stringdata_CLASSQt6GLVideoItemInterfaceENDCLASS.stringdata0))
        return static_cast<void*>(this);
    return QObject::qt_metacast(_clname);
}

int Qt6GLVideoItemInterface::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    return _id;
}
namespace {

#ifdef QT_MOC_HAS_STRINGDATA
struct qt_meta_stringdata_CLASSQt6GLVideoItemENDCLASS_t {};
static constexpr auto qt_meta_stringdata_CLASSQt6GLVideoItemENDCLASS = QtMocHelpers::stringData(
    "Qt6GLVideoItem",
    "QML.Element",
    "auto",
    "itemInitializedChanged",
    "",
    "forceAspectRatioChanged",
    "handleWindowChanged",
    "QQuickWindow*",
    "win",
    "onSceneGraphInitialized",
    "onSceneGraphInvalidated",
    "itemInitialized",
    "forceAspectRatio"
);
#else  // !QT_MOC_HAS_STRING_DATA
struct qt_meta_stringdata_CLASSQt6GLVideoItemENDCLASS_t {
    uint offsetsAndSizes[26];
    char stringdata0[15];
    char stringdata1[12];
    char stringdata2[5];
    char stringdata3[23];
    char stringdata4[1];
    char stringdata5[24];
    char stringdata6[20];
    char stringdata7[14];
    char stringdata8[4];
    char stringdata9[24];
    char stringdata10[24];
    char stringdata11[16];
    char stringdata12[17];
};
#define QT_MOC_LITERAL(ofs, len) \
    uint(sizeof(qt_meta_stringdata_CLASSQt6GLVideoItemENDCLASS_t::offsetsAndSizes) + ofs), len 
Q_CONSTINIT static const qt_meta_stringdata_CLASSQt6GLVideoItemENDCLASS_t qt_meta_stringdata_CLASSQt6GLVideoItemENDCLASS = {
    {
        QT_MOC_LITERAL(0, 14),  // "Qt6GLVideoItem"
        QT_MOC_LITERAL(15, 11),  // "QML.Element"
        QT_MOC_LITERAL(27, 4),  // "auto"
        QT_MOC_LITERAL(32, 22),  // "itemInitializedChanged"
        QT_MOC_LITERAL(55, 0),  // ""
        QT_MOC_LITERAL(56, 23),  // "forceAspectRatioChanged"
        QT_MOC_LITERAL(80, 19),  // "handleWindowChanged"
        QT_MOC_LITERAL(100, 13),  // "QQuickWindow*"
        QT_MOC_LITERAL(114, 3),  // "win"
        QT_MOC_LITERAL(118, 23),  // "onSceneGraphInitialized"
        QT_MOC_LITERAL(142, 23),  // "onSceneGraphInvalidated"
        QT_MOC_LITERAL(166, 15),  // "itemInitialized"
        QT_MOC_LITERAL(182, 16)   // "forceAspectRatio"
    },
    "Qt6GLVideoItem",
    "QML.Element",
    "auto",
    "itemInitializedChanged",
    "",
    "forceAspectRatioChanged",
    "handleWindowChanged",
    "QQuickWindow*",
    "win",
    "onSceneGraphInitialized",
    "onSceneGraphInvalidated",
    "itemInitialized",
    "forceAspectRatio"
};
#undef QT_MOC_LITERAL
#endif // !QT_MOC_HAS_STRING_DATA
} // unnamed namespace

Q_CONSTINIT static const uint qt_meta_data_CLASSQt6GLVideoItemENDCLASS[] = {

 // content:
      12,       // revision
       0,       // classname
       1,   14, // classinfo
       5,   16, // methods
       2,   55, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       2,       // signalCount

 // classinfo: key, value
       1,    2,

 // signals: name, argc, parameters, tag, flags, initial metatype offsets
       3,    0,   46,    4, 0x06,    3 /* Public */,
       5,    1,   47,    4, 0x06,    4 /* Public */,

 // slots: name, argc, parameters, tag, flags, initial metatype offsets
       6,    1,   50,    4, 0x08,    6 /* Private */,
       9,    0,   53,    4, 0x08,    8 /* Private */,
      10,    0,   54,    4, 0x08,    9 /* Private */,

 // signals: parameters
    QMetaType::Void,
    QMetaType::Void, QMetaType::Bool,    4,

 // slots: parameters
    QMetaType::Void, 0x80000000 | 7,    8,
    QMetaType::Void,
    QMetaType::Void,

 // properties: name, type, flags
      11, QMetaType::Bool, 0x00015001, uint(0), 0,
      12, QMetaType::Bool, 0x00015103, uint(1), 0,

       0        // eod
};

Q_CONSTINIT const QMetaObject Qt6GLVideoItem::staticMetaObject = { {
    QMetaObject::SuperData::link<QQuickItem::staticMetaObject>(),
    qt_meta_stringdata_CLASSQt6GLVideoItemENDCLASS.offsetsAndSizes,
    qt_meta_data_CLASSQt6GLVideoItemENDCLASS,
    qt_static_metacall,
    nullptr,
    qt_metaTypeArray<
        // property 'itemInitialized'
        bool,
        // property 'forceAspectRatio'
        bool,
        // Q_OBJECT / Q_GADGET
        Qt6GLVideoItem,
        // method 'itemInitializedChanged'
        void,
        // method 'forceAspectRatioChanged'
        void,
        bool,
        // method 'handleWindowChanged'
        void,
        QQuickWindow *,
        // method 'onSceneGraphInitialized'
        void,
        // method 'onSceneGraphInvalidated'
        void
    >,
    nullptr
} };

void Qt6GLVideoItem::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        auto *_t = static_cast<Qt6GLVideoItem *>(_o);
        (void)_t;
        switch (_id) {
        case 0: _t->itemInitializedChanged(); break;
        case 1: _t->forceAspectRatioChanged((*reinterpret_cast< std::add_pointer_t<bool>>(_a[1]))); break;
        case 2: _t->handleWindowChanged((*reinterpret_cast< std::add_pointer_t<QQuickWindow*>>(_a[1]))); break;
        case 3: _t->onSceneGraphInitialized(); break;
        case 4: _t->onSceneGraphInvalidated(); break;
        default: ;
        }
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        switch (_id) {
        default: *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType(); break;
        case 2:
            switch (*reinterpret_cast<int*>(_a[1])) {
            default: *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType(); break;
            case 0:
                *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType::fromType< QQuickWindow* >(); break;
            }
            break;
        }
    } else if (_c == QMetaObject::IndexOfMethod) {
        int *result = reinterpret_cast<int *>(_a[0]);
        {
            using _t = void (Qt6GLVideoItem::*)();
            if (_t _q_method = &Qt6GLVideoItem::itemInitializedChanged; *reinterpret_cast<_t *>(_a[1]) == _q_method) {
                *result = 0;
                return;
            }
        }
        {
            using _t = void (Qt6GLVideoItem::*)(bool );
            if (_t _q_method = &Qt6GLVideoItem::forceAspectRatioChanged; *reinterpret_cast<_t *>(_a[1]) == _q_method) {
                *result = 1;
                return;
            }
        }
    } else if (_c == QMetaObject::ReadProperty) {
        auto *_t = static_cast<Qt6GLVideoItem *>(_o);
        (void)_t;
        void *_v = _a[0];
        switch (_id) {
        case 0: *reinterpret_cast< bool*>(_v) = _t->itemInitialized(); break;
        case 1: *reinterpret_cast< bool*>(_v) = _t->getForceAspectRatio(); break;
        default: break;
        }
    } else if (_c == QMetaObject::WriteProperty) {
        auto *_t = static_cast<Qt6GLVideoItem *>(_o);
        (void)_t;
        void *_v = _a[0];
        switch (_id) {
        case 1: _t->setForceAspectRatio(*reinterpret_cast< bool*>(_v)); break;
        default: break;
        }
    } else if (_c == QMetaObject::ResetProperty) {
    } else if (_c == QMetaObject::BindableProperty) {
    }
}

const QMetaObject *Qt6GLVideoItem::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *Qt6GLVideoItem::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_meta_stringdata_CLASSQt6GLVideoItemENDCLASS.stringdata0))
        return static_cast<void*>(this);
    if (!strcmp(_clname, "QOpenGLFunctions"))
        return static_cast< QOpenGLFunctions*>(this);
    return QQuickItem::qt_metacast(_clname);
}

int Qt6GLVideoItem::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QQuickItem::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 5)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 5;
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 5)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 5;
    }else if (_c == QMetaObject::ReadProperty || _c == QMetaObject::WriteProperty
            || _c == QMetaObject::ResetProperty || _c == QMetaObject::BindableProperty
            || _c == QMetaObject::RegisterPropertyMetaType) {
        qt_static_metacall(this, _c, _id, _a);
        _id -= 2;
    }
    return _id;
}

// SIGNAL 0
void Qt6GLVideoItem::itemInitializedChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 0, nullptr);
}

// SIGNAL 1
void Qt6GLVideoItem::forceAspectRatioChanged(bool _t1)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t1))) };
    QMetaObject::activate(this, &staticMetaObject, 1, _a);
}
QT_WARNING_POP
