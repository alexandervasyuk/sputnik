require 'net/http/persistent'

$http = Net::HTTP::Persistent.new 'happpening'
$http.verify_mode = OpenSSL::SSL::VERIFY_NONE