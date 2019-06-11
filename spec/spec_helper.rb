# frozen_string_literal: true

require 'chefspec'
require 'chefspec/berkshelf'

COOKBOOK_NAME = 'bootstrap'

CHEF_SPEC_OPTS = { platform: 'mac_os_x', version: '10.14' }.freeze
