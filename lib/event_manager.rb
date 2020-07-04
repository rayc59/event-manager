require "csv"
require "google/apis/civicinfo_v2"
require "erb"

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

def get_legislators(zipcode)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyDs0ELYOeEMZkrC-iu8QytCftQ9l4G6pf0'

  begin
    civic_info.representative_info_by_address(
      address: zipcode,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']).officials
  rescue
    "You can find your legislators elsewhere"
  end
end

def save_letter(id, form_letter)
  
  Dir.mkdir("output") unless Dir.exists? "output"

  filename = "output/thanks#{id}.html"
  
  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end


puts "EventManager Initialized!"

contents = CSV.open "event_attendees.csv", headers: true, header_converters: :symbol

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter

contents.each do |row|
  id = row[0]
  name = row[:first_name]

  zipcode = clean_zipcode(row[:zipcode])
  legislators = get_legislators(zipcode)

  form_letter = erb_template.result(binding)

  save_letter(id, form_letter)

end