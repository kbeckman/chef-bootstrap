# frozen_string_literal: true

require 'spec_helper'

describe 'bootstrap::default' do
  context 'When all attributes are default, on Ubuntu 16.04' do
    let(:user) { 'jduggan' }

    let(:chef_run) do
      # for a complete list of available platforms and versions see:
      # https://github.com/customink/fauxhai/blob/master/PLATFORMS.md
      runner = ChefSpec::SoloRunner.new(platform: 'mac_os_x', version: '10.13') do |node|
        node.normal[COOKBOOK_NAME]['user'] = user
      end
      runner.converge(described_recipe)
    end

    before do
      allow_any_instance_of(Chef::Recipe).to receive(:include_recipe).and_call_original
      RECIPES.each { |recipe| allow_any_instance_of(Chef::Recipe).to receive(:include_recipe).with(recipe) }
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end
  end
end
