#!/usr/bin/env ruby

require 'erb'
require 'pry'

class FileNode
  attr_accessor :path, :parents, :lines
  def initialize(path)
    ab_path = File.expand_path(path)
    @base_name = File.basename(path)
    @path = ab_path
    @parents = []
    @lines = []

    read_file
  end

  def ancestors
    out = @parents.map do |parent|
      parent.ancestors
    end
    [self, out].flatten.uniq
  end

  # call from #uniq
  def eql?(other)
    return false unless other.is_a?(Text)
    if other.path == self.path
      return true
    end
    return false
  end

  def render
    dir = File.dirname(@path)
    output_path = "#{dir}/#{Time.now.strftime('%y%m%d_%H%m')}_#{@base_name}.sql"
    fo = open(output_path, 'w')

    fo.write(build)

    fo.close
    `pbcopy < #{output_path}`
  end

  # need to implement on subclass
  def read_file
    fail
  end

  # need to implement on subclass
  def build
    fail
  end
end

class SQLTextNode < FileNode
  def read_file
    open(@path).each do |line|
      if line =~ /^--\s*with_import\s['"](.*)['"]/
        Dir.chdir(File.dirname(@path))
        @parents << SQLWithClause.new($1)
      else
        @lines << line
      end
    end
  end

  def build
    body = ancestors.map do |ancestor|
      ancestor.lines.join
    end.join(", \n")
    out = "WITH #{body}"
    out
  end

end

class SQLWithClause < SQLTextNode
end

class SQLMainText < SQLTextNode
end


if __FILE__ == $0
  fail 'set file' unless ARGV[0]
  node = SQLMainText.new(ARGV[0])
  node.render
end