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
credentials = {partnerCode: partner_code, apiKey: api_key}
order_lines = {}

shipping_address = {
  name: 'Prasad Surase',
  address1: 'Sr. No. 48/4, Ganeshnagar,',
  address2: 'Wadgaonsheri',
  city: 'Pune',
  state: 'Maharashtra',
  zipCode: '411014',
  countryCode: 'IN',
  emailAddress: 'prasadsurase@gmail.com',
  mainPhone: '+91 9701915915'
}

shipping_info = {
  shipAddress: shipping_address,
  carrier: 'USPS',
  shipMethod: 'PR',
  returnAddress: ''
}

file = {
  FileFormat: 'PDF',
  FileName: '12345.pdf'
}

line_item = {
  lineItemId: 1,
  productId: 27,
  projectId: '',
  quantity: 1,
  files:  [file],
  shippingData:  shipping_info
}
order_lines = [order_lines, line_item].reduce :merge

order = {
  creds: credentials,
  partnerOrderId: '12345',
  orderLineItems: [order_lines],
  rushOrder: 0,
  orderDate: Date.today,
  errors: ''
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
client = Savon.client(wsdl: test_url)
response = client.call(:place_order, message: {orderData: order})

# Display response.
puts '----- Response of client.call -----------------'
puts response.body[:place_order_response][:place_order_result]
ftp.close

=begin

Output (have removed the partnerCode and apiKey):

$ ruby zenprint.rb 
----- Files on the server ---------------------
total 123
-rwxrwxrwx  1 ftp      ftp         32271 May 21 00:26 12345-1-FULL.pdf
-rwxrwxrwx  1 ftp      ftp        153497 May 21 00:40 12345.pdf

----- File ordered for printing ---------------
{:FileFormat=>"PDF", :FileName=>"12345.pdf"}

----- Order format ----------------------------
{:creds=>{:partnerCode=>"", :apiKey=>""}, :partnerOrderId=>"12345", :orderLineItems=>[{:lineItemId=>1, :productId=>27, :projectId=>"", :quantity=>1, :files=>[{:FileFormat=>"PDF", :FileName=>"12345.pdf"}], :shippingData=>{:shipAddress=>{:name=>"Prasad Surase", :address1=>"Sr. No. 48/4, Ganeshnagar,", :address2=>"Wadgaonsheri", :city=>"Pune", :state=>"Maharashtra", :zipCode=>"411014", :countryCode=>"IN", :emailAddress=>"prasadsurase@gmail.com", :mainPhone=>"+91 9701915915"}, :carrier=>"USPS", :shipMethod=>"PR", :returnAddress=>""}}], :rushOrder=>0, :orderDate=>#<Date: 2015-05-21 ((2457164j,0s,0n),+0s,2299161j)>, :errors=>""}

----- Response of client.call -----------------
{:creds=>{:partner_code=>"", :api_key=>""}, :rush_order=>false, :partner_order_id=>"12345", :order_date=>#<DateTime: 2015-05-21T00:00:00+00:00 ((2457164j,0s,0n),+0s,2299161j)>, :errors=>{:message=>" Error: Files Missing"}, :order_line_items=>nil}

=end
