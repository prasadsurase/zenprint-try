require 'pry'
require 'savon'
require 'net/ftp'

# Initialize all variables.
partner_code = 'PARTNER_CODE'
api_key = 'API_KEY'
host = 'FTP_SERVER_IP_ADDRESS'
user = 'FTP_USERNAME'
password = 'FTP_USER_PASSWORD'


test_url = 'http://orderapi.zenprint.com/orderapisand/?WSDL'
credentials = {'partnerCode' => partner_code, 'apiKey' => api_key}
order_lines = Hash.new { |h,k| h[k] = [] }

shipping_address = {
  'name' => 'Prasad Surase',
  'address1' => 'Sr. No. 48/4, Ganeshnagar,',
  'address2' => 'Wadgaonsheri',
  'city' => 'Pune',
  'state' => 'Maharashtra',
  'zipCode' => '411014',
  'countryCode' => 'IN',
  'emailAddress' => 'prasadsurase@gmail.com',
  'mainPhone' => '+91 9701915915'
}

shipping_info = {
  'shipAddress' => shipping_address,
  'carrier' => 'USPS',
  'shipMethod' => 'PR',
  'returnAddress' => ''
}

file = {
  'Files' => {
      'FileFormat' => 'PDF',
      'FileName' => '12345.pdf'
    }
  }

line_item = {
  'lineItemId' => 1,
  'productId' => '0',
  'projectId' => '',
  'quantity' => 1,
  'files' => file,
  'shippingData' =>  shipping_info
}
order_lines['LineItem'] << line_item

order = {
  'creds' => credentials,
  'partnerOrderId' => 12345,
  'orderLineItems' => order_lines,
  'rushOrder' => 0,
  'orderDate' => Time.now.strftime("%FT%T.%L"),
  'errors' => ''
}

# Upload file using FTP.
upload_file = File.new('12345.pdf')
ftp = Net::FTP.new(host, user, password)
ftp.putbinaryfile(upload_file)
puts '----- Files on the server ---------------------'
puts ftp.list

# file ordered for printing
puts '----- File ordered for printing ---------------'
puts file

puts '----- Order format ----------------------------'
puts order

# Place order.
client = Savon.client('wsdl' => test_url)
response = client.call(:place_order, 'message' => {'orderData' => order})
binding.pry

# Display response.
puts '----- Response of client.call -----------------'
puts response.body[:place_order_response][:place_order_result]
ftp.close
