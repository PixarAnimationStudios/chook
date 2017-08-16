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
    end # end mac_address

    # Validate E-mail Address
    #
    # @param [String] E-mail address formatted String e.g. FirstNameLastName@randomword.com
    # @return [Boolean]
    #
    def self.email(email_address)
      email_address =~ /^[a-zA-Z]([\w -]*[a-zA-Z])\@\w*\.\w*$/ ? true : false
    end # end email

    # Validate URL
    #
    # @param [String] URL formatted String
    # @return [Boolean]
    #
    def self.url(url)
      uri = URI.parse(url)
      uri.is_a?(URI::HTTP) && !uri.host.nil? ? true : false
    end # end url

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
    end # end serial_number

    # Validate Push
    #
    # @param [String] Push Type
    # @return [Boolean]
    #
    def self.push(push)
      raise TypeError unless push.is_a? String
      return false if push.empty?
      return false unless Chook::Randomizers::PUSH_COMMANDS.include? push
      true
    end # end push

    # Validate IMEI
    #
    # @param [String] A 17-15 digit sequence of numbers
    # @return [Boolean]
    #
    def self.imei(imei)
      imei_length = imei.delete(' ').size
      (15...17).cover? imei_length
    end # end imei

    # Validate ICCID
    #
    # @param [String] ICCID
    # @return [Boolean]
    #
    def self.iccid(iccid)
      iccid_length = iccid.delete(' ').size
      return true if iccid_length < 23
    end # end iccid

    # Validate Boolean
    #
    # @param [Boolean] Make sure input is valid Boolean, because Ruby doesn't have a Boolean Class
    # @return [Boolean]
    #
    def self.boolean(true_or_false)
      [true, false].include? true_or_false
    end # end boolean

    # Validate Patch
    #
    # @param [String] Name of a Patch Reporting Software Title
    # @return [Boolean]
    #
    def self.patch(patch_name)
      Chook::Randomizers::PATCH_SOFTWARE_TITLES.include? patch_name
    end # end patch

  end # module validators

end # module Chook
