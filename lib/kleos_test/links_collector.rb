class KleosTest::LinksCollector
  @@unverified_inside_links = ['/']
  @@unverified_outside_links = []
  @@verified_links = []
  @@inside_links = { valid: [], invalid: [] }
  @@outside_links = { valid: [], invalid: [] }
  @@inside_downloads = 0

  def initialize
    @target = get_target_link
  end

  def get_target_link
    @@unverified_inside_links.empty? ? '/' : @@unverified_inside_links.shift
  end

  def get_new_links
    page, response_code = download_inside_webpage
    if response_code == 200
      @@inside_links[:valid] << @target
      @@verified_links << @target
      links = extract_links(page)
      refill_unverified_links(links)
    else
      @@inside_links[:invalid] << @target
      @@verified_links << @target
    end
  end

  def verify_outside_links
    @@unverified_outside_links.each_with_index do |link, i|
      code = download_outside_webpage(link, i + 1)
      if code == 200
        @@outside_links[:valid] << link
      else
        @@outside_links[:invalid] << link
      end
    end
  end

  def download_inside_webpage
    address = @target.include?('http') ? @target : KleosTest.base_address + @target
    @@inside_downloads += 1
    print "Downloading (#{@@inside_downloads}|#{@@unverified_inside_links.size})\
 #{URI::decode(address)}..."
    response = RestClient.get(address)
    puts "OK"
    [response.body, response.code]
  rescue RestClient::ExceptionWithResponse => e
    puts "ERROR"
    [e.response.body, e.response.code]
  rescue URI::InvalidURIError
    puts "ERROR"
    puts "BAD URI"
    ['fake body', 1]
  rescue
    puts "UNKNOWN ERROR"
    ['fake body', 1]
  end

  def download_outside_webpage(address, counter)
    print "Downloading (#{counter}|#{@@unverified_outside_links.size - counter})\
 #{URI::decode(address)}..."
    response = RestClient.get(address)
    puts "OK"
    response.code
  rescue RestClient::ExceptionWithResponse => e
    puts "ERROR"
    e.response.code
  rescue URI::InvalidURIError
    puts "ERROR"
    puts "BAD URI"
    1
  rescue
    puts "UNKNOWN ERROR"
    1
  end

  def extract_links(page)
    query = '//a[@href!=""]'
    query += '[not(starts-with(@href, "javascript:void(0)"))]'
    query += '[not(starts-with(@href, "#"))]'
    query += '[not(starts-with(@href, "mailto"))]'
    Nokogiri::HTML(page).xpath(query).map { |link| link.attribute('href').value }
  end

  def refill_unverified_links(links)
    regexp = /^(\/|\?|https?:\/\/(www\.)?kleos\.ru)(?!\/forum)/
    @@unverified_inside_links.concat(links.select do |link|
      link.match(regexp) && !(
        @@unverified_inside_links.include?(link) ||
        @@verified_links.include?(link))
    end.uniq)

    @@unverified_outside_links.concat(
      links.reject { |link| link.match(regexp) }).uniq!
  end

  class << self
    def unverified_inside_links
      @@unverified_inside_links
    end

    def inside_links
      @@inside_links[:valid] | @@inside_links[:invalid]
    end

    def valid_inside_links
      @@inside_links[:valid]
    end

    def invalid_inside_links
      @@inside_links[:invalid]
    end

    def outside_links
      @@outside_links[:valid] | @@outside_links[:invalid]
    end

    def valid_outside_links
      @@outside_links[:valid]
    end

    def invalid_outside_links
      @@outside_links[:invalid]
    end
  end
end
