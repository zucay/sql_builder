#!/usr/bin/env ruby

require 'erb'

class SQLBuilder
  @@with_first_time = true

  def self.with sql_file
    if @@with_first_time
      print 'WITH　'
    else
      print ', '
    end

    print open(sql_file).read
    @@with_first_time = false
  end

  def self.import sql_file
    print open(sql_file).read
  end

  def self.render(sql_file)
    print sql_file
    print ERB.new(open(sql_file).read).result
  end
end

if __FILE__ == $0
  fail 'set file' unless ARGV[0]
  SQLBuilder.render(ARGV[0])
end