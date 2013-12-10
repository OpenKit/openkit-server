module Dashboard
class DevelopersController < ApplicationController
  # Nothing required to hit the signup page.
  skip_before_filter :require_login, :only => [:new, :create]
  before_filter      :set_developer, :except => [:new, :create]

  def show
  end

  def new
    @developer = Developer.new
  end

  def edit
  end

  def create
    @developer = Developer.new(params[:developer])
    if @developer.save
      redirect_to root_url, notice: 'Developer was successfully created.'
    else
      render action: "new"
    end
  end

  def update
    @developer.assign_attributes(params[:developer])
    if @developer.save
      redirect_to @developer, notice: 'Developer was successfully updated.'
    else
      render action: "edit"
    end
  end

  def destroy
    @developer.destroy
    redirect_to developers_url, notice: 'Your account was destroyed'
  end

  private
  def set_developer
    @developer = Developer.find(params[:id].to_i)
    unless @developer && (current_developer == @developer)
      render :text => "Forbidden", :status => :forbidden
    end
  end
end
end