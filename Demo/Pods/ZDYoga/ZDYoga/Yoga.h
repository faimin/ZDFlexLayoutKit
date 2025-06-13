/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#pragma once

/**
 * `#include <ZDYoga/Yoga.h>` includes all of Yoga's public headers.
 */

#if __has_include(<ZDYoga/Yoga.h>)
#include <ZDYoga/YGConfig.h>
#include <ZDYoga/YGEnums.h>
#include <ZDYoga/YGMacros.h>
#include <ZDYoga/YGNode.h>
#include <ZDYoga/YGNodeLayout.h>
#include <ZDYoga/YGNodeStyle.h>
#include <ZDYoga/YGPixelGrid.h>
#include <ZDYoga/YGValue.h>
#else
#include "YGConfig.h"
#include "YGEnums.h"
#include "YGMacros.h"
#include "YGNode.h"
#include "YGNodeLayout.h"
#include "YGNodeStyle.h"
#include "YGPixelGrid.h"
#include "YGValue.h"
#endif
