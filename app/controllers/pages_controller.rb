require 'net/http'
require 'nokogiri'
require 'uri'
require 'openssl'

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
        a_line: getval(@body, "//line"),
        city: getval(@body, "//city"),
        state: getval(@body, "//state"),
        pc: getval(@body, "//postalCode"),
        country: getval(@body, "//country"),
        id: getval(@body, "//id"),
        active: getval(@body, "//active") == "true",
        fn: getval(@body, "//given"),
        ln: getval(@body, "//family"),
        dob: getval(@body, "//birthDate"),
        gender: getval(@body, "//gender"),
        email: getval(@body, "//telecom//system[@value='email']//..//value"),
        phone: getval(@body, "//telecom//system[@value='phone']//..//value")
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



    #redirect_to patient_path

    render 'pages/dump_body'
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
    scope = "patient/*.read openid profile"
    clientId = "7024ba74-0e17-42b4-b988-7fee02f4c7e2"
    secret = "wGi7+xEpydRRoYom6mhhMMTOqYEwCHH5JEWsn/RCyfaA6FVFkzbr2i+0Z0qZElvVCP9F9pV1Ef6Gd/9b7ODRh9VokxUmAp4+1DEvikk1Aiypab1FIwfNgdNOU5LtwtxaUsRqnDaqFZ4oGoTLqLSiZJ2yj7P/2dN+hPdLGMLLwvvMgtlNiYJoJQHVXh5ojiY3dSRRk+18BVw0gg699WUQzR3FqkcHlWGkEggkVFVpS/1v9QVKF7M94k4pU1QlHZ1LHIRF+kyXdlcvczyjD6qQEIeUtBxpGMY5DAfqfI6mRDlGQhJuCxkuWJG9iXwy7a8YXgzM45xhpp+HnuT2NpDYUyUwje+Vq2HCaT9PFvVGPhkAMIBwA/00I77aZHOf8XCeIhGNrbdnYKhfXXaD4XgCKcjJTSpdf4t7Yzcc29H1fmHqVEOYKJ2RlnDX6teX0pdTdyl1sSsgkvtIpEuSocjywRRCyVkOTQzCby0+HUEXgsnFWxhCpiBv+gJcqyZdakTv0wOLl9+6f3PJDDx7ntGK+Rc2WTr5Afb+PMcNRMJKbLRiNxOA8tPwlMyOSfyOQyT3pmmFx4zT6RHCY4b3mzV281bmIudQ2GaEa3k2FlhfQqjya3u0LdD92mTs+psCnKQwTgMSb3Oldefb5QvCbHy14Ic1M7cnQf1HlGx+ic/h+GM="

    launch(redirectUri, scope, clientId)
  end

  def mychart_launch

    # Params
    launchUri = "https://enigmatic-brushlands-72564.herokuapp.com/mlaunch"
    redirectUri = "https://enigmatic-brushlands-72564.herokuapp.com/findex"

    # Scope for needed info
    scope = "patient/*.read openid profile"
    clientId = "7024ba74-0e17-42b4-b988-7fee02f4c7e2"
    secret = "wGi7+xEpydRRoYom6mhhMMTOqYEwCHH5JEWsn/RCyfaA6FVFkzbr2i+0Z0qZElvVCP9F9pV1Ef6Gd/9b7ODRh9VokxUmAp4+1DEvikk1Aiypab1FIwfNgdNOU5LtwtxaUsRqnDaqFZ4oGoTLqLSiZJ2yj7P/2dN+hPdLGMLLwvvMgtlNiYJoJQHVXh5ojiY3dSRRk+18BVw0gg699WUQzR3FqkcHlWGkEggkVFVpS/1v9QVKF7M94k4pU1QlHZ1LHIRF+kyXdlcvczyjD6qQEIeUtBxpGMY5DAfqfI6mRDlGQhJuCxkuWJG9iXwy7a8YXgzM45xhpp+HnuT2NpDYUyUwje+Vq2HCaT9PFvVGPhkAMIBwA/00I77aZHOf8XCeIhGNrbdnYKhfXXaD4XgCKcjJTSpdf4t7Yzcc29H1fmHqVEOYKJ2RlnDX6teX0pdTdyl1sSsgkvtIpEuSocjywRRCyVkOTQzCby0+HUEXgsnFWxhCpiBv+gJcqyZdakTv0wOLl9+6f3PJDDx7ntGK+Rc2WTr5Afb+PMcNRMJKbLRiNxOA8tPwlMyOSfyOQyT3pmmFx4zT6RHCY4b3mzV281bmIudQ2GaEa3k2FlhfQqjya3u0LdD92mTs+psCnKQwTgMSb3Oldefb5QvCbHy14Ic1M7cnQf1HlGx+ic/h+GM="

    launch(redirectUri, scope, clientId)
  end

  def local_launch

    # Params
    launchUri = "http://localhost:3000/elaunch"
    redirectUri = "http://localhost:3000/findex"

    # Scope for needed info
    scope = "patient/*.read"
    clientId = "82768a0a-d830-47fc-8e51-e1b410c98fa4"

    launch(redirectUri, scope, clientId)
  end

  def remote_launch
    client_id = '7024ba74-0e17-42b4-b988-7fee02f4c7e2'
    secret = "ku2A0eCEZSpSFVADUnu3RCcSpfeEziRplzKza7JPXT4uBF7UY+EX7LjJewPj7I/lM6FcdilUnlBIr78gUWnFbKo8fkD22RMzDILIdq3zcwspg37s5bSfi19HUTLXJwrTKb6fXXQDBkul2ZiqgjOjZpAU8pB9YHLSP7tXWzVxThbY1Z3ZmGBvprvFbAKf2Cz+DeVWJ5CMQbyGQzYI1W0AQ/b1XSu/+c6vPINBJescDxsesklcGvwgNe7o/CTtK+wSuaXafoWCNW8pfHl1V9uKMGxwcoEvqdAZtern2VhnyaVSVCPiEZc+DJX1EpTTA3eaUnwEIlMLN1aeELQ0TUgj/w/Pvr6W5YyLUDeIjSn2et5/b37Qda49vdzA68lAde9QBRV8vi8erRoh8k5KGSNGiYvU9VBGo+OStIEmBZsTbWasF35xIcb+I7hIIurkvFtZDvlwPxVjT9662YVs/FTnT3GBC53l2UcMhnj5nPeo4K/wPecDjPxrJJB4Y/FVxJ6fjsuQmbrqCwY2ZmQIyMn9oPmeHk7TTYrBHWz4rX/fq51ZYEQPjnYieVd6Tkq5Aa4pKPrEWTJJB4bmIrlUEur8yA43DEZAo4t7fJfmZVg8dbhbaxb8hOxI/68MuxIkgev7VLGjtEo74CxReP07IesKSHW+NwY00zQ2hnq5hwYnLK0="
    service_uri = 'https://ic-fhirworks.epic.com/interconnect-fhir-open/api/FHIR/DSTU2/'
    scope = "patient/*.read openid profile"

    launchUri = "http://localhost:3000/elaunch"
    redirectUri = "http://localhost:3000/findex"

    # Generate URIs
    conformance_uri = "#{service_uri}/metadata"

    uri = URI(conformance_uri)

    req = Net::HTTP::Get.new(uri)

    res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => uri.scheme == 'https') do |http|
      http.request(req)
    end

    @body = res.body

    @body = URI.parse(conformance_uri).read
    @body = Nokogiri::XML(@body).remove_namespaces!

    auth_uri = @body.xpath('//rest//extension[@url="http://fhir-registry.smarthealthit.org/StructureDefinition/oauth-uris"]//extension[@url="authorize"]//valueUri').first.values.first
    token_uri = @body.xpath('//rest//extension[@url="http://fhir-registry.smarthealthit.org/StructureDefinition/oauth-uris"]//extension[@url="token"]//valueUri').first.values.first

    # Set session params
    session[:clientId] = client_id
    session[:secret] = secret
    session[:serviceUri] = service_uri
    session[:redirectUri] = redirectUri
    session[:tokenUri] = token_uri

    # Setup Authorization data and request
    query_hash = {
        response_type: "code",
        client_id: client_id,
        scope: scope,
        redirect_uri: redirectUri,
        #aud: service_uri,
        #launch: launch_context_id,
        state: session.id

    }
    redirect_uri = URI(auth_uri)
    redirect_uri.query = URI.encode_www_form(query_hash)

    # Go to Redirect URI
    redirect_to redirect_uri.to_s

  end

  private

  def launch(redirect_uri, scope, client_id, secret = nil)
    # Get query params
    service_uri = params["iss"]
    launch_context_id = params["launch"]

    # Generate URIs
    conformance_uri = "#{service_uri}/metadata"


    uri = URI(conformance_uri)

    req = Net::HTTP::Get.new(uri)

    res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => uri.scheme == 'https') do |http|
      http.request(req)
    end

    @body = res.body

    @body = URI.parse(conformance_uri).read
    @body = Nokogiri::XML(@body).remove_namespaces!

    auth_uri = @body.xpath('//rest//extension[@url="http://fhir-registry.smarthealthit.org/StructureDefinition/oauth-uris"]//extension[@url="authorize"]//valueUri').first.values.first
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
        #aud: service_uri,
        launch: launch_context_id,
        state: session.id

    }
    redirect_uri = URI(auth_uri)
    redirect_uri.query = URI.encode_www_form(query_hash)

    # Go to Redirect URI
    redirect_to redirect_uri.to_s
  end

  def getval(body, xpath)
    body.at(xpath) ? body.at(xpath).values.first : nil
  end
end
