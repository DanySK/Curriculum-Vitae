#! /usr/bin/env ruby
require 'nokogiri'
require 'net/http'
require 'pathname'

def download_html(url)
    uri = URI.parse(url)
    response = Net::HTTP.get(uri)
    Nokogiri::HTML(response)
end

#Scholar
puts "Downloading Google Scholar page"
scholar_page = download_html('https://scholar.google.com/citations?user=0CLlt5oAAAAJ&hl=en')
puts scholar_page
since = scholar_page.xpath('//*[@class="gsc_rsb_sth"]')
    .map { |tag| tag.text }
    .filter { |text| text.include?('Since') }
    .first
citedBy = scholar_page.xpath('//*[@class="gsc_rsb_std"]')
    .map {| tag | tag.text }
# require that all 6 metrics are present, otherwise the page structure may have changed: fail fast.
if citedBy.length < 6
    raise "Expected 6 metrics, but found #{citedBy.length}. The page structure may have changed."
end
# require that all 6 metrics are numeric, otherwise the page structure may have changed: fail fast.
citedBy.each_with_index do |metric, index|
    unless metric.match?(/^\d+$/)
        raise "Expected metric #{index} to be numeric, but found '#{metric}'. The page structure may have changed."
    end
end
latex_newline = '\\\\'
tex = <<-TeX
% ! TeX root = curriculum.tex
\\textbf{\\href{https://scholar.google.com/citations?user=0CLlt5oAAAAJ&hl=en}{Google Scholar metrics as of #{Time.now.strftime('%Y-%m-%d')}}}
\\begin{outerlist}
    \\item[] Overall
    \\begin{innerlist}
        \\item Citations: #{citedBy[0]}
        \\item h-Index: #{citedBy[2]}
        \\item i10-Index: #{citedBy[4]}
    \\end{innerlist}
    \\item[] #{since}
    \\begin{innerlist}
        \\item Citations: #{citedBy[1]}
        \\item h-Index: #{citedBy[3]}
        \\item i10-Index: #{citedBy[5]}
    \\end{innerlist}
\\end{outerlist}
TeX
puts tex
File.write('scholar.tex', tex)

#Scopus
puts download_html('https://www.scopus.com/authid/detail.uri?authorId=36997527800')
