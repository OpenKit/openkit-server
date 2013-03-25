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
  def score_helper(leaderboard, user, value)
    s = leaderboard.scores.build(value: value)
    s.user = user
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
    # Create a situation where user already has scores in the
    # three Best tables, and make sure the overwrite only happens in one.
    s1 = score_helper(@hs_leaderboard, @user, 50)
    s2 = score_helper(@hs_leaderboard, @user, 100)
    s3 = score_helper(@hs_leaderboard, @user, 150)
    
    # Let's put 50 in the 1 day, 100 in the 7 day, and 150 all time.
    BestScore1.create_from_score(s1)
    BestScore7.create_from_score(s2)
    BestScoreAll.create_from_score(s3)
    
    # Now let's create a new score of 75 and handle it.
    s4 = score_helper(@hs_leaderboard, @user, 75)
    Score.handle_new_score(s4)
    
    # Make sure 1 day is updated
    assert BestScore1.find_by_score_id(s4.id)
    assert !BestScore1.find_by_score_id(s1.id)
    
    # Make sure 7 day and all time are not updated
    assert !BestScore7.find_by_score_id(s1.id)
    assert !BestScoreAll.find_by_score_id(s1.id)
    
    # Now let's create a new score of 125 and handle it.
    s5 = score_helper(@hs_leaderboard, @user, 125)
    Score.handle_new_score(s5)
    assert BestScore1.find_by_score_id(s5.id)
    assert !BestScore1.find_by_score_id(s4.id)
    assert BestScore7.find_by_score_id(s5.id)
    assert !BestScore7.find_by_score_id(s2.id)
    assert !BestScoreAll.find_by_score_id(s5.id)
    
    # Now 200
    s6 = score_helper(@hs_leaderboard, @user, 200)
    Score.handle_new_score(s6)
    assert BestScore1.find_by_score_id(s6.id)
    assert !BestScore1.find_by_score_id(s5.id)
    assert BestScore7.find_by_score_id(s6.id)
    assert !BestScore7.find_by_score_id(s5.id)
    assert BestScoreAll.find_by_score_id(s6.id)
    assert !BestScoreAll.find_by_score_id(s3.id)
  end
  
  test "With full best tables, a new best should pop lowest score out and insert new score" do
    max_entries = 100
    bulk_value = 50
    
    # Do bulk insert into best. 
    arr = Array.new(max_entries - 1, "(#{@hs_leaderboard.id}, #{@user.id}, #{bulk_value}, '2013-01-01 04:00:00')")
    sql = "INSERT INTO scores (leaderboard_id, user_id, value, created_at) VALUES #{arr.join(", ")}"
    BestScore1.connection.execute sql
    
    # create a score that is lower than bulk_value
    low = BestScore1.create!(leaderboard_id: @hs_leaderboard.id, user_id: @user.id, value: bulk_value - 10, score_id: 1)
    
    # now handle a score post that is higher than the current low score
    s1 = score_helper(@hs_leaderboard, @user, 125)
    Score.handle_new_score(s1)
    
    assert BestScore1.find(s1.id)
    assert !BestScore1.find(low.id)
  end
  
  test "daily scores do fear the reaper" do 
    lives_time = Time.now - 1.day
    dies_time = Time.now - 1.day - 1.second
    
    create_daily = lambda {
      return BestScore1.create(:leaderboard_id => 1, :user_id => 1, :value => 1, :score_id => 1)
    }
    
    lives = create_daily.()
    lives.update_attributes(:created_at => lives_time)
    
    dies = create_daily.()
    dies.update_attributes(:created_at => dies_time)
    
    Reaper.reap
    
    assert BestScore1.find(lives.id)
    assert !BestScore1.find(dies.id)
  end
  
  test "best scores should be saved in utc" do
    score = BestScore.create!(leaderboard_id: 1, user_id: 1, value: 1, score_id: 1)
    score.update_attributes(created_at: Time.parse("2013-03-23 15:00:00 -0700"))
    assert_equal "2013-03-23 22:00:00", BestScore.find(score.id).attributes_before_type_cast["created_at"]
  end
  
  test "weekly scores do fear the reaper" do
    dies_time = Time.now - 1.week - 1.second
    lives_time = Time.now - 1.week

    create_weekly = lambda {
      return BestScore7.create(:leaderboard_id => 1, :user_id => 1, :value => 1, :score_id => 1)
    }
    
    lives = create_weekly.()
    lives.update_attributes(:created_at => lives_time)
    
    dies = create_weekly.()
    dies.update_attributes(:created_at => dies_time)

    Reaper.reap
    
    assert BestScore7.find(lives.id)
    assert !BestScore7.find(dies.id)
  end
  
  test "row count in best tables should be approximate and cached" do
    
  end
  
  test "row count should resync with db every 5 runs of the reaper" do
    
  end
  
  

  # test "high score all time overwriting" do
  #   s1 = score_helper(@hs_leaderboard, @user, 100)
  #   Score.handle_new_score(s1)
  #   arr = scores(@hs_leaderboard, @user)
  #   assert_equal 100, arr.first.value
  # 
  #   # Now post a score of 200 and make sure old score is overwritten
  #   s2 = score_helper(@hs_leaderboard, @user, 200)
  #   Score.handle_new_score(s2)
  #   arr = scores(@hs_leaderboard, @user)
  #   assert_equal 200, arr.first.value
  # 
  #   # Now post a score of 50 and make sure no write takes place
  #   s3 = score_helper(@hs_leaderboard, @user, 50)
  #   Score.handle_new_score(s3)
  #   arr = scores(@hs_leaderboard, @user)
  #   assert_equal 200, arr.first.value
  #   assert_equal 1, arr.count
  # end
  # 
  # test "low score overwriting" do
  #   s1 = score_helper(@ls_leaderboard, @user, 100)
  #   Score.handle_new_score(s1)
  #   arr = scores(@ls_leaderboard, @user)
  #   assert_equal 100, arr.first.value
  # 
  #   # Now post a score of 200 and make sure it does not overwrite previous score
  #   s2 = score_helper(@ls_leaderboard, @user, 200)
  #   Score.handle_new_score(s2)
  #   arr = scores(@ls_leaderboard, @user)
  #   assert_equal 100, arr.first.value
  # 
  #   # Now post a score of 50 and make sure old score is overwritten
  #   s3 = score_helper(@ls_leaderboard, @user, 50)
  #   Score.handle_new_score(s3)
  #   arr = scores(@ls_leaderboard, @user)
  #   assert_equal 50, arr.first.value
  #   assert_equal 1, arr.count
  # end

end
