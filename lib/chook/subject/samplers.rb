require 'jss'

module Chook

  # A namespace for holding Constants and methods for
  # pulling sample data from a JSS for use with Test events and test subjects
  module Samplers

    # return a hash of all the data needed for a Computer Subject
    # from a single random computer in the JSS.
    def self.computer
      random_computer = JSS::Computer.fetch id: JSS::Computer.all_ids.sample
      hash = Chook::Subject.classes[Chook::Subject::COMPUTER].dup
      hash.each do |attrib, definition|
        hash[attrib] = case definition[:api_object_attribute]
                       when nil then nil
                       when Symbol then random_computer.send definition[:api_object_attribute]
                       when Array then random_computer.send(definition[:api_object_attribute][0])[definition[:api_object_attribute][1]]
        end # case
      end # do k
      hash
    end

    def self.serial_number(mobile = false)
      if mobile
        JSS::MobileDevice.all_serial_numbers.sample
      else
        JSS::Computer.all_serial_numbers.sample
      end
    end # end serial_number

    # MAC Address Sampler
    #
    # @param [Boolean] mobile Set to true to indicate MobileDevice vs. Computer
    # @return [String] A MAC Address sampled from a MobileDevice or Computer in the JSS
    #
    def self.mac_address(mobile = false)
      if mobile
        JSS::MobileDevice.all_wifi_mac_addresses.sample
      else
        JSS::Computer.all_mac_addresses.sample
      end
    end # end mac_address

    # UDID Sampler
    #
    # @param [Boolean] mobile Set to true to indicate MobileDevice vs. Computer
    # @return [String] A UDID sampled from a MobileDevice or Computer in the JSS
    #
    def self.udid(mobile = false)
      if mobile
        JSS::MobileDevice.all_udids.sample
      else
        JSS::Computer.all_udids.sample
      end
    end # end udid

    # IMEI Sampler
    #
    # @return [String] An IMEI sampled from a MobileDevice in the JSS
    #
    def self.imei
      imei = ''
      i = 0
      while imei.nil? || imei.empty?
        i += 1
        id = jssid(mobile: true)
        raw_subset = JSS::API.get_rsrc("mobiledevices/id/#{id}/subset/network")
        imei = raw_subset[:mobile_device][:network][:imei]
        if i > 3
          imei = 'Undefined'
          break
        end
      end
      imei
    end # end imei

    # ICCID Sampler
    #
    # @return [String] An ICCID sampled from a MobileDevice in the JSS
    #
    def self.iccid
      iccid = ''
      i = 0
      while iccid.nil? || imei.empty?
        i += 1
        id = jssid(mobile: true)
        raw_subset = JSS::API.get_rsrc("mobiledevices/id/#{id}/subset/network")
        iccid = raw_subset[:mobile_device][:network][:iccid]
        if i > 3
          iccid = 'Undefined'
          break
        end
      end
      iccid
    end # end iccid

    # Version is a String in the sample JSONs
    def self.version
      id = jssid(mobile: true)
      raw_subset = JSS::API.get_rsrc("mobiledevices/id/#{id}/subset/network")
      raw_subset[:mobile_device][:something][:something]
    end # end version

    # Product is null in the sample JSONs...
    def self.product
      id = jssid(mobile: true)
      raw_subset = JSS::API.get_rsrc("mobiledevices/id/#{id}/subset/network")
      raw_subset[:mobile_device][:something][:something] # AURICA
    end # end product

    def self.model_display
      id = jssid(mobile: true)
      raw_subset = JSS::API.get_rsrc("mobiledevices/id/#{id}/subset/general")
      raw_subset[:mobile_device][:general][:model_display]
    end # end model_display

    # JSS ID Sampler
    #
    # @param [Boolean] mobile Set to true to indicate MobileDevice vs. Computer
    # @return [Integer] A JSS ID sampled from a MobileDevice or Computer in the JSS
    #
    def self.jssid(mobile: false)
      if mobile
        all_mobile = JSS::MobileDevice.all
        all_mobile.map { |i| i[:id] }.sample.to_i
      else
        all_computer = JSS::Computer.all
        all_computer.map { |i| i[:id] }.sample.to_i
      end
    end # end jssid

    # OS Build Sampler
    #
    # @param [Boolean] mobile Set to true to indicate MobileDevice vs. Computer
    # @return [String] Operating System Build from a MobileDevice or Computer in the JSS
    #
    def self.os_build(mobile = false)
      if mobile
        id = jssid(mobile: true)
        raw_subset = JSS::API.get_rsrc("mobiledevices/id/#{id}/subset/general")
        raw_subset[:mobile_device][:general][:os_build]
      else
        id = jssid
        raw_os = JSS::API.get_rsrc("computers/id/#{id}/subset/hardware")
        raw_os[:computer][:hardware][:os_build]
      end
    end # end os_build

    # OS Version Sampler
    #
    # @param [Boolean] mobile Set to true to indicate MobileDevice vs. Computer
    # @return [String] Operating System Version from a MobileDevice or Computer in the JSS
    #
    def self.os_version(mobile = false)
      if mobile
        id = jssid(mobile: true)
        raw_subset = JSS::API.get_rsrc("mobiledevices/id/#{id}/subset/general")
        raw_subset[:mobile_device][:general][:os_version]
      else
        id = jssid
        raw_os = JSS::API.get_rsrc("computers/id/#{id}/subset/hardware")
        raw_os[:computer][:hardware][:os_version]
      end
    end # end os_version

    # Device Name Sampler
    #
    # @param [Boolean] mobile Set to true to indicate MobileDevice vs. Computer
    # @return [String] A name sampled from a MobileDevice or Computer in the JSS
    #
    def self.device_name(mobile = false)
      if mobile
        all_mobile = JSS::MobileDevice.all
        all_mobile.map { |i| i[:name] }.sample
      else
        all_computer = JSS::Computer.all
        all_computer.map { |i| i[:name] }.sample
      end
    end # end device_name

    # Model Sampler
    #
    # @param [Boolean] mobile Set to true to indicate MobileDevice vs. Computer
    # @return [String] A model sampled from a MobileDevice or Computer in the JSS
    #
    def self.model(mobile = false)
      if mobile
        all_mobile = JSS::MobileDevice.all
        all_mobile.map { |i| i[:model] }.sample
      else
        all_computer = JSS::Computer.all
        all_computer.map { |i| i[:model] }.sample
      end
    end # end model

    # Username Sampler
    #
    # @param [Boolean] mobile Set to true to indicate MobileDevice vs. Computer
    # @return [String] A username sampled from a MobileDevice or Computer in the JSS
    #
    def self.username(mobile = false)
      if mobile
        all_mobile = JSS::MobileDevice.all
        all_mobile.map { |i| i[:username] }.sample
      else
        all_computer = JSS::Computer.all
        all_computer.map { |i| i[:username] }.sample
      end
    end # end username

    # User Directory ID Sampler
    #
    # @return [Integer] A randomly sampled uid from a Computer in the JSS
    #
    def self.user_directory_id
      id = jssid
      raw_groups_acccounts = JSS::API.get_rsrc("computers/id/#{id}/subset/groups_accounts")
      raw_groups_acccounts[:computer][:groups_accounts][:local_accounts].sample[:uid]
    end # end user_directory_id

    # Real Name Sampler
    #
    # @return [String] A real name from a Computer or MobileDevice in the JSS
    #
    def self.real_name
      real_name = ''
      i = 0
      while real_name.nil? || real_name.empty?
        i += 1
        mobile_or_computer = rand(0..1)
        id = jssid(mobile_or_computer)
        if mobile_or_computer == false
          raw_location = JSS::API.get_rsrc("computers/id/#{id}/subset/location")
          real_name = raw_location[:computer][:location][:real_name]
        else
          raw_location = JSS::API.get_rsrc("mobiledevices/id/#{id}/subset/location")
          real_name = raw_location[:mobile_device][:location][:real_name]
        end
        if i > 3
          real_name = 'Undefined'
          break
        end
      end
      real_name
    end # end real_name

    # Email Address Sampler
    #
    # @return [String] An email address from a Computer or MobileDevice in the JSS
    #
    def self.email_address
      email_address = ''
      i = 0
      while email_address.nil? || email_address.empty?
        i += 1
        mobile_or_computer = rand(0..1)
        id = jssid(mobile_or_computer)
        if mobile_or_computer == false
          raw_location = JSS::API.get_rsrc("computers/id/#{id}/subset/location")
          email_address = raw_location[:computer][:location][:email_address]
        else
          raw_location = JSS::API.get_rsrc("mobiledevices/id/#{id}/subset/location")
          email_address = raw_location[:mobile_device][:location][:email_address]
        end
        if i > 3
          email_address = 'Undefined'
          break
        end
      end
      email_address
    end # end email_address

    # Phone Sampler
    #
    # @return [String] A phone number from a Computer or MobileDevice in the JSS
    #
    def self.phone_number
      phone = ''
      i = 0
      while phone.nil? || phone.empty?
        i += 1
        mobile_or_computer = rand(0..1)
        id = jssid(mobile_or_computer)
        if mobile_or_computer == false
          raw_location = JSS::API.get_rsrc("computers/id/#{id}/subset/location")
          phone = raw_location[:computer][:location][:phone]
        else
          raw_location = JSS::API.get_rsrc("mobiledevices/id/#{id}/subset/location")
          phone = raw_location[:mobile_device][:location][:phone]
        end
        if i > 3
          phone = 'Undefined'
          break
        end
      end
      phone
    end # end phone_number

    # Position Sampler
    #
    # @return [String] A position from a Computer or MoabileDevice in the JSS
    #
    def self.position
      position = ''
      i = 0
      while position.nil? || position.empty?
        i += 1
        mobile_or_computer = rand(0..1)
        id = jssid(mobile_or_computer)
        if mobile_or_computer == false
          raw_location = JSS::API.get_rsrc("computers/id/#{id}/subset/location")
          position = raw_location[:computer][:location][:position]
        else
          raw_location = JSS::API.get_rsrc("mobiledevices/id/#{id}/subset/location")
          position = raw_location[:mobile_device][:location][:position]
        end
        if i > 3
          position = 'Undefined'
          break
        end
      end
      position
    end # end position

    # Department Sampler
    #
    # @return [String] A department from a Computer or MobileDevice in the JSS
    #
    def self.department
      department = ''
      i = 0
      while department.nil? || department.empty?
        i += 1
        mobile_or_computer = rand(0..1)
        id = jssid(mobile_or_computer)
        if mobile_or_computer == false
          raw_location = JSS::API.get_rsrc("computers/id/#{id}/subset/location")
          department = raw_location[:computer][:location][:department]
        else
          raw_location = JSS::API.get_rsrc("mobiledevices/id/#{id}/subset/location")
          department = raw_location[:mobile_device][:location][:department]
        end
        if i > 3
          department = 'Undefined'
          break
        end
      end
      department
    end # end department

    # Building Sampler
    #
    # @return [String] A building from a Computer or MobileDevice in the JSS
    #
    def self.building
      building = ''
      i = 0
      while building.nil? || building.empty?
        i += 1
        mobile_or_computer = rand(0..1)
        id = jssid(mobile_or_computer)
        if mobile_or_computer == false
          raw_location = JSS::API.get_rsrc("computers/id/#{id}/subset/location")
          puts raw_location
          building = raw_location[:computer][:location][:building]
        else
          raw_location = JSS::API.get_rsrc("mobiledevices/id/#{id}/subset/location")
          puts raw_location
          building = raw_location[:mobile_device][:location][:building]
        end
        if i > 3
          building = 'Undefined'
          break
        end
      end
      building
    end # end building

    # Room Sampler
    #
    # @return [String] A room from a Computer or MobileDevice in the JSS
    #
    def self.room
      room = ''
      i = 0
      while room.nil? || room.empty?
        i += 1
        mobile_or_computer = rand(0..1)
        id = jssid(mobile_or_computer)
        if mobile_or_computer == false
          raw_location = JSS::API.get_rsrc("computers/id/#{id}/subset/location")
          room = raw_location[:computer][:location][:room]
        else
          raw_location = JSS::API.get_rsrc("mobiledevices/id/#{id}/subset/location")
          room = raw_location[:mobile_device][:location][:room]
        end
        if i > 3
          room = 'Undefined'
          break
        end
      end
      room
    end # end room

    # Smart Group Sampler
    #
    # @return [String] A Smart Group name from the JSS
    #
    def self.smart_group
      raw_computer_groups = JSS::API.get_rsrc('computergroups')
      smart_groups = raw_computer_groups[:computer_groups].select { |group| group[:is_smart] == true }
      smart_groups.sample[:name]
    end # end smart_group

  end # module samplers

end # module Chook
