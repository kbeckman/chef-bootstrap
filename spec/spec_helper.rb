# frozen_string_literal: true
require 'chefspec'
require 'chefspec/berkshelf'

COOKBOOK_NAME = 'bootstrap'.freeze

CHEF_SPEC_OPTS = { platform: 'mac_os_x', version: '10.13' }.freeze
