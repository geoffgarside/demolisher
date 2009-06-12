require 'xml'

module Demolisher
  # Demolish an XML file or XML::Parser object.
  def self.demolish(file_or_xml_parser)
    file_or_xml_parser = XML::Parser.file(file_or_xml_parser) if file_or_xml_parser.kind_of?(String)
    node = Node.new(file_or_xml_parser.parse, true)

    yield node if block_given?
    node
  end
  class Node
    # Creates a new Node object. If the node is not the root node then
    # the second argument needs to be false.
    def initialize(xml, is_root = true)
      @nodes = [xml]
      @nodes.unshift(nil) unless is_root
    end
    # Access an attribute of the current node
    # Example:
    #   <addressbook>
    #     <person rel="friend">
    #       <firstname>Steve</firstname>
    #     </person>
    #   </addressbook>
    # 
    #   xml.addressbook do
    #     xml.person do
    #       puts "#{xml.firstname} is a #{xml['rel']}"  #=> "Steve is a friend"
    #     end
    #   end
    # 
    def [](attr_name)
      @nodes.last.attributes[attr_name]
    end
    def method_missing(meth, *args, &block) # :nodoc:
      xpath = @nodes.last.find(element_from_symbol(meth))
      return nil if xpath.empty?

      if block_given?
        xpath.each_with_index do |node, idx|
          @nodes.push(node)
          case block.arity
          when 1
            yield idx
          else
            yield
          end
          @nodes.pop
        end
      else
        node = xpath.first

        if node.find('text()').length == 1
          content = node.find('text()').first.content
          case meth.to_s
          when /\?$/
            !! Regexp.new(/(t(rue)?|y(es)?|1)/i).match(content)
          else
            content
          end
        else
          self.class.new(node, false)
        end
      end
    end
    def to_s # :nodoc:
      @nodes.last.content.strip
    end
    def element_from_symbol(sym) # :nodoc:
      "#{is_root_node? ? '/' : nil}#{sym.to_s.gsub(/[^a-z0-9_]/i, '')}"
    end
    # Indicates if the current node is the root of the XML document
    def is_root_node?
      @nodes.size == 1
    end
  end
end
