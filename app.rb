#!/usr/bin/ruby

Shoes.setup do
  gem 'mechanize'
  gem 'activerecord'
  gem 'sqlite3'
  gem 'google-qr'
end

require 'drugs'
require 'active_record'
require 'google-qr'
require 'yaml'
require 'uri'
require 'app_methods'
require 'app_shoes_methods'

dbconfig = YAML::load(File.open('database.yml'))
ActiveRecord::Base.establish_connection(dbconfig)

class Prescription < ActiveRecord::Base
end
class Patient < ActiveRecord::Base
end

Shoes.app :width => 950, :height => 600 do
  flow do
    stack :width => 400, :left => 275 do
      image "logo.png", :width => 400
    end
  end
  stack :width => 550 do
    title "New Prescription"
    flow do
      para "Patient ID: "
      @id = edit_line
      button "Get patient details" do
        get_patient_details
      end
    end
   flow do
      para "Drug name: "
      @prescription_name = edit_line
      button "Get prescription details" do
        get_prescription_details
      end
    end
    flow do
      para "Amount: "
      @amount = edit_line
    end
    flow do
      para "When to be taken: "
      @when = edit_line
    end
    button "OK" do
      image_path = save_prescription
      show_qr_code image_path
    end
  end
  stack :width => 400 do
    @patient = stack
    @prescription = stack
  end
end