#!/usr/bin/env ruby

require 'erb'
require 'pry'
require 'fileutils'
class FileNode
  attr_accessor :path, :parents, :lines
  def initialize(file)
    @base_name = File.basename(file)

    @path = File.absolute_path(file)
    @@base_dir ||= File.dirname(@path)
    Dir.chdir(@@base_dir)

    @parents = []
    @lines = []

    read_file
  end

  def ancestors
    out = @parents.map do |parent|
      parent.ancestors
    end
    [out, self].flatten.uniq
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
    dir = "#{@@base_dir}/built_sql"
    FileUtils.mkdir_p(dir)
    output_path = "#{dir}/out_#{Time.now.strftime('%y%m%d_%H%m')}_#{@base_name}"
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
        begin
          @parents << SQLTextNode.new($1)
        rescue => e
          fail "file error => #{@path} : #{e}"
        end

      else
        @lines << line
      end
    end
  end

  def build
    partials = ancestors.map do |ancestor|
      ancestor.lines.join
    end

    body = partials.pop

    out = "WITH #{partials.join(', ')} #{body}"
    out
  end

end

if __FILE__ == $0
  fail 'set file' unless ARGV[0]
  node = SQLTextNode.new(ARGV[0])
  node.render
end
