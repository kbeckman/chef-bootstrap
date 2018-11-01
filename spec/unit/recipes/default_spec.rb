# frozen_string_literal: true

require 'spec_helper'

describe 'bootstrap::default' do
  included_recipes = %w[bootstrap::homebrew bootstrap::oh_my_zsh bootstrap::homesick]

  let(:user) { 'jduggan' }

  let(:chef_run) do
    runner = ChefSpec::SoloRunner.new(CHEF_SPEC_OPTS) do |node|
      node.normal[COOKBOOK_NAME]['user'] = user
    end
    runner.converge(described_recipe)
  end

  before(:each) do
    allow_any_instance_of(Chef::Recipe).to receive(:include_recipe).and_call_original
    included_recipes.each { |recipe| allow_any_instance_of(Chef::Recipe).to receive(:include_recipe).with(recipe) }
  end

  describe 'Included Recipes:' do
    included_recipes.each do |recipe|
      it "includes '#{recipe}'" do
        expect_any_instance_of(Chef::Recipe).to receive(:include_recipe).with(recipe)

        chef_run
      end
    end
  end

  describe 'reboot[reboot_system]' do
    it 'executes command' do
      expect(chef_run).to request_reboot('reboot_system')
        .with(reason: 'End of chef-client run...', delay_mins: 0)
    end
  end
end
