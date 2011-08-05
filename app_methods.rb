def qr_code_from_id(id, signed_id)
  raise id.inspect if id.nil?
  raise signed_id.inspect if signed_id.nil?
  
  escaped_signed_id = URI.escape signed_id
  
  qr_string = "http://ec2-107-20-214-102.compute-1.amazonaws.com/qrcode/#{id}/#{escaped_signed_id}"
  
  image_path = qr_string.to_qr :size => "500x500"
end

def gpg_sign(plaintext)
  signed_output = `echo "#{plaintext}"|gpg --sign --armor --detach-sig`
  signed_output
end