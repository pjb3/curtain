require 'minitest/autorun'
require 'slim'
require 'erubis'
require 'curtain'

class Curtain::TestCase < MiniTest::Unit::TestCase
  def self.test(name, &block)
    test_name = "test_#{name.gsub(/\s+/,'_')}".to_sym
    defined = instance_method(test_name) rescue false
    raise "#{test_name} is already defined in #{self}" if defined
    if block_given?
      define_method(test_name, &block)
    else
      define_method(test_name) do
        flunk "No implementation provided for #{name}"
      end
    end
  end

  private
  def strip_lines(s)
    s.to_s.split("\n").map(&:strip).reject(&:blank?).join
  end
end
