# frozen_string_literal: true

require 'spec_helper'

RSpec.describe "#{COOKBOOK_NAME}::oh_my_zsh" do
  let(:user)        { 'jduggan' }
  let(:which_bash)  { '/bin/bash' }
  let(:which_zsh)   { '/usr/local/bin/zsh' }

  let(:chef_run) do
    runner = ChefSpec::SoloRunner.new(CHEF_SPEC_OPTS) do |node|
      node.normal[COOKBOOK_NAME]['user'] = user
    end
    runner.converge(described_recipe)
  end

  before(:each) do
    which_zsh_double = double('which_zsh_double')
    allow(which_zsh_double).to receive(:run_command)
    allow(which_zsh_double).to receive(:error!)
    allow(which_zsh_double).to receive(:stdout).and_return(which_zsh)
    allow(Mixlib::ShellOut).to receive(:new).with('which zsh').and_return(which_zsh_double)

    shell_double = double('shell_double')
    allow(shell_double).to receive(:run_command)
    allow(shell_double).to receive(:error!)
    allow(shell_double).to receive(:stdout).and_return(which_zsh)
    allow(Mixlib::ShellOut).to receive(:new).with('echo $SHELL').and_return(shell_double)
  end

  describe 'execute[change_shell_to_zsh]' do
    context '$SHELL is not ZSH' do
      before(:each) do
        shell_double = double('shell_double')
        allow(shell_double).to receive(:run_command)
        allow(shell_double).to receive(:error!)
        allow(shell_double).to receive(:stdout).and_return(which_bash)
        allow(Mixlib::ShellOut).to receive(:new).with('echo $SHELL').and_return(shell_double)
      end

      it 'executes command' do
        expect(chef_run).to run_execute('change_shell_to_zsh').with(command: "chsh -s #{which_zsh} #{user}")
      end
    end

    context '$SHELL is ZSH' do
      it 'does not execute' do
        expect(chef_run).to_not run_execute('change_shell_to_zsh')
      end
    end
  end

  describe 'remote_file[ohmyzsh_installer]' do
    context '/Users/[user]/.oh-my-zsh does not exist' do
      before(:each) { allow(Dir).to receive(:exist?).with("/Users/#{user}/.oh-my-zsh").and_return(false) }

      it 'executes command' do
        expect(chef_run).to create_remote_file('ohmyzsh_installer')
          .with(path:   "#{Chef::Config[:file_cache_path]}/install-ohmyzsh.sh",
                source: 'http://install.ohmyz.sh',
                mode:   '0755')
      end
    end

    context '/Users/[user]/.oh-my-zsh exists' do
      before(:each) { allow(Dir).to receive(:exist?).with("/Users/#{user}/.oh-my-zsh").and_return(true) }

      it 'does not execute' do
        expect(chef_run).to_not create_remote_file('ohmyzsh_installer')
      end
    end
  end

  describe 'bash[install_ohmyzsh]' do
    let(:subject) { chef_run.bash('install_ohmyzsh') }

    it 'is configured but does nothing until notified' do
      expect(subject).to          do_nothing
      expect(subject.cwd).to eq   Chef::Config[:file_cache_path]
      expect(subject.code).to eq  './install-ohmyzsh.sh'
    end

    it 'subscribes to remote_file[ohmyzsh_installer]' do
      expect(subject).to subscribe_to('remote_file[ohmyzsh_installer]').on(:run).immediately
    end
  end
end
