// Copyright 2021 Sony Corporation. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "flutter_window.h"

#include <chrono>
#include <cmath>
#include <iostream>
#include <thread>
#include <poll.h>

#include "flutter/generated_plugin_registrant.h"
#include "mechanix_common/dbus_instance_manager.h"

FlutterWindow::FlutterWindow(
    const flutter::FlutterViewController::ViewProperties view_properties,
    const flutter::DartProject project)
    : view_properties_(view_properties), project_(project) {}

bool FlutterWindow::OnCreate() {
  flutter_view_controller_ = std::make_unique<flutter::FlutterViewController>(
      view_properties_, project_);

  // Ensure that basic setup of the controller was successful.
  if (!flutter_view_controller_->engine() ||
      !flutter_view_controller_->view()) {
    return false;
  }

  // Register Flutter plugins.
  RegisterPlugins(flutter_view_controller_->engine());

  return true;
}

void FlutterWindow::OnDestroy() {
  if (flutter_view_controller_) {
    flutter_view_controller_ = nullptr;
  }
}

void FlutterWindow::Run(mechanix::DBusInstanceManager* manager) {
  // Main loop.
  auto next_flutter_event_time =
      std::chrono::steady_clock::time_point::clock::now();
  while (flutter_view_controller_->view()->DispatchEvent()) {
    // Wait until the next event.
    {
      auto now = std::chrono::steady_clock::time_point::clock::now();
      auto wait_duration =
          std::max(std::chrono::nanoseconds(0),
                   next_flutter_event_time - now);
      
      if (manager) {
        // Process D-Bus events
        while (manager->Process() > 0);

        int dbus_fd = manager->GetFd();
        struct pollfd pfd = { dbus_fd, POLLIN, 0 };
        int timeout_ms = static_cast<int>(std::chrono::duration_cast<std::chrono::milliseconds>(wait_duration).count());
        
        // Also consider D-Bus timeout
        uint64_t dbus_timeout_usec = manager->GetTimeout();
        if (dbus_timeout_usec != (uint64_t)-1) {
            int dbus_timeout_ms = static_cast<int>(dbus_timeout_usec / 1000);
            if (dbus_timeout_ms < timeout_ms) timeout_ms = dbus_timeout_ms;
        }

        poll(&pfd, 1, timeout_ms);
      } else {
        std::this_thread::sleep_for(
            std::chrono::duration_cast<std::chrono::milliseconds>(wait_duration));
      }
    }

    // Processes any pending events in the Flutter engine, and returns the
    // number of nanoseconds until the next scheduled event (or max, if none).
    auto wait_duration = flutter_view_controller_->engine()->ProcessMessages();
    {
      auto next_event_time = std::chrono::steady_clock::time_point::max();
      if (wait_duration != std::chrono::nanoseconds::max()) {
        next_event_time =
            std::min(next_event_time,
                     std::chrono::steady_clock::time_point::clock::now() +
                         wait_duration);
      } else {
        // Wait for the next frame if no events.
        auto frame_rate = flutter_view_controller_->view()->GetFrameRate();
        next_event_time = std::min(
            next_event_time,
            std::chrono::steady_clock::time_point::clock::now() +
                std::chrono::milliseconds(
                    static_cast<int>(std::trunc(1000000.0 / frame_rate))));
      }
      next_flutter_event_time =
          std::max(next_flutter_event_time, next_event_time);
    }
  }
}
