#!/usr/bin/env ruby
require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'byebug'
require 'prawn'

if ARGV.length < 1
  p 'Give id of document'
  exit
end

doc_id = ARGV[0]
p "Document #{doc_id} processing"

viewer_uri = File.read('viewer_url')
main_page_uri = "#{viewer_uri}?docId=#{doc_id}&page="
count_uri = "#{viewer_uri}?docId=#{doc_id}&pageCount=all"

count_doc = Nokogiri::HTML(open(count_uri))
pages_count = count_doc.at('body').children[0].text.to_i

def get_page(page_uri, page_num)
  open(page_uri) do |page_image|
    File.open("./out/#{page_num.to_s}.jpg", 'wb') do |file|
      IO.copy_stream(page_image, file)
    end
  end
end

1.upto(pages_count) do |page_num|
  page_uri = "#{main_page_uri}#{page_num.to_s}"
  p "Page #{page_num}"
  get_page(page_uri, page_num)
  sleep 10
end

format_arg = ARGV[1]

pdf_format = format_arg == 'l' ? :landscape : :portrait

Prawn::Document.generate('./out/out.pdf', page_layout: pdf_format) do |pdf|
  1.upto(pages_count) do |page_num|
    pdf.image "./out/#{page_num.to_s}.jpg", :fit => [pdf.bounds.right, pdf.bounds.top]
    pdf.start_new_page unless pdf.page_count == pages_count
  end
end

p 'Done'
