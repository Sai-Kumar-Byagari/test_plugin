//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <flutter_js/flutter_js_plugin.h>
#include <flutter_secure_storage_windows/flutter_secure_storage_windows_plugin.h>
#include <test_plugin/test_plugin_c_api.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  FlutterJsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FlutterJsPlugin"));
  FlutterSecureStorageWindowsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FlutterSecureStorageWindowsPlugin"));
  TestPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("TestPluginCApi"));
}
