# frozen_string_literal: true

gem_package 'homesick'

user          = node['bootstrap']['user']
castle_name   = node['bootstrap']['homesick']['castle_name']
github_repo   = node['bootstrap']['homesick']['github_repo']
addl_symlinks = node['bootstrap']['homesick']['additional_symlinks']

execute 'clone_homesick_castle' do
  user    user
  command "homesick clone #{github_repo}"
  not_if  { Dir.exist?("/Users/#{user}/.homesick/repos/#{castle_name}") }
end

execute 'symlink_homesick_castle' do
  user        user
  command     "homesick link #{castle_name} --force"
  action      :nothing
  timeout     30
  subscribes  :run, 'execute[clone_homesick_castle]', :immediately
end

addl_symlinks.each do |symlink|
  execute "symlink #{symlink['link']}" do
    user        user
    command     "ln -sfv #{symlink['source']} #{symlink['link']}"
    action      :nothing
    subscribes  :run, 'execute[symlink_homesick_castle]', :immediately
  end
end
