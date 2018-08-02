homebrew_user = node[cookbook_name]['user']

include_recipe 'homebrew'
include_recipe 'homebrew::install_formulas'
include_recipe 'homebrew::install_casks'

# Remove dead symlinks from the Homebrew prefix...
execute 'brew_prune' do
  user    homebrew_user
  command 'brew prune'
end

# Remove old versions of Homebrew formulas, including and associated download-cache items...
execute 'brew_cleanup' do
  user    homebrew_user
  command 'brew cleanup'
end

# Remove cached downloads and tracker symlinks for any casks...
execute 'brew_cask_cleanup' do
  user    homebrew_user
  command 'brew cask cleanup'
end
