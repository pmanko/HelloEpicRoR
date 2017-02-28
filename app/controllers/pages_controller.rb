require 'net/http'
require 'nokogiri'
require 'uri'

class PagesController < ApplicationController


  def fhir_index
    # @state = params[:state]
    # @code = params[:code]
    #
    #
    #
    #
    #
    #
    render :patient

    #render layout: false
  end

  def fhir_launch
    @serviceUri = params["iss"]
    @launchContextId = params["launch"]
    @scope = "patient/*.read launch"


    @launchUri = "https://enigmatic-brushlands-72564.herokuapp.com/flaunch"
    @redirectUri = "https://enigmatic-brushlands-72564.herokuapp.com/findex"

    @conformanceUri = "#{@serviceUri}/metadata"


    clientId = "4bc7b02f-7a71-45d8-9b98-5181458e79ac"
    secret = "ALBJ1YiX4Ieto_vrgvPP3s2SM-zO5cwQlXCSXfsZC4ZJkN-Q2w9sh-wmkW1UwSYXI9Ao-NsjAEyNPw-SzfeV6Nc"


    @body = Nokogiri::XML(URI.parse(@conformanceUri).read)
    @body.remove_namespaces!
    @authUri = @body.xpath('//rest//extension[@url="http://fhir-registry.smarthealthit.org/StructureDefinition/oauth-uris"]//extension[@url="authorize"]//valueUri').first.values.first
    @tokenUri = @body.xpath('//rest//extension[@url="http://fhir-registry.smarthealthit.org/StructureDefinition/oauth-uris"]//extension[@url="token"]//valueUri').first.values.first


    session[:clientId] = clientId
    session[:secret] = secret
    session[:serviceUri] = @serviceUri
    session[:redirectUri] = @redirectUri
    session[:tokenUri] = @tokenUri

    query_hash = {
        response_type: "code",
        client_id: clientId,
        scope: @scope,
        redirect_uri: @redirectUri,
        aud: @serviceUri,
        launch: @launchContextId,
        state: session.id

    }

    redirect_uri = URI(@authUri)
    redirect_uri.query = URI.encode_www_form(query_hash)

    redirect_to redirect_uri.to_s

  end

end
