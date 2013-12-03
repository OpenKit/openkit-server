module Dashboard
class ScoresController < ApplicationController

  def destroy
    @score = Score.find(params[:id].to_i)
    if current_developer.authorized_to_delete_score?(@score)
      @score.destroy
      redirect_to scores_url, notice: "Score was deleted."
    else
      redirect_to root_url, notice: "You can't delete that score."
    end
  end
end
end