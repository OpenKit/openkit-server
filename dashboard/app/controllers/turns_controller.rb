class TurnsController < ApplicationController
  def new
    @turn = Turn.new
  end

  def create
    @turn = Turn.new(params[:turn])
    if @turn.save
      render :text => 'saved'
    else
      render action: "new"
    end
  end
end
