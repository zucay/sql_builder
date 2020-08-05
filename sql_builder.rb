#!/usr/bin/env ruby

require 'erb'
require 'pry'

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
    open(sql_file).read
  end

  def self.render(sql_file)
    dir, base, ext = [File.dirname(sql_file), File.basename(sql_file), File.extname(sql_file)]
    rendered_file = File.join(dir, "out_#{base}#{ext}")
    @@fo = File.open(rendered_file, 'w')
    @@fo.print "-- THIS FILE IS RENDERED BY SQL_BUILDER https://github.com/zucay/sql_builder\n\n"
    out = ERB.new(open(sql_file).read).result
    @@fo.print out
    @@fo.close
  end
end

if __FILE__ == $0
  fail 'set file' unless ARGV[0]
  SQLBuilder.render(ARGV[0])
end