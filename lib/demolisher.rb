require 'libxml'
require 'nokogiri'
require 'nokogiri/xml'

module Demolisher
  # Demolish an XML file or XML::Parser object.
  # @param [String,IO,#parse] thing
  def self.demolish(thing, namespaces = nil)
    thing = _parse(thing) unless thing.kind_of?(Nokogiri::XML::Document)
    node = Node.new(thing, namespaces, true)

    yield node if block_given?
    node
  end

  def self._exchange_libxml(thing)
    thing = thing.parse if thing.respond_to?(:parse)
    thing.to_s
  end
  def self._parse(thing)
    if thing.kind_of?(LibXML::XML::Parser) || thing.kind_of?(LibXML::XML::Document)
      Nokogiri::XML::Document.parse(_exchange_libxml(thing))
    else
      # could be string data or a file name
      thing = File.open(thing) if File.exists?(thing)
      Nokogiri::XML::Document.parse(thing)
    end
  end

  # Handles all the complexity of accessing the XML contents
  class Node
    # Creates a new Node object.
    #
    # If the node is not the root node then the secondargument needs to be false.
    def initialize(xml, namespaces = nil, is_root = true)
      @nodes = [xml]
      @nodes.unshift(nil) unless is_root
      @namespaces = namespaces || {}
      @namespaces.merge!(xml.collect_namespaces) if xml.respond_to?(:collect_namespaces)
    end

    # Access an attribute of the current node.
    #
    # XML file:
    #   <addressbook>
    #     <person rel="friend">
    #       <firstname>Steve</firstname>
    #     </person>
    #   </addressbook>
    #
    # Example:
    #   xml.addressbook do
    #     xml.person do
    #       puts "#{xml.firstname} is a #{xml['rel']}"  #=> "Steve is a friend"
    #     end
    #   end
    #
    def [](attr_name)
      _current_node.attributes[attr_name]
    end

    # The workhorse, finds the node matching meth.
    #
    # Rough flow guide:
    #   If a block is given then yield to it each for each instance
    #     of the element found in the current node.
    #   If no block given then get the first element found
    #     If the node has only one text element check if the
    #       method called has a ? suffix then return true if node content
    #       looks like a boolean. Otherwise return text content
    #     Otherwise return a new Node instance
    def method_missing(meth, *args, &block) # :nodoc:
      xpath = _xpath_for_element(meth.to_s, args.shift)
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

        if node.xpath('text()').length == 1
          content = node.xpath('text()').first.content
          case meth.to_s
          when /\?$/
            !! Regexp.new(/(t(rue)?|y(es)?|1)/i).match(content)
          else
            content
          end
        else
          self.class.new(node, @namespaces, false)
        end
      end
    end

    # Returns the current nodes contents.
    def to_s # :nodoc:
      _current_node.content.strip
    end

    def _current_node
      @nodes.last
    end

    def _xpath_for_element(el_or_ns, el_for_ns = nil)
      _current_node.xpath(_element_from_symbol(el_or_ns, el_for_ns), @namespaces)
    end

    # Transforms a symbol into a XML element path.
    def _element_from_symbol(el_or_ns,el_for_ns = nil) # :nodoc:
      "#{_is_root_node? ? '/' : nil}#{el_or_ns.gsub(/[^a-z0-9_-]/i, '')}#{el_for_ns && el_for_ns.inspect}"
    end

    # Indicates if the current node is the root of the XML document.
    def _is_root_node?
      @nodes.size == 1
    end
  end
end
