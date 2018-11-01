# frozen_string_literal: true

require 'spec_helper'

RSpec.describe "#{COOKBOOK_NAME}::homebrew" do
  included_recipes  = %w[homebrew homebrew::install_formulas homebrew::install_casks].freeze
  execute_cmds      = { brew_prune:        'brew prune',
                        brew_cleanup:      'brew cleanup',
                        brew_cask_cleanup: 'brew cask cleanup' }.freeze

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

  execute_cmds.each_pair do |resource, command|
    describe "execute[#{resource}]" do
      it 'executes' do
        expect(chef_run).to run_execute(resource.to_s).with(user: user, command: command)
      end
    end
  end
end
