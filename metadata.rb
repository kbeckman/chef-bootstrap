# frozen_string_literal: true

name              'bootstrap'
maintainer        'Keith Beckman'
maintainer_email  'kbeckman@redfournine.com'
description       'Chef Cookbook for bootstrapping personal macOS environments.'
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
source_url        'https://github.com/kbeckman/chef-bootstrap'
issues_url        'https://github.com/kbeckman/chef-bootstrap/issues'

license           'MIT'
version           '0.1.0'
chef_version      '~> 14' if respond_to?(:chef_version)
supports          'mac_os_x', '>= 10.13'

depends           'homebrew', '~> 5'
