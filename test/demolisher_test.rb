require 'test_helper'

class DemolisherTest < Test::Unit::TestCase
  context "Demolished XML file" do
    setup do
      @people = Array.new
      Demolisher.demolish(File.dirname(__FILE__) +'/test.xml') do |xml|
        xml.addressbook do
          xml.person do
            @people << {:firstname => xml.firstname, :lastname => xml.lastname,
              :active => xml.active?, :email => xml.contact.email}
          end
        end
      end
    end
    context "first extracted person" do
      setup do
        @person = @people[0]
      end
      should "have extracted firstname" do
        assert_equal 'Enoch', @person[:firstname]
      end
      should "have extracted lastname" do
        assert_equal 'Root', @person[:lastname]
      end
      should "have extracted true active status" do
        assert @person[:active]
      end
      should "have extracted email" do
        assert_equal 'enoch@example.com', @person[:email]
      end
    end
    context "second extracted person" do
      setup do
        @person = @people[1]
      end
      should "have extracted firstname" do
        assert_equal 'Randy', @person[:firstname]
      end
      should "have extracted lastname" do
        assert_equal 'Waterhouse', @person[:lastname]
      end
      should "have extracted false active status" do
        assert !@person[:active]
      end
      should "have extracted email" do
        assert_equal 'randy@example.com', @person[:email]
      end
    end
  end
  context "Demolished XML String" do
    setup do
      @xml =<<-EOXML
<hi>
  <there>Geoff</there>
</hi>
EOXML
      @demolisher = Demolisher.demolish(@xml)
    end
    should "find Geoff" do
      assert_equal 'Geoff', @demolisher.hi.there
    end
  end
  context "Demolished XML file with Namespaces" do
    setup do
      @id_and_name = ''
      @namespaces = {'soap' => "http://schemas.xmlsoap.org/soap/envelope/",
        'ns0' => "http://services.somewhere.com",
        'ns1' => "http://domain.somewhere.com" }
      Demolisher.demolish(File.dirname(__FILE__) +'/ns.xml', @namespaces) do |xml|
        xml.soap :Envelope do
          xml.soap :Body do
            xml.ns0 :getManufacturerNamesResponse do
              xml.ns0 :IDAndNameList do
                @id_and_name = xml.ns1(:IdAndName).strip
              end
            end
          end
        end
      end
    end
    should "get '14-Demolisher' from XML file" do
      assert_equal '14-Demolisher', @id_and_name
    end
  end
end
