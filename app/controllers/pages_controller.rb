require 'net/http'

class PagesController < ApplicationController


  def fhir_index
    @state = params[:state]
    @code = params[:code]






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


    # request = Net::HTTP::Get.new(@conformanceUri)
    # result = Net::HTTP.start(@conformanceUri) {|http|
    #   http.request(request)
    #
    # }
    #
    # @body = result.body

    render :patient
    #render layout: false
  end

end
