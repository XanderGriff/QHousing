require 'open-uri'
require 'nokogiri'

doc = Nokogiri::HTML(open("https://listingservice.housing.queensu.ca/index.php/rental/rentalsearch/action/results_list"))
number_of_listings = doc.css('.page_margins').css('.page').css('#main').css('div').css('b')
number_of_listings = number_of_listings[0].text.chomp(" Matches").to_f

pages = (number_of_listings / 20.0).ceil


properties = Array.new
pages.times do |i|
    doc = Nokogiri::HTML(open("https://listingservice.housing.queensu.ca/index.php/rental/rentalsearch/action/results_list/pageID/" + (i+1).to_s + "/"))

    titles = doc.css('.page_margins').css('.page').css('#main').css('form').css('table').css('tr').css('td').css('b')
    details = doc.css('.page_margins').css('.page').css('#main').css('form').css('table').css('tr').css('td').css('div')
    extra_details = doc.css('.page_margins .page #main form table tr td div ul li a')
    
    addresses = Array.new
    links = Array.new
    extra_details.length.times do |j|
        if extra_details[j].text == "More Info"
            link = extra_details[j].values.to_s
            3.times do |k|
                if k !=2
                    link[0]=""
                end
                link[link.length-1]=""
            end
            links << link
        elsif extra_details[j].text == "View on Map"
            raw_address = extra_details[j].values
            raw_address = raw_address.to_s
            raw_address[1] = ""
            raw_address = raw_address.split("[javascript:openAWindow('http://maps.google.ca/?f=d&saddr=")[1].split("%")
            raw_address = raw_address[0].gsub("+", " ")
            if !raw_address.strip.include? " "
                raw_address += " St."
            end
            address =  raw_address + ", Kingston, Ontario"
            addresses << address
        end
    end

    if(i == pages-1)
        props_per_page = (number_of_listings % 20).to_i
    else
        props_per_page = 20
    end
    
    puts props_per_page
    
    props_per_page.times do |j|
        index = 21 + 2 * j
        entry = details[index].text.gsub(/\s+/, "~:~").split("~:~")
    
        entry_hash = Hash.new
        entry_hash["title"] = titles[j].text
        entry_hash["address"] = addresses[j]
        entry_hash["type"] = entry[2]
        entry_hash["rent"] = entry[4].scan(/[.0-9]/).join().to_f
        entry_hash["bedrooms"] = entry[6].to_i
        entry_hash["link"] = links[j]
        properties << entry_hash

    end
    
end

puts properties.length
puts properties


properties.length.times do |i|
    Place.create(title: properties[i]["title"], address: properties[i]["address"], place_type: properties[i]["type"], 
        rent: properties[i]["rent"], bedrooms: properties[i]["bedrooms"], link: properties[i]["link"] )
end
