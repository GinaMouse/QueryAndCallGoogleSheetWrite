require 'google/apis/sheets_v4'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'


module Google
  def self.map_api_key(request, opts={})
    host = nil
    if request
      Rails.logger.debug("geocode: req: #{request.host}")
      host = request.host
      host = host[/^(?:www.)?(.*)$/,1]
      host = host.gsub('.', "_")
    end
    Rails.logger.debug("geokit: host: #{host}, nil #{host.nil?}, opts: #{opts}")
    if (APP_CONFIG[:google]) && host
      if APP_CONFIG[:google][host.to_sym]
        Rails.logger.debug("use app_config google key: #{}")
        APP_CONFIG[:google][host.to_sym][:map_api_key]
      else
        Rails.logger.debug("use older google key")
        "123456789987"
      end
    else
      if opts[:server_key]
        # Our default server key
        Rails.logger.debug("use default server google key")
        '123456789987'
      else
        # Our default browser key
        Rails.logger.debug("use default browser google key")
        "123456789987"
      end
    end
  end

  def self.client_id
    "123456789987-abcd1efgh23ijk4l5mnop6q78rst90uv1.apps.googleusercontent.com"
  end


  # taken from google api docs example
  OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'.freeze
  APPLICATION_NAME = 'Application Name'.freeze
  # CREDENTIALS_PATH = './credentials.json'.freeze
  CREDENTIALS_PATH = ENV['GOOGLE_APPLICATION_CREDENTIALS']
# The file token.yaml stores the user's access and refresh tokens, and is created
# automatically when the authorization flow completes for the first time.
  TOKEN_PATH = 'token.yaml'.freeze
  SCOPE = Google::Apis::SheetsV4::AUTH_SPREADSHEETS


  # range = sheetname!row/col similar to excel syntax
  def self.read_sheet
    service = Google.initialize_api
    spreadsheet_id = '123123123123123123123123123123123123123123123123123123'
    range = 'Tab Name!A1:F38'
    response = service.get_spreadsheet_values(spreadsheet_id, range)
    puts 'col0, col1, col5:'
    puts 'No data found.' if response.values.empty?
    response.values.each do |row|
      # Print columns A and E, which correspond to indices 0 and 4.
      puts "#{row[0]}, #{row[1]}, #{row[5]}\n"
    end
    response
  end


  # values = [[val1, val2, val3, ...]]
  # range = sheetname!row/col similar to excel syntax
  # major_dimension: data is written as a row of cells
  def self.write_example_sheet(data_array)
    service = Google.initialize_api
    spreadsheet_id = '123123123123123123123123123123123123123123123123123123'

    response = "failed"
    range = "'Tab Name'!B3"
    object = {"major_dimension": 'ROWS', "values": data_array}
    begin
      service.clear_values(spreadsheet_id, range)
      response  = service.update_spreadsheet_value(spreadsheet_id, range, object, value_input_option: "USER_ENTERED")
    rescue Exception => e
      Rails.logger.error("Google.write_new_data: #{e.message}\n#{e.backtrace.join('\n')}")
    end
    response
  end

  # Initialize the API
  def self.initialize_api
    begin
      if Rails.env.production?
        ENV['GOOGLE_APPLICATION_CREDENTIALS'] = 'location/filename.com_api-project-123456789987-12ab34c567de.json'
      end
      service = Google::Apis::SheetsV4::SheetsService.new
      service.client_options.application_name = APPLICATION_NAME
      service.authorization = Google::Auth.get_application_default([SCOPE])
      service
    rescue Exception => e
      Rails.logger.error("Google.initialize_api: #{e.message}\n#{e.backtrace.join('\n')}")
    end
  end
end
