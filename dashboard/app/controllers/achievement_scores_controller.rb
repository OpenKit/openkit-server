class AchievementScoresController < ApplicationController

  def destroy
    @achievement_score = AchievementScore.find(params[:id].to_i)
    if current_developer.authorized_to_delete_achievement_score?(@achievement_score)
      @achievement_score.destroy
      redirect_to achievement_scores_url, notice: "Score was deleted."
    else
      redirect_to root_url, notice: "You can't delete that score."
    end
  end
end
