require 'spec_helper'

describe Horoscope do
  it "should error out for blanks" do
    h = Horoscope::Horo.new
    expect(h.compute).to eql(["Error: Invalid Date. Enter a valid date between years 1600 AD and 2300 AD", 
      "Error: Please pass a valid time zone ranging from -12.0 to +12.0",
      "Error: Invalid Latitude. Enter between -90.0 to +90.0", 
      "Error: Invalid Longitude. Enter between -180.0 to +180.0"])
  end

  it "should validate an universal horoscope" do
    #Sachin Tendulkar's Birth Horoscope
    h = Horoscope::Horo.new(:datetime => Time.utc(1973, 4, 24, 14, 25), :zone => +5.5, :lat => 18.60, :lon => -72.50)
    h.compute
    expect(h.errors).to eql([])
    expect(h.positions).to eql({"As"=>4, "Su"=>0, "Mo"=>8, "Ma"=>9, "Me"=>11, "Ju"=>9, "Ve"=>0, "Sa"=>1, "Ra"=>8, "Ke"=>2})
  end

  it "should validate all dates" do
    h = Horoscope::Horo.new(:datetime => nil, :zone => 0, :lat => 0, :lon => 0)
    expect(h.compute).to eql(["Error: Invalid Date. Enter a valid date between years 1600 AD and 2300 AD"])

    h.datetime = Time.mktime(1599)
    expect(h.compute).to eql(["Error: Invalid Date. Enter a valid date between years 1600 AD and 2300 AD"])

    h.datetime = Time.mktime(2301)
    expect(h.compute).to eql(["Error: Invalid Date. Enter a valid date between years 1600 AD and 2300 AD"])
    
    h.datetime = Time.mktime(2013)
    h.compute
    expect(h.errors).to eql([])
  end

  it "should validate lat and lon" do
    h = Horoscope::Horo.new(:datetime => Time.now, :zone => 0)
    expect(h.compute).to eql(["Error: Invalid Latitude. Enter between -90.0 to +90.0", 
      "Error: Invalid Longitude. Enter between -180.0 to +180.0"])

    h.lat = +90.1
    h.lon = +180.1
    expect(h.compute).to eql(["Error: Invalid Latitude. Enter between -90.0 to +90.0", 
      "Error: Invalid Longitude. Enter between -180.0 to +180.0"])

    h.lat = -90.1
    h.lon = -180.1
    expect(h.compute).to eql(["Error: Invalid Latitude. Enter between -90.0 to +90.0", 
      "Error: Invalid Longitude. Enter between -180.0 to +180.0"])

    h.lat = h.lon = 0
    h.compute
    expect(h.errors).to eql([])
  end

  it "should validate time zone" do
    h = Horoscope::Horo.new(:datetime => Time.now, :lat => 18.60, :lon => -72.50)
    expect(h.compute).to eql(["Error: Please pass a valid time zone ranging from -12.0 to +12.0"])

    h.zone = -12.1
    expect(h.compute).to eql(["Error: Please pass a valid time zone ranging from -12.0 to +12.0"])

    h.zone = 12.1
    expect(h.compute).to eql(["Error: Please pass a valid time zone ranging from -12.0 to +12.0"])
    
    h.zone = 5.5
    h.compute
    expect(h.errors).to eql([])
  end

  it "can generate chart" do
    h = Horoscope::Horo.new(:datetime => Time.utc(1973, 4, 24, 14, 25), :zone => 5.5, :lat => 18.60, :lon => -72.50)
    h.compute
    h.create_chart
    expect(File).to exist("output.png") 
  end

    it "can generate chart as html" do
    h = Horoscope::Horo.new(:datetime => Time.utc(1973, 4, 24, 14, 25), :zone => 5.5, :lat => 18.60, :lon => -72.50)
    h.compute
    chart_html = h.create_chart format: :html
    expect(chart_html).to match("<td style = \"width:25%\" cell_index = \"0\">Su<br/>Ve</td>")
    expect(chart_html).to match("<td style = \"width:25%\" cell_index = \"4\">As</td>")
    expect(chart_html).to match("<td style = \"width:25%\" cell_index = \"11\">Me</td>")
    expect(chart_html).to match("<td style = \"width:25%\" cell_index = \"1\">Sa</td>")
    expect(chart_html).to match("<td style = \"width:25%\" cell_index = \"8\">Mo<br/>Ra</td>")
  end
end