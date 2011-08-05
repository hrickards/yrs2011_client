require 'mechanize'

class Drug
  
  def initialize
    @agent = Mechanize.new
    @base_uri = 'http://webprod3.hc-sc.gc.ca/dpd-bdpp'
    @page = @agent.get(@base_uri + '/start-debuter.do?lang=eng')
  end
  
  def search(name_query)
    search_form = @page.form_with :id => 'search'
    search_form.brandName = name_query
    new_page = @agent.submit search_form, search_form.buttons.first
    result = scrape new_page
  end
  
  def scrape(page)
    rows = page.parser.xpath "//form[@id='search']//table//tr[@class=' ']"
    row = rows.first
    din = row.xpath("//td//a").first.xpath('text()').to_s
    company = row.xpath("//td")[2].xpath('text()').to_s
    product = row.xpath("//td")[3].xpath('text()').to_s
    strength = row.xpath("//td")[8].xpath('text()').to_s
    results = { :din => din, :company => company, :product => product,
                :strength => strength }
  end
end