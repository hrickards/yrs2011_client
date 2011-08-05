#!/usr/bin/ruby

require 'active_record'
require 'open-uri'
require 'net/http'
require 'uri'
require 'json'
require 'open3'

def decode_qr(image_data)
  uri = URI.parse "http://qrcode.good-survey.com/api/v2/decode"
  http = Net::HTTP.new(uri.host, uri.port)

  data = http.post(uri.request_uri, image_data)
  
  response = JSON.parse data.body
  
  content = response["content"]
  
  parsed_content = YAML::load content
end

def check_signature(id, signed_id)
  File.open('/tmp/id', 'w') { |f| f.write id }
  File.open('/tmp/signed_id', 'w') { |f| f.write signed_id }
  stdin, stdout, stderr = Open3.popen3("gpg --verify /tmp/signed_id /tmp/id")
  output = stdout.read + stderr.read
  puts output
  last_line = output.lines.to_a.last
  email = last_line.split("\"")[1].gsub(/>/,'').split("<").last
  has_valid_signature = false
  has_valid_signature = true if last_line.split("signature").first.include? "GOOD"
  return { :email => email, :has_valid_signature => has_valid_signature }
end

def check_signatures(trunc_signed_id, signed_id)
  generated_trunc_signed_id = signed_id.lines.to_a[3..-2].join.gsub(/\n/,'')[-15,15]
  trunc_signed_id == generated_trunc_signed_id
end

def verify(id, signed_id)
  prescription = Prescription.find_by_id id

  # Checks that the truncated signature is the same as the truncated version
  # of the actual signature
  valid_signature = check_signatures signed_id, prescription[:signature]
  
  # Checks the actual signature verifies
  same_signatures = check_signature id, prescription[:signature]
  
  valid = valid_signature and same_signatures[:has_valid_signature]
  
  return { :email => same_signatures[:email], :valid => valid }
end