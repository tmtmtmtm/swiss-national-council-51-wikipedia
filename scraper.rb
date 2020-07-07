#!/bin/env ruby
# frozen_string_literal: true

require 'csv'
require 'pry'
require 'scraped'
require 'wikidata_ids_decorator'

class MembersPage < Scraped::HTML
  decorator WikidataIdsDecorator::Links

  field :members do
    members_table.xpath('.//tr[td[2]]').map { |tr| fragment(tr => MemberRow).to_h }
  end

  private

  def members_table
    noko.xpath('//table[.//th[contains(.,"Groupe")]]')
  end
end

class MemberRow < Scraped::HTML
  field :id do
    tds[1].css('a/@wikidata').map(&:text).first
  end

  field :name do
    tds[1].css('a').map(&:text).map(&:tidy).first
  end

  field :constituencyLabel do
    tds[2].css('a').map(&:text).map(&:tidy).first
  end

  field :constituency do
    tds[2].css('a/@wikidata').map(&:text).first
  end

  field :groupLabel do
    tds[5].css('a').map(&:text).map(&:tidy).first
  end

  field :group do
    tds[5].css('a/@wikidata').map(&:text).map(&:tidy).first
  end

  private

  def tds
    noko.css('td')
  end
end

url = 'https://fr.wikipedia.org/wiki/Liste_des_membres_du_Conseil_national_suisse_(2019-2023)'
data = Scraped::Scraper.new(url => MembersPage).scraper.members

header = data.first.keys.to_csv
rows = data.map { |row| row.values.to_csv }
puts header + rows.join
