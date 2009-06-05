require 'test_helper'

class DemolisherTest < Test::Unit::TestCase
  context "Demolished XML file" do
    setup do
      @people = Array.new
      xml = Demolisher.demolish(File.dirname(__FILE__) +'/test.xml')
      xml.addressbook do
        xml.person do
          @people << {:firstname => xml.firstname.to_s, :lastname => xml.lastname.to_s,
            :active => xml.active?, :email => xml.contact.email.to_s}
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
end
