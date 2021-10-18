#!/usr/bin/env ruby

require 'erb'
require 'pry'

class FileNode
  attr_accessor :path, :parents, :lines
  def initialize(path)
    @path = path
    @parents = []
    @lines = []

    read_file(path)
  end

  def ancestors
    @parents.map do |parent|
      parent.ancestors
    end.uniq.flatten
  end

  # uniq メソッド内部で呼ばれる
  def eql?(other)
    return false unless other.is_a?(Text)
    if other.path == self.path
      return true
    end
    return false
  end

  def read_file
    fail # subclass
  end
end

class TextNode < FileNode
  def read_file
    open(@path).read.each do |line|
      if line =~ /^--\s*with_import\s['"](.*)['"]/
        @parents << WithElement.new($1)
      else
        out << line
      end
    end
  end
end

class WithElement < TextNode
end

class MainText < TextNode
end

=begin
class FileImportable
  def initialize(path, import_regex = /^--\s*with_import\s['"](.*)['"]/)
    @import_regex = import_regex    
    @lines = read(path)
  end
  def read(file)
    out = []
    open(file).each do |line|
      if line =~ @import_regex
        read($1)
      else
        out << line
      end
    end
    out.flatten
  end
  def render
    out = @lines.join("\n")
    `echo #{out} | pbcopy` # 出力したものをクリップボードに保存　
  end
end

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

  def parse_file(sql_file)
    out = []
    fi = open(sql_file).read

    fi.each do |line|
      if line =~ /^-- with_import ''/
      end
    end
    out.flatten
  end

  def self.execute(sql_file)
    dir, base, ext = [File.dirname(sql_file), File.basename(sql_file), File.extname(sql_file)]
    Dir.chdir(dir)
    rendered_file = File.join(dir, "out_#{base}#{ext}")
    @@fo = File.open(rendered_file, 'w')
    @@fo.print "-- THIS FILE IS RENDERED BY SQL_BUILDER https://github.com/zucay/sql_builder\n"
    @@fo.print "-- #{Time.now.to_s}\n"
    @@fo.print "\n"

    lines = self.parse_file(sql_file)

    lines.each do |line|
      @@fo.print line
    end
    @@fo.close
  end
end
=end

if __FILE__ == $0
  fail 'set file' unless ARGV[0]
  # SQLBuilder.execute(ARGV[0])
end