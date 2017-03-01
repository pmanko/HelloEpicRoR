require 'net/http'
require 'nokogiri'
require 'uri'

class PagesController < ApplicationController


  def patient
    uri = URI("#{session[:serviceUri]}/Patient/#{session[:patientId]}")

    req = Net::HTTP::Get.new(uri)
    req['Authorization'] = "Bearer #{session[:accessToken]}"

    res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => uri.scheme == 'https') do |http|
      http.request(req)
    end


    @body = Nokogiri::XML(res.body)
    @body.remove_namespaces!

    @params = {
        a_line: @body.at("//line").values.first,
        city: @body.at("//city").values.first,
        state: @body.at("//state").values.first,
        pc: @body.at("//postalCode").values.first,
        country: @body.at("//country").values.first,
        id: @body.at("//id").values.first,
        active: @body.at("//active").values.first == "true",
        fn: @body.at("//given").values.first,
        ln: @body.at("//family").values.first,
        dob: @body.at("//birthDate").values.first,
        gender: @body.at("//gender").values.first,
        email: @body.at("//telecom//system[@value='email']//..//value").values.first,
        phone: @body.at("//telecom//system[@value='phone']//..//value").values.first
    }

  end

  def fhir_index
    @state = params[:state]
    @code = params[:code]

    token_query = {
        code: @code,
        grant_type: 'authorization_code',
        redirect_uri: session[:redirectUri]
    }

    uri = URI(session[:tokenUri])

    req = Net::HTTP::Post.new(uri)
    req.set_form_data(token_query)
    req.basic_auth(session[:clientId], session[:secret])

    res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => uri.scheme == 'https') do |http|
      http.request(req)
    end


    @body = JSON.parse(res.body)

    session[:accessToken] = @body['access_token']
    session[:patientId] = @body['patient']



    redirect_to patient_path
  end

  def fhir_launch
    # Params
    @launchUri = "https://enigmatic-brushlands-72564.herokuapp.com/flaunch"
    @redirectUri = "https://enigmatic-brushlands-72564.herokuapp.com/findex"
    # Scope for needed info
    @scope = "patient/*.read launch"
    clientId = "4bc7b02f-7a71-45d8-9b98-5181458e79ac"
    secret = "ALBJ1YiX4Ieto_vrgvPP3s2SM-zO5cwQlXCSXfsZC4ZJkN-Q2w9sh-wmkW1UwSYXI9Ao-NsjAEyNPw-SzfeV6Nc"

    byebug

    launch(@redirectUri, @scope, clientId, secret)
  end

  def epic_launch


    # Params
    launchUri = "https://enigmatic-brushlands-72564.herokuapp.com/elaunch"
    redirectUri = "https://enigmatic-brushlands-72564.herokuapp.com/findex"
    # Scope for needed info
    scope = "patient/*.read launch"
    clientId = "82768a0a-d830-47fc-8e51-e1b410c98fa4"
    #secret = "ALBJ1YiX4Ieto_vrgvPP3s2SM-zO5cwQlXCSXfsZC4ZJkN-Q2w9sh-wmkW1UwSYXI9Ao-NsjAEyNPw-SzfeV6Nc"

    launch(redirectUri, scope, clientId)
  end


  private

  def launch(redirect_uri, scope, client_id, secret = nil)
    # Get query params
    service_uri = params["iss"]
    launch_context_id = params["launch"]

    # Generate URIs
    conformance_uri = "#{service_uri}/metadata"
    @body = Nokogiri::XML(URI.parse(conformance_uri).read).remove_namespaces!

    auth_rui = @body.xpath('//rest//extension[@url="http://fhir-registry.smarthealthit.org/StructureDefinition/oauth-uris"]//extension[@url="authorize"]//valueUri').first.values.first
    token_uri = @body.xpath('//rest//extension[@url="http://fhir-registry.smarthealthit.org/StructureDefinition/oauth-uris"]//extension[@url="token"]//valueUri').first.values.first

    # Set session params
    session[:clientId] = client_id
    session[:secret] = secret
    session[:serviceUri] = service_uri
    session[:redirectUri] = redirect_uri
    session[:tokenUri] = token_uri

    # Setup Authorization data and request
    query_hash = {
        response_type: "code",
        client_id: client_id,
        scope: scope,
        redirect_uri: redirect_uri,
        aud: service_uri,
        launch: launch_context_id,
        state: session.id

    }
    redirect_uri = URI(auth_rui)
    redirect_uri.query = URI.encode_www_form(query_hash)

    # Go to Redirect URI
    redirect_to redirect_uri.to_s
  end
end
