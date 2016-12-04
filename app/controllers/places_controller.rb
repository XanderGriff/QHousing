class PlacesController < ApplicationController
  def index
    @places = Place.order('created_at DESC')
  end

  def new
    @place = Place.new
  end

  def create
    @place = Place.new()
    if @place.save
      flash[:success] = "Place added!"
      redirect_to root_path
    else
      render 'new'
    end
  end
  
  def show
    @place = Place.find(params[:id])
  end

  def destroy
  end

  def update
  end

  def edit
  end
end
