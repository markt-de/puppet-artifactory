# frozen_string_literal: true

require 'puppet_litmus'
require 'singleton'

class LitmusHelper
  include Singleton
  include PuppetLitmus
end

RSpec.configure do |c|
  c.before :suite do
    # Install soft dependencies.
    LitmusHelper.instance.run_shell('puppet module install puppetlabs/postgresql')
  end
end
