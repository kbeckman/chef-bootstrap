# frozen_string_literal: true

require 'spec_helper'

RSpec.describe "#{COOKBOOK_NAME}::homesick" do
  let(:user)          { 'rflair' }
  let(:castle_name)   { 'limousine_ridin' }
  let(:github_repo)   { 'git:://github.com/rflair/castle' }
  let(:addl_symlinks) { [{ 'source' => 'test_file', 'link' => 'linked_file' }] }

  let(:chef_run) do
    runner = ChefSpec::SoloRunner.new(CHEF_SPEC_OPTS) do |node|
      node.normal[COOKBOOK_NAME]['user']                            = user
      node.normal[COOKBOOK_NAME]['homesick']['castle_name']         = castle_name
      node.normal[COOKBOOK_NAME]['homesick']['github_repo']         = github_repo
      node.normal[COOKBOOK_NAME]['homesick']['additional_symlinks'] = addl_symlinks
    end
    runner.converge(described_recipe)
  end

  describe 'Gem Packages:' do
    it 'installs homesick' do
      expect(chef_run).to install_gem_package('homesick')
    end
  end

  describe 'execute[clone_homesick_castle]' do
    let(:homesick_repo) { "/Users/#{user}/.homesick/repos/#{castle_name}" }

    context 'castle_dir does not exist' do
      before(:each) { allow(Dir).to receive(:exist?).with(homesick_repo).and_return(false) }

      it 'executes command' do
        expect(chef_run).to run_execute('clone_homesick_castle').with(command: "homesick clone #{github_repo}")
      end
    end

    context 'castle_dir exists' do
      before(:each) { allow(Dir).to receive(:exist?).with(homesick_repo).and_return(true) }

      it 'does not execute' do
        expect(chef_run).to_not run_execute('clone_homesick_castle')
      end
    end

    describe 'execute[symlink_homesick_castle]' do
      let(:subject) { chef_run.execute('symlink_homesick_castle') }

      it 'is configured but does nothing until notified' do
        expect(subject.user).to         eql(user)
        expect(subject.command).to      eql("homesick link #{castle_name} --force")
        expect(subject.timeout).to      eql(30)
        expect(subject).to              do_nothing
      end

      it 'subscribes to execute[homesick_clone_castle]' do
        expect(subject).to subscribe_to('execute[clone_homesick_castle]').on(:run).immediately
      end
    end

    describe 'symlink linked_file:' do
      let(:subject) { chef_run.execute('symlink linked_file') }

      it 'is configured but does nothing until notified' do
        expect(subject.user).to         eql(user)
        expect(subject.command).to eq   "ln -sfv #{addl_symlinks[0]['source']} #{addl_symlinks[0]['link']}"
        expect(subject).to              do_nothing
      end

      it 'subscribes to execute[symlink_homesick_castle]' do
        expect(subject).to subscribe_to('execute[symlink_homesick_castle]').on(:run).immediately
      end
    end
  end
end
