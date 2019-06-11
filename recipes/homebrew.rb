# frozen_string_literal: true

homebrew_user = node[cookbook_name]['user']

include_recipe 'homebrew'
include_recipe 'homebrew::install_formulas'
include_recipe 'homebrew::install_casks'

# Remove old versions of Homebrew formulas (including any associated download-cache items)...
execute 'brew_cleanup' do
  user    homebrew_user
  command 'brew cleanup'
end
