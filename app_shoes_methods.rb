def get_patient_details
  @patient_details = Patient.find @id.text
  @name = @patient_details.name
  @address_line_one = @patient_details.address_line_one
  @town = @patient_details.town
  @county = @patient_details.county
  @postcode = @patient_details.postcode
  @patient.clear
  @patient.append do
    subtitle "Patient details"
    inscription "Name: #{@name}"
    flow :width => 400 do
      stack :width => 80 do
        inscription "Address: ", :width => 50
      end
      stack :width => 320 do
        inscription "#{@address_line_one},"
        inscription "#{@town},"
        inscription "#{@county},"
        inscription "#{@postcode}"
      end
    end
  end
end

def get_prescription_details
  drug = Drug.new
  results = drug.search @prescription_name.text
  @din = results[:din]
  @company = results[:company]
  @product = results[:product]
  @strength = results[:strength]
  @prescription.clear
  @prescription.append do
    subtitle "Prescription details"
    inscription "DIN: #{@din}"
    inscription "Company: #{@company}"
    inscription "Product: #{@product}"
    inscription "Strength: #{@strength}"
  end
end

def save_prescription
  prescription = Prescription.create :patient_id => @id.text, :din => @din,
    :item => "#{@company} #{@product}", :strength => @strength,
    :amount => @amount.text, :when => @when.text
  id = prescription.id
  signed_output = gpg_sign id
  prescription.signature = signed_output
  prescription.save
  signed_id_trunc = signed_output.lines.to_a[3..-2].join.gsub(/\n/,'')[-15,15]
  image_path = qr_code_from_id id, signed_id_trunc 
end

def show_qr_code(image_path)
  File.open 'qr.png', 'w' do |file|
    open(image_path, 'r', :read_timeout => 100) do |http|
      file.write http.read
    end
  end
  window :width => 510, :height => 560 do
    stack do
      subtitle "QR Image"
      image 'qr.png'    
    end
  end
end