// Copyright 2021 Sony Corporation. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include <flutter/basic_message_channel.h>
#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <flutter/method_channel.h>
#include <flutter/standard_message_codec.h>
#include <flutter/standard_method_codec.h>

#include <iostream>
#include <memory>
#include <string>
#include <vector>

#include "flutter_embedder_options.h"
#include "flutter_window.h"
#include "instance_manager.h"

namespace {
// Short flags that consume the *next* argv token as a value (e.g. "-s 1"),
// based on your --help output. Verify against flutter_embedder_options.h.
bool ShortFlagTakesValue(char c) {
  switch (c) {
    case 'b': case 'r': case 'x': case 's':
    case 't': case 'a': case 'w': case 'h':
      return true;
    default:
      return false;
  }
}
}  // namespace

int main(int argc, char** argv) {
  // --------------------------------------------------------------------
  // Split argv into (a) engine/window flags consumed by
  // FlutterEmbedderOptions, and (b) everything else (e.g. the deep-link
  // path/URL passed by xdg-open or your launcher), which we now deliver
  // to Dart over a method channel instead of as entrypoint args.
  // --------------------------------------------------------------------
  std::vector<std::string> engine_arg_storage;
  std::vector<std::string> dart_entrypoint_arguments;
  engine_arg_storage.push_back(argv[0]);

  for (int i = 1; i < argc; ++i) {
    std::string arg = argv[i];
    if (arg.rfind("--", 0) == 0) {
      engine_arg_storage.push_back(arg);
    } else if (arg.size() >= 2 && arg[0] == '-' && arg != "-") {
      engine_arg_storage.push_back(arg);
      if (ShortFlagTakesValue(arg[1]) && i + 1 < argc) {
        engine_arg_storage.push_back(argv[++i]);  // consume its value too
      }
    } else {
      // Anything that isn't a flag — e.g. the URL from xdg-open — goes to Dart.
      dart_entrypoint_arguments.push_back(arg);
    }
  }

  std::vector<char*> engine_argv;
  for (auto& s : engine_arg_storage) {
    engine_argv.push_back(const_cast<char*>(s.c_str()));
  }

  FlutterEmbedderOptions options;
  if (!options.Parse(static_cast<int>(engine_argv.size()), engine_argv.data())) {
    return 0;
  }

  const auto bundle_path = options.BundlePath();
  const std::wstring fl_path(bundle_path.begin(), bundle_path.end());
  flutter::DartProject project(fl_path);

  // The URL/path this launch was invoked with (empty if none).
  std::string incoming_url =
      dart_entrypoint_arguments.empty() ? "" : dart_entrypoint_arguments.front();

  // If another instance is already running, hand the URL off to it and exit.
  if (!TryBecomePrimaryOrForward(incoming_url)) {
    return 0;
  }

  flutter::FlutterViewController::ViewProperties view_properties = {};
  view_properties.width = options.WindowWidth();
  view_properties.height = options.WindowHeight();
  view_properties.view_mode = options.WindowViewMode();
  view_properties.view_rotation = options.WindowRotation();
  view_properties.title = options.WindowTitle();
  view_properties.app_id = options.WindowAppID();
  view_properties.use_mouse_cursor = options.IsUseMouseCursor();
  view_properties.use_onscreen_keyboard = options.IsUseOnscreenKeyboard();
  view_properties.use_window_decoration = options.IsUseWindowDecoraation();
  view_properties.text_scale_factor = options.TextScaleFactor();
  view_properties.enable_high_contrast = options.EnableHighContrast();
  view_properties.force_scale_factor = options.IsForceScaleFactor();
  view_properties.scale_factor = options.ScaleFactor();
  view_properties.enable_vsync = options.EnableVsync();

  FlutterWindow window(view_properties, project);
  if (!window.OnCreate()) {
    return 0;
  }

  auto messenger = window.GetEngine()->messenger();

  // --- Pull-based: Dart asks for the initial URL once its handler is
  // ready (in initState()). No race — nothing is sent until Dart
  // explicitly requests it, so we can't lose the cold-start URL.
  auto initial_url_channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          messenger, "com.mechanix.files/initial_url",
          &flutter::StandardMethodCodec::GetInstance());

  initial_url_channel->SetMethodCallHandler(
      [incoming_url](
          const flutter::MethodCall<flutter::EncodableValue>& call,
          std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        if (call.method_name() == "getInitialUrl") {
          if (incoming_url.empty()) {
            result->Success(flutter::EncodableValue());  // null
          } else {
            result->Success(flutter::EncodableValue(incoming_url));
          }
        } else {
          result->NotImplemented();
        }
      });

  // --- Push-based: forwards a URL to an ALREADY-running instance.
  // Dart is guaranteed to be listening by the time a second launch
  // happens, so there's no race on this path.
  flutter::BasicMessageChannel<flutter::EncodableValue> singleton_channel(
      messenger, "com.mechanix.files/singleton",
      &flutter::StandardMessageCodec::GetInstance());

  StartInstanceListener([&singleton_channel](std::string url) {
    singleton_channel.Send(flutter::EncodableValue(url));
  });

  window.Run();
  window.OnDestroy();
  return 0;
}