# frozen_string_literal: true

include_recipe "#{cookbook_name}::homebrew"
include_recipe "#{cookbook_name}::oh_my_zsh"
include_recipe "#{cookbook_name}::homesick"

reboot 'reboot_system' do
  reason      'End of chef-client run...'
  delay_mins  0
  action      :request_reboot
end

# build_essential 'install_C_compiler' do
#   compile_time  true
#   action :install
# end

# homebrew_packages = node['homebrew']['formulas']
#
# homebrew_packages.each do |homebrew_package|
#   package homebrew_package do
#     package_name  homebrew_package
#     homebrew_user node['homebrew']['owner']
#     action        :install
#   end
# end
