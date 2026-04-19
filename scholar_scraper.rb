#! /usr/bin/env ruby
require 'json'
require 'nokogiri'
require 'net/http'

AUTHOR_ID = '0CLlt5oAAAAJ'.freeze
SCHOLAR_URL = "https://scholar.google.com/citations?user=#{AUTHOR_ID}&hl=en".freeze
SERPAPI_URL = 'https://serpapi.com/search.json'.freeze

def format_fetch_error(error)
  "#{error.class}: #{error.message}"
end

def http_get(uri)
  Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
    response = http.request(Net::HTTP::Get.new(uri))
    response.value
    response.body
  end
end

def download_html(url)
  Nokogiri::HTML(http_get(URI.parse(url)))
end

def fetch_serpapi_metrics(api_key)
  uri = URI.parse(SERPAPI_URL)
  uri.query = URI.encode_www_form(
    engine: 'google_scholar_author',
    author_id: AUTHOR_ID,
    hl: 'en',
    api_key: api_key
  )
  payload = JSON.parse(http_get(uri))

  raise(payload['error']) if payload['error']

  cited_by_table = payload.dig('cited_by', 'table')
  unless cited_by_table.is_a?(Array) && cited_by_table.length >= 3
    raise "Expected at least 3 cited_by table rows, found #{cited_by_table.inspect}"
  end

  metrics = {}
  since_label = nil
  cited_by_table.each do |row|
    metric_name, values = row.first
    raise "Malformed cited_by row: #{row.inspect}" unless values.is_a?(Hash)

    all_value = values['all']
    since_key = values.keys.find { |key| key != 'all' }
    since_value = since_key && values[since_key]

    raise "Missing all value for #{metric_name}" if all_value.nil?
    raise "Missing recent value for #{metric_name}" if since_value.nil?

    if since_label.nil?
      year = since_key.to_s[/\d{4}/]
      since_label =
        if year
          "Since #{year}"
        else
          since_key.to_s.tr('_', ' ').split.map(&:capitalize).join(' ')
        end
    end

    metrics[metric_name] = {
      all: all_value.to_s,
      since: since_value.to_s
    }
  end

  {
    since: since_label,
    citations_all: metrics.fetch('citations').fetch(:all),
    citations_since: metrics.fetch('citations').fetch(:since),
    h_index_all: metrics.fetch('h_index').fetch(:all),
    h_index_since: metrics.fetch('h_index').fetch(:since),
    i10_index_all: metrics.fetch('i10_index').fetch(:all),
    i10_index_since: metrics.fetch('i10_index').fetch(:since)
  }
end

def fetch_scraped_metrics
  scholar_page = download_html(SCHOLAR_URL)
  since = scholar_page.xpath('//*[@class="gsc_rsb_sth"]')
    .map(&:text)
    .find { |text| text.include?('Since') }
  cited_by = scholar_page.xpath('//*[@class="gsc_rsb_std"]')
    .map(&:text)

  if cited_by.length < 6
    raise "Expected 6 metrics, but found #{cited_by.length}. The page structure may have changed."
  end

  cited_by.each_with_index do |metric, index|
    unless metric.match?(/^\d+$/)
      raise "Expected metric #{index} to be numeric, but found '#{metric}'. The page structure may have changed."
    end
  end

  {
    since: since,
    citations_all: cited_by[0],
    citations_since: cited_by[1],
    h_index_all: cited_by[2],
    h_index_since: cited_by[3],
    i10_index_all: cited_by[4],
    i10_index_since: cited_by[5]
  }
end

def scholar_metrics
  api_key = ENV.fetch('SERPAPI_KEY', '').strip
  if !api_key.empty?
    puts 'SERPAPI_KEY detected, using SerpApi for Google Scholar metrics'
    begin
      return fetch_serpapi_metrics(api_key)
    rescue StandardError => e
      warn "SerpApi fetch failed, falling back to direct Google Scholar scraping: #{format_fetch_error(e)}"
    end
  else
    puts 'SERPAPI_KEY is unset or empty, using direct Google Scholar scraping'
  end

  fetch_scraped_metrics
rescue StandardError => e
  raise "Scholar metrics unavailable: #{format_fetch_error(e)}"
end

metrics = scholar_metrics

tex = <<~TEX
  % ! TeX root = curriculum.tex
  \\textbf{\\href{#{SCHOLAR_URL}}{Google Scholar metrics as of #{Time.now.strftime('%Y-%m-%d')}}}
  \\begin{outerlist}
      \\item[] Overall
      \\begin{innerlist}
          \\item Citations: #{metrics[:citations_all]}
          \\item h-Index: #{metrics[:h_index_all]}
          \\item i10-Index: #{metrics[:i10_index_all]}
      \\end{innerlist}
      \\item[] #{metrics[:since]}
      \\begin{innerlist}
          \\item Citations: #{metrics[:citations_since]}
          \\item h-Index: #{metrics[:h_index_since]}
          \\item i10-Index: #{metrics[:i10_index_since]}
      \\end{innerlist}
  \\end{outerlist}
TEX

puts tex
File.write('scholar.tex', tex)
