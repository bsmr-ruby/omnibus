#
# Cookbook Name:: build-essential
# Recipe:: default
#
# Copyright 2008-2009, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

case node['platform']
when "ubuntu","debian"
  %w{build-essential binutils-doc}.each do |pkg|
    package pkg do
      action :install
    end
  end

  # TODO: figure out what the root cause is and remove this dep
  # Background: Erlang fails to ./configure erts on Ubuntu 12.04 platforms
  # because the test program it uses to detect ncurses fails to find ncurses in
  # the embedded/ directory. Installing ncurses-devel causes ./configure to
  # work, and the resulting erlang is linked to the correct ncurses shared
  # object (in embedded/). So this is ugly, but required to make erlang build.
  if platform?("ubuntu") and node[:platform_version].to_f >= 12.04
    package "ncurses-dev"
  end
when "centos"
  centos_major_version = node['platform_version'].split('.').first.to_i
  pkgs = if centos_major_version < 6
           %w{gcc44 gcc44-c++ gcc gcc-c++ kernel-devel make}
         else
           %w{gcc gcc-c++ kernel-devel make}
         end
  pkgs << "zlib"
  pkgs << "zlib-devel"
  pkgs << "openssl-devel"
  pkgs.each do |pkg|
    package pkg do
      action :install
    end
  end
when "redhat","fedora"
  %w{gcc gcc-c++ kernel-devel make}.each do |pkg|
    package pkg do
      action :install
    end
  end
when "mac_os_x"
  include_recipe "homebrew"
end

unless node['platform'] == "mac_os_x"
  package "autoconf" do
    action :install
  end

  package "flex" do
    action :install
  end

  package "bison" do
    action :install
  end
end