require 'securerandom'

module Chook

  # A namespace for holding methods and constants
  # used for creating random data for Test Events and Test Subjects.
  #
  module Randomizers

    WORDS = Pathname.new '/usr/share/dict/words'

    NAMES = Pathname.new '/usr/share/dict/propernames'

    REST_OPS = %w(GET POST PUT DELETE).freeze

    MOBILE_SERIAL_CHARACTER_SETS = [
      %w(F D C H),
      %w(4 L Q 7 M 3 K N 2 9 5 C 8 1 X Y 6 0 J F T G D A P R),
      %w(L X T 8 Q 9 K V P 7 R J F 6 G N 3 M 5 Y W 4 1 H 2 C D),
      %w(K M L J H G N F 3 P B Q R S A),
      %w(H 6 4 C G V J 5 T R N K X 1 F L 9 Q 8 W M 2 P D 7 3 Y A),
      %w(J 1 2 8 B W 0 C 4 7 F 5 6 M 3 G A E Q S N R D Z X 9 P K V Y H U T L),
      %w(3 2 S Y V R M Q F J 1 8 9 L 6 H W A 4 0 E T U 5 N 7 X Z K G B D C P),
      %w(V 7 Z R P C G 8 A 2 J X Q 4 D E N B 9 0 H K Y 3 6 1 L T 5 M W F U S),
      %w(F D G 9 7 H 1),
      %w(1 C N K F J 8 R T 2 P V 3 L 4 H 5 0 6 D M X 9 G),
      %w(9 M D 1 J H 8 C 2 F P G W T Y 5 R Q 7 3 V N K X L 6 0),
      %w(6 5 K 4 J W T 2 0 V M Y 9 N 8 3 1 H Q L D R 7 P G C F X)
    ].freeze

    COMPUTER_SERIAL_CHARACTER_SETS = [
      %w(C),
      %w(0 2 1 P),
      %w(7 2 V M W F Q X),
      %w(K L F G M N J H D P Q R S),
      %w(8 G 5 7 L T M 2 P 9 X 4 K J D W C H F Q V N R 3 6 1 Y),
      %w(1 9 0 7 5 2 6 B A P 4 E 3 K F R G U W C L V 8 J D T X Y M Z N S H),
      %w(9 U 2 S Q H M V Z J G P D N 5 Y X 7 3 E 6 0 K T 4 L C F 8 A B W 1 R),
      %w(4 E N C Y H F A G 1 B 3 0 5 8 M J W L T S D V P R K U 6 Z 2 Q 7 9 X),
      %w(D F G H),
      %w(Y 6 D R H 5 W G F 0 8 T K V L 2 N 3 J 9 1 C Q),
      %w(3 T Q 0 Y P 5 V R 8 4 2 J 7 1 C M H N D F 6 G W),
      %w(H 6 X 4 5 W L J 8 G 3 P 7 T N 9 1 F M V 0 D R K 2 C Y)
    ].freeze

    SAMPLE_MOBILE_MODELS = [
      'iPhone SE',
      'iPhone 7',
      'iPhone 6S Plus',
      'iPhone 6S',
      'iPhone 6',
      'iPhone 5S (GSM)',
      'iPad Air 2 (CDMA)',
      'iPad Pro (9.7-inch Wi-Fi)',
      'iPhone 6 Plus',
      'iPad Pro (9.7-inch Cellular)',
      'iPhone 5C (GSM)',
      'iPad Air (GSM)',
      'iPhone 7 Plus',
      'iPad Pro (12.9-inch Wi-Fi)',
      'iPad Air (Wi-Fi)',
      'iPhone 5 (GSM)',
      'iPad mini 2nd Generation (GSM)',
      'iPad 3rd Generation (Wi-Fi)',
      'iPad mini 2nd Generation (Wi-Fi)',
      'iPad Air 2 (Wi-Fi)',
      'iPad mini 4 (GSM)',
      'iPod touch (5th Generation)',
      'iPod touch (6th Generation)',
      'iPad Pro (12.9-inch Cellular)',
      'iPhone 5 (CDMA)',
      'iPad 3rd Generation (GSM)',
      'iPhone 4S',
      'iPad 4th Generation (Wi-Fi)',
      'iPad mini 4 (Wi-Fi)',
      'iPad mini 3 (Wi-Fi)',
      'iPhone 4 (GSM)',
      'iPhone 5S (CDMA)',
      'iPad 4th Generation (GSM)',
      'iPad 2 (Wi-Fi)',
      'iPad 4th Generation (CDMA)',
      'iPad (Original)',
      'iPad 2 (GSM)',
      'iPad mini (GSM)',
      'iPhone 5C (CDMA)',
      'iPad 3rd Generation (CDMA)',
      'iPhone3,2',
      'iPad6,11',
      'iPad mini 3 (GSM)',
      'iPad mini (CDMA)'
    ].freeze

    SAMPLE_COMPUTER_MODELS = [
      'MacBookPro12,1',
      'MacBookAir7,2',
      'MacBookPro11,5',
      'MacPro1,1',
      'MacPro6,1',
      'MacBookAir6,2',
      'MacBookPro11,2',
      'MacBookPro13,3',
      'Xserve3,1',
      'MacPro4,1',
      'Macmini3,1',
      'iMac15,1',
      'MacBookPro11,1',
      'MacBook9,1',
      'Macmini4,1',
      'MacPro5,1',
      'Xserve1,1',
      'MacPro3,1',
      'Macmini1,1',
      'iMac14,2',
      'Macmini6,2',
      'Macmini7,1',
      'MacBookAir6,1',
      'MacBook4,1',
      'iMac11,1',
      'MacBookPro1,1',
      'MacBookPro5,3',
      'iMac7,1',
      'MacBookAir5,2',
      'iMac13,2',
      'VMware7,1',
      'MacBook5,2',
      'MacBookPro13,2',
      'iMac11,3',
      'MacBookPro7,1',
      'MacBookPro11,3',
      'MacBookPro9,2',
      'MacBookAir3,1',
      'iMac11,2',
      'MacBookPro6,2',
      'MacBookPro9,1',
      'MacBookPro8,2',
      'MacBookPro13,1',
      'iMac12,2',
      'MacBookPro8,1',
      'MacBook7,1',
      'iMac14,1',
      'Macmini5,2',
      'iMac13,1',
      'iMac12,1',
      'iMac17,1',
      'MacBookAir7,1',
      'MacBookPro10,1',
      'MacBookAir5,1',
      'MacBookAir4,2',
      'Macmini5,1',
      'Xserve2,1',
      '“MacPro6,1”'
    ].freeze

    # Keeping this set of PUSH_COMMANDS in here just in case JAMF decides to make the Push webhooks more useful...
    # PUSH_COMMANDS = [
    #   'Settings',
    #   'DeviceLock',
    #   'EraseDevice',
    #   'ClearPasscode',
    #   'UnmanageDevice',
    #   'UpdateInventory',
    #   'ClearRestrictionsPassword',
    #   'SettingsEnableDataRoaming',
    #   'SettingsDisableDataRoaming',
    #   'SettingsEnableVoiceRoaming',
    #   'SettingsDisableVoiceRoaming',
    #   'SettingsEnableAppAnalytics',
    #   'SettingsDisableAppAnalytics',
    #   'SettingsEnableDiagnosticSubmission',
    #   'SettingsDisableDiagnosticSubmission',
    #   'BlankPush',
    #   'Wallpaper', # supervised only
    #   'DeviceName', # supervised only
    #   'ShutDownDevice', # supervised only
    #   'RestartDevice', # supervised only
    #   'PasscodeLockGracePeriod' # shared iPad only
    # ].freeze

    PUSH_COMMANDS = %w(MobileDevicePushSent PushSent).freeze

    # A full list of supported titles is unfortunately not available via the API :(
    PATCH_SOFTWARE_TITLES = [
      'Adobe AIR',
      'Adobe Acrobat Pro DC',
      'Adobe Acrobat Pro XI',
      'Adobe Acrobat Reader DC',
      'Adobe Acrobat Reader XI',
      'Adobe After Effects CC',
      'Adobe Bridge CC	Adobe',
      'Adobe Core Components',
      'Adobe Dreamweaver CC',
      'Adobe Fireworks CS6',
      'Adobe Flash Player',
      'Adobe Illustrator CC',
      'Adobe InDesign CC',
      'Adobe Photoshop CC',
      'Adobe Photoshop Lightroom CC',
      'Adobe Prelude CC',
      'Adobe Premiere Pro CC',
      'Adobe Shockwave Player',
      'Google Chrome',
      'Java SE Development Kit 7',
      'Java SE Development Kit 8',
      'Java SE Runtime Environment JRE 7',
      'Java SE Runtime Environment JRE 8',
      'McAfee Endpoint Security for Mac',
      'Microsoft AutoUpdate',
      'Microsoft Excel 2016',
      'Microsoft OneNote 2016',
      'Microsoft Outlook 2016',
      'Microsoft PowerPoint 2016',
      'Microsoft Silverlight',
      'Microsoft Word 2016',
      'Mozilla Firefox Extended Support Release (ESR)',
      'Mozilla Firefox',
      'Skype',
      'Skype for Business'
    ].freeze

    # Random Word
    # Use this to generate device or username Strings
    #
    # @return [String] Randomly generated US English word to stand in for a username, device name, etc.
    #
    def self.word
      WORDS.read.lines.sample.chomp
    end # end word

    # Random Name
    #
    # @return [String] Randomly generated US English formatted "FirstName LastName".
    #
    def self.name
      NAMES.read.lines.sample.chomp + ' ' + NAMES.read.lines.sample.chomp
    end # end name

    # Random Email
    #
    # @return [String] Randomly generated email address formatted String e.g. FirstNameLastName@randomword.com
    #
    def self.email_address
      name.gsub(' ','.') + '@' + word + '.com'
    end # end email_address

    # Random Int
    #
    # @param [Integer] Optionally choose the length of the returned random Integer
    # @return [Integer] Randomized number of an optionally specified length
    #
    def self.int(x = 1)
      startpoint = 10**(x - 1)
      endpoint = (10**x) - 1
      rand(startpoint..endpoint)
    end # end int

    # Random Serial Number
    #
    # @param [Array<Array>] A dataset for generating a serial number
    # @return [String] Valid Computer or Mobile Device Serial Number
    #
    def self.serial_number_from(dataset)
      serial = ''
      dataset.each { |pos| serial << pos.sample }
      serial
    end # end serial_number

    # Computer Serial Number
    #
    # @return [String] Valid Computer Serial Number
    #
    def self.computer_serial_number
      serial_number_from COMPUTER_SERIAL_CHARACTER_SETS
    end # end computer_serial_number

    # Mobile Serial Number (wrapper)
    #
    # @return [String] Valid Mobile Device Serial Number
    #
    def self.mobile_serial_number
      serial_number_from MOBILE_SERIAL_CHARACTER_SETS
    end # mobile_serial_number

    # Random U*ID
    # MobileDevice UDID and Mac UUID are poorly distingusished in Jamf Pro.
    # In a Jamf Pro Computer record, the "UDID" in the web interface corresponds to the Hardware UUID.
    # On a Jamf Pro MobileDevice record, the UDID is actually a UDID.
    # Since these are actually different things, they are generated differently.
    #
    # @return [String] Randomly generated UUID/UDID formatted String
    #
    def self.udid(mobile = false)
      if mobile
        # UDID = SHA1(serial + IMEI + wifiMac + bluetoothMac)
        Digest::SHA1.hexdigest(serial_number(mobile: true) + int(15).to_s + mac_address + mac_address)
      else
        # UUID
        # In its canonical textual representation, the sixteen octets of a UUID are represented as 32 hexadecimal (base 16) digits
        # displayed in five groups separated by hyphens, in the form 8-4-4-4-12 for a total of 36 characters (32 alphanumeric characters and four hyphens).
        # For example:
        # 123e4567-e89b-12d3-a456-426655440000
        indexes = [8, 13, 18, 23]
        uuid = SecureRandom.hex(16).upcase
        indexes.each { |idx| uuid.insert(idx, '-') }
        uuid.upcase
      end
    end # end udid

    # Computer UUID (wrapper)
    #
    # @return [String] Randomly generated computer UUID formatted String
    #
    def self.computer_udid
      udid
    end # end computer_udid

    # Mobile UDID (wrapper)
    #
    # @return [String] Randomly generated mobile UDID formatted String
    #
    def self.mobile_udid
      udid(true)
    end # end mobile_udid

    # Product is null in the sample JSONs... And there isn't anything labeled "product" in JSS::API.get_rsrc("mobiledevices/id/#{id}")
    def self.product
      nil
    end # end product

    # Random MAC Address
    #
    # @return [String] Randomly generated MAC address formatted String
    #
    def self.mac_address
      SecureRandom.hex(6).upcase.scan(/.{2}/).join(':')
    end # end mac_address

    # Random IMEI
    #
    # @return [String] Randomly generated IMEI formatted number String
    #
    def self.imei
      indexes = [2, 9, 16]
      imei = int(15).to_s
      indexes.each { |idx| imei.insert(idx, ' ') }
      imei
    end # end imei

    # Random ICCID
    #
    # @return [String] Randomly generated ICCID formatted number String
    #
    def self.iccid
      int(20).to_s.scan(/.{4}/).join(' ')
    end # end iccid

    # Random Model
    #
    # @param [Boolean] mobile Returns a valid Computer model by default, mobile: true returns a valid Mobile Device model
    # @return [String] Randomly selected Computer or MobileDevice model
    #
    def self.model(mobile = false)
      if mobile
        SAMPLE_MOBILE_MODELS.sample
      else
        SAMPLE_COMPUTER_MODELS.sample
      end
    end # end model

    # Mobile Model (wrapper)
    #
    # @return [String]  Randomly selected MobileDevice model
    #
    def self.mobile_model
      model(true)
    end # end mobile_model

    # Computer Model (wrapper)
    #
    # @return [String]  Randomly selected Computer model
    #
    def self.computer_model
      model
    end # end computer_model

    # Version
    #
    # @return [String] Carrier Settings Version formatted String
    #
    def self.version
      [int(2), int].join('.')
    end # end version

    # Random OS Version
    #
    # @param [Boolean] mobile Returns a randomized Computer OS version by default, mobile: true returns a randomized Mobile Device OS version
    # @return [Type] String
    #
    def self.os_version(mobile = false)
      if mobile
        [rand(4..11), int, int].join('.')
      else
        [10, rand(6..15), int].join('.')
      end
    end # end os_version

    # Mobile OS Version (wrapper)
    #
    # @return [String]  Operating System Version from a MobileDevice in the JSS
    #
    def self.mobile_os_version
      os_version(true)
    end # end mobile_os_version

    # Computer OS Version (wrapper)
    #
    # @return [String]  Operating System Version from a Computer in the JSS
    #
    def self.computer_os_version
      os_version
    end # end computer_os_version

    # Random OS Build
    #
    # @return [String] Randomized OS build string
    #
    def self.os_build
      SecureRandom.hex(3).upcase
    end # end os_build

    # Random Boolean
    #
    # @return [Boolean] True or False
    #
    def self.bool
      rand(0..1).zero?
    end # end bool

    # Random REST Operation
    #
    # @return [String] Random GET, POST, PUT, or DELETE
    #
    def self.rest_operation
      REST_OPS.sample
    end # end rest_operation

    # Random Phone Number
    #
    # @return [String] Random US-formatted Phone Number
    #
    def self.phone
      raw_phone = int(10).to_s.split(//)
      [3, 7].each { |index| raw_phone.insert(index, '-') }
      raw_phone.join('')
    end # end phone

    # Random Room Number
    #
    # @return [String] Random Room Number
    #
    def self.room
      int((1..4).to_a.sample).to_s
    end # end room

    # Random Push Command
    #
    # @return [String] Random Push Command from PUSH_COMMANDS
    #
    def self.push
      PUSH_COMMANDS.sample
    end # end push

    # Random Patch Software Title
    #
    # @return [String] Random Patch Software Title
    #
    def self.patch
      PATCH_SOFTWARE_TITLES.sample
    end # end patch

    # Random Time (for lastUpdate in Patch Software Update subject)
    #
    # @return [Time] A random date and time
    #
    def self.time
      Time.at(rand * Time.now.to_i) # .to_i
    end # end time

    # Random URL-formatted String
    #
    # @return [String] A random URL-formatted String
    #
    def self.url
      "http://www.#{word}.com:#{int}"
    end # end url

    # Random hostname-formatted String
    #
    # @return [String] A random hostname-formatted String
    #
    def self.host
      "#{word}.#{word}.com"
    end # end host

  end # module randomizers

end # mod chook
