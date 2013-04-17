require 'test_helper'

# There are 5 tables for scores: 
#   * scores table with all scores
#   * best scores table with top 100
#   * best scores table with top 100, reaped on rolling 24hr basis
#   * best scores table with top 100, reaped on rolling 7day basis
#   * a lookup table to get approximate rank if outside top 100 

# The best scores tables are denormalized.  They contain all data needed for a client.  They *do*
# have a foreign key referencing the all scores table, but it should not be used in production queries.

# The best tables will be slightly bigger than the number of scores you should get
# from them (except for all time).  The reaper will kill stuff out of 1 and 7 day, 
# and then the next scores submitted will fill those spots.  So at the low end of these 
# tables, there will be sorting happening due to reaper, and the ranks will not be accurate.

# Best tables are indexed on leaderboard_id and on value.
# Scores table is indexed on (leaderboard_id, user_id), query in that order.

# The lookup table for approx rank is not yet implemented.

class ScoreTest < ActiveSupport::TestCase
  def score_helper(leaderboard, user, value, created_at = nil)
    s = leaderboard.scores.build()
    s.value = value
    s.user_id = user.id if user.is_a?(User)
    s.user_id = user if user.is_a?(Fixnum)
    s.created_at = created_at if created_at
    s
  end

  def scores(leaderboard, user)
    Score.where(leaderboard_id: leaderboard.id, user_id: user.id)
  end

  def setup
    @hs_leaderboard = Leaderboard.create!(name: "high", sort_type: Leaderboard::HIGH_VALUE_SORT_TYPE)
    @ls_leaderboard = Leaderboard.create!(name: "low", sort_type: Leaderboard::LOW_VALUE_SORT_TYPE)
    @user = User.create!(nick: "foo")
  end

  test "scores of the same leaderboard type should compare properly" do
    s1 = score_helper(@hs_leaderboard, @user, 150)
    s2 = score_helper(@hs_leaderboard, @user, 100)
    assert s1.is_better_than?(s2), "High score comparison is broken"
  
    s3 = score_helper(@ls_leaderboard, @user, 150)
    s4 = score_helper(@ls_leaderboard, @user, 100)
    assert !s3.is_better_than?(s4), "Low score comparison is broken"
  
    s5 = score_helper(@ls_leaderboard, @user, 100)
    assert !s4.is_better_than?(s5)
  end
  
  
  test "scores only post to the appropriate Best tables" do
    score_helper(@hs_leaderboard, @user, 50, Time.now - 1.minutes).save
    score_helper(@hs_leaderboard, @user, 100, Time.now - 2.days).save
    score_helper(@hs_leaderboard, @user, 150, Time.now - 2.weeks).save
    
    # Now let's create a new score of 75.
    s1 = score_helper(@hs_leaderboard, @user, 75).save
  
    assert_equal 75,  Score.best_for('today', @hs_leaderboard.id, @user.id).value
    assert_equal 100, Score.best_for('this_week', @hs_leaderboard.id, @user.id).value
    assert_equal 150, Score.best_for('all_time', @hs_leaderboard.id, @user.id).value
    
    # Now let's create a new score of 125.
    s2 = score_helper(@hs_leaderboard, @user, 125).save
    
    assert_equal 125,  Score.best_for('today', @hs_leaderboard.id, @user.id).value
    assert_equal 125, Score.best_for('this_week', @hs_leaderboard.id, @user.id).value
    assert_equal 150, Score.best_for('all_time', @hs_leaderboard.id, @user.id).value
    
    # Now 200
    s3 = score_helper(@hs_leaderboard, @user, 200).save
    
    assert_equal 200,  Score.best_for('today', @hs_leaderboard.id, @user.id).value
    assert_equal 200, Score.best_for('this_week', @hs_leaderboard.id, @user.id).value
    assert_equal 200, Score.best_for('all_time', @hs_leaderboard.id, @user.id).value
  end
  
  test "scores should be saved in utc" do
    score = score_helper(@hs_leaderboard, @user, 100)
    score.created_at = Time.parse("2013-03-23 15:00:00 -0700")
    score.save
    created_at_str = Score.find_by_id(score.id).attributes_before_type_cast["created_at"].to_s
    assert "2013-03-23 22:00:00 UTC", created_at_str
  end
  
  test "high score best" do
    s1 = score_helper(@hs_leaderboard, @user, 100).save
    assert_equal 100, Score.best_for('today', @hs_leaderboard.id, @user.id).value 
  
    s2 = score_helper(@hs_leaderboard, @user, 200).save
    assert_equal 200, Score.best_for('today', @hs_leaderboard.id, @user.id).value 
  end
  
  test "low score best" do
    s1 = score_helper(@ls_leaderboard, @user, 100).save
    
    assert_equal 100, Score.best_for('today', @ls_leaderboard.id, @user.id).value 
  
    s2 = score_helper(@ls_leaderboard, @user, 200).save
    assert_equal 100, Score.best_for('today', @ls_leaderboard.id, @user.id).value 
  
    s3 = score_helper(@ls_leaderboard, @user, 50).save
    assert_equal 50, Score.best_for('today', @ls_leaderboard.id, @user.id).value 
  end
  
  test "a user should only have one best score for any time range" do
    user1 = User.create!(nick: "foo")
    user2 = User.create!(nick: "bar")
    score_helper(@hs_leaderboard, user1, 100).save
    score_helper(@hs_leaderboard, user1, 300).save
    assert_equal 1, Score.bests_for('today', @hs_leaderboard.id).count
  end

end
