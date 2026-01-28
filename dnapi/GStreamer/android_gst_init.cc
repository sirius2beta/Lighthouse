#include <gst/gst.h>
#include <QtCore/QJniEnvironment>
#include <QtCore/QJniObject>
#include <QtCore/QLoggingCategory>
static jobject _class_loader = nullptr;
// 這是 GStreamer 提供給 Android 的接口，用於設定 Java 虛擬機環境
extern "C"
{
extern void gst_amc_jni_set_java_vm(JavaVM *java_vm);

jobject gst_android_get_application_class_loader(void)
{
    return _class_loader;
}
}

extern "C" jint JNI_OnLoad(JavaVM* vm, void* reserved) {
    JNIEnv* env = nullptr;
    if (vm->GetEnv(reinterpret_cast<void**>(&env), JNI_VERSION_1_6) != JNI_OK) {
        return JNI_ERR;
    }

    // [關鍵步驟] 告訴 GStreamer 的 androidmedia 插件 JavaVM 在哪裡
    // 沒這行，硬解插件 (amcviddec) 就無法調用 MediaCodec，會報 JNI 錯誤
    gst_amc_jni_set_java_vm(vm);

    return JNI_VERSION_1_6;
}
