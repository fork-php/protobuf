# Protocol Buffers - Google's data interchange format
# Copyright 2024 Google Inc.  All rights reserved.
#
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file or at
# https://developers.google.com/open-source/licenses/bsd
#
"""Tests for py_proto_library rule."""

load("@rules_python//python:proto.bzl", "py_proto_library")
load("@rules_python//python:py_binary.bzl", "py_binary")
load("@rules_python//python:py_info.bzl", "PyInfo")
load("@rules_testing//lib:analysis_test.bzl", "analysis_test", "test_suite")
load("@rules_testing//lib:util.bzl", "util")
load("//bazel:proto_library.bzl", "proto_library")

def py_proto_library_test_suite(name):
    """Test suite for py_proto_library."""
    test_suite(
        name = name,
        tests = [
            _test_collects_python_files_from_deps_when_srcs_is_empty,
            _test_python_binary_deps,
            _test_python_proto2_deps,
        ],
    )

# Verifies py_proto_library on proto_library with no srcs generates outputs for deps.
def _test_collects_python_files_from_deps_when_srcs_is_empty(name):
    util.helper_target(
        proto_library,
        name = "b",
        srcs = ["b.proto"],
    )
    util.helper_target(
        proto_library,
        name = "a",
        deps = [":b"],
    )
    util.helper_target(
        py_proto_library,
        name = "a_py_pb",
        deps = [":a"],
    )
    analysis_test(
        name = name,
        target = ":a_py_pb",
        impl = _test_collects_python_files_from_deps_when_srcs_is_empty_impl,
    )

def _test_collects_python_files_from_deps_when_srcs_is_empty_impl(env, target):
    py_info = target[PyInfo]
    transitive_sources = [f.basename for f in py_info.transitive_sources.to_list()]

    env.expect.that_collection(transitive_sources).contains("b_pb2.py")

def _test_python_binary_deps(name):
    """Tests that py_proto_library includes outputs from proto_library.deps."""
    util.empty_file("bin.py")
    util.helper_target(
        proto_library,
        name = "bar",
        srcs = ["bar.proto"],
    )
    util.helper_target(
        proto_library,
        name = "foo",
        srcs = ["foo.proto"],
        deps = [":bar"],
    )
    util.helper_target(
        py_proto_library,
        name = "foo_py_pb",
        deps = [":foo"],
    )
    util.helper_target(
        py_binary,
        name = "bin",
        srcs = ["bin.py"],
        deps = [":foo_py_pb"],
    )
    analysis_test(
        name = name,
        target = ":bin",
        impl = _test_python_binary_deps_impl,
    )

def _test_python_binary_deps_impl(env, target):
    py_info = target[PyInfo]
    transitive_sources = [f.basename for f in py_info.transitive_sources.to_list()]

    env.expect.that_collection(transitive_sources).contains("foo_pb2.py")
    env.expect.that_collection(transitive_sources).contains("bar_pb2.py")
    env.expect.that_collection(transitive_sources).contains("bin.py")

def _test_python_proto2_deps(name):
    """Tests that py_proto_library depends on python proto2 library."""
    util.empty_file("bin_proto2_deps.py")
    util.helper_target(
        proto_library,
        name = "proto2_deps",
        srcs = ["file.proto"],
    )
    util.helper_target(
        py_proto_library,
        name = "py_proto2_deps_pb",
        deps = [":proto2_deps"],
    )
    util.helper_target(
        py_binary,
        name = "proto2_deps_bin",
        srcs = ["proto2_deps_bin.py"],
        deps = [":py_proto2_deps_pb"],
    )
    analysis_test(
        name = name,
        target = ":proto2_deps_bin",
        impl = _test_python_proto2_deps_impl,
    )

def _test_python_proto2_deps_impl(env, target):
    py_info = target[PyInfo]
    transitive_sources = [f.short_path for f in py_info.transitive_sources.to_list()]
    env.expect.that_collection(transitive_sources).contains("net/proto2/python/public/message.py")
