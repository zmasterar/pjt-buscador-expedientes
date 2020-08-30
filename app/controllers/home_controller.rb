class HomeController < ApplicationController
  include HTTParty
  def index
  end
  def search
    if params[:q]==""
      #do nothing
    else
      if params[:q] =~ /\d+\/(?:\d{4}|\d{2})/
        response=HTTParty.get(
          "https://portaldelsae.justucuman.gov.ar/ingreso-escritos/create", 
          cookies: parse_cookies(login())
          )
        doc = Nokogiri::HTML(response)
        token=doc.at('[name="_token"]')["value"]

        response=HTTParty.post(
          "https://portaldelsae.justucuman.gov.ar/ingreso-escritos/create/buscar-expediente",
          cookies: parse_cookies(response),
          headers: {
            "X-Requested-With": "XMLHttpRequest"
          },
          multipart: true,
          body: {
            e: params[:q],
            f: '1',
            _token: token
          }
        )
        
        response_body=JSON.parse response.body

        doc = Nokogiri::HTML(response_body["view"])
        exptes = doc.css(".card.mb-3.border-secondary")

        @response=exptes
        @expedientes = []
        exptes.each do |expte|
          raw_links = expte.css("a")
          links = []
          raw_links.each do |link|
            links << create_link(link)
          end
          @expedientes.push([expte.at_css("strong").inner_text,
            expte.css("strong")[1].inner_text, links]
          )
          raw_links.each do |link|
            link.attributes["href"].value=create_link(link)
            link["target"]="_blank"
          end
        end
      end
    end

  end


  private
  def parse_cookies(response)
    cookies=response.headers["set-cookie"]
    parsed_cookies={}
    cookies.split(",").each do |cookie|
      if cookie.include? "pjtportalsae_session" or cookie.include? "XSRF-TOKEN" or cookie.include? "pagjudbeToken"
        parsed_cookies[cookie.split("=")[0]]=cookie.split("=")[1]
      end
    end
    parsed_cookies
  end

  def create_link(anchor)
    return unless anchor
    last_bit=anchor["href"].scan(/.+(\/.+)$/).last[0]
  def login
    login_url="https://login.justucuman.gov.ar/login"
    response = HTTParty.get(login_url)
    doc = Nokogiri::HTML(response)
    token=doc.at('[name="_token"]')["value"]

    HTTParty.post(
      login_url,
      multipart: true,
      body: {
        username: ENV["PJT_USERNAME"],
        password: ENV["PJT_PASSWORD"],
        _token: token
      },
      cookies: parse_cookies(response)
    )
  end
end
