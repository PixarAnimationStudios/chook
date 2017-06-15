require 'uri'

module Chook

  # A namespace to hold validation methods for use with
  # Test Events and Test Subjects.
  # Each method taks a value, and returns a boolean
  # indicating the validity of the value.
  #
  module Validators

    # Validate MAC Address
    #
    # @param [String] MAC address formatted String
    # @return [Boolean]
    #
    def self.mac_address(mac)
      mac =~ /^([a-f\d]{2}:){5}[a-f\d]{2}$/i ? true : false
    end # end validate_mac_address

    # Validate E-mail Address
    #
    # @param [String] E-mail address formatted String e.g. FirstNameLastName@randomword.com
    # @return [Boolean]
    #
    def self.email(email_address)
      email_address =~ /^[a-zA-Z]([\w -]*[a-zA-Z])\@\w*\.\w*$/ ? true : false
    end # end validate_email

    # Validate URL
    #
    # @param [String] URL formatted String
    # @return [Boolean]
    #
    def self.url(url)
      uri = URI.parse(url)
      uri.is_a?(URI::HTTP) && !uri.host.nil? ? true : false
    end # end validate_url

    # Validate Serial Number
    #
    # @param [String] Serial Number Formatted String
    # @return [Boolean]
    #
    def self.serial_number(serial)
      raise TypeError unless serial.is_a? String
      serial_array = serial.scan(/\w/)
      return false if serial.empty?
      serial_array.each_with_index do |character, index|
        return false unless (Chook::Randomizers::MOBILE_SERIAL_CHARACTER_SETS[index].include? character) || (Chook::Randomizers::COMPUTER_SERIAL_CHARACTER_SETS[index].include? character)
      end
      true
    end # end validate_serial_number

    # Validate Boolean
    #
    # @param [Boolean] Make sure input is valid Boolean, because Ruby doesn't have a Boolean Class
    # @return [Boolean]
    #
    def self.boolean(true_or_false)
      [true, false].include? true_or_false
    end # end validate_boolean

  end # module validators

end # module Chook
