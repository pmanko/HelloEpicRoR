class PagesController < ApplicationController


  def fhir_index
    @state = params[:state]
    @code = params[:code]






    render :patient

    #render layout: false
  end

  def fhir_launch




    #render layout: false
  end

end
