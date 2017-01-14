require 'rest-client'
require 'nokogiri'
require 'kleos_test/version'
require 'kleos_test/links_collector'

module KleosTest
  module_function

  @base_address = 'https://www.kleos.ru'

  def base_address
    @base_address
  end

  def base_address=(address)
    @base_address = address
  end
end
