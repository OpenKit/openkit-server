require 'test_helper'

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
    @hs_board = Leaderboard.create!(name: "high", sort_type: Leaderboard::HIGH_VALUE_SORT_TYPE)
    @ls_board = Leaderboard.create!(name: "low", sort_type: Leaderboard::LOW_VALUE_SORT_TYPE)
    @user = User.new
  end

  test "scores of the same leaderboard type should compare properly" do
    s1 = score_helper(@hs_board, @user, 150)
    s2 = score_helper(@hs_board, @user, 100)
    assert s1.is_better_than?(s2), "High score comparison is broken"

    s3 = score_helper(@ls_board, @user, 150)
    s4 = score_helper(@ls_board, @user, 100)
    assert !s3.is_better_than?(s4), "Low score comparison is broken"

    s5 = score_helper(@ls_board, @user, 100)
    assert !s4.is_better_than?(s5)
  end

  test "high score overwriting" do
    s1 = score_helper(@hs_board, @user, 100)
    Score.handle_new_score(s1)
    arr = scores(@hs_board, @user)
    assert_equal 100, arr.first.value

    # Now post a score of 200 and make sure old score is overwritten
    s2 = score_helper(@hs_board, @user, 200)
    Score.handle_new_score(s2)
    arr = scores(@hs_board, @user)
    assert_equal 200, arr.first.value

    # Now post a score of 50 and make sure no write takes place
    s3 = score_helper(@hs_board, @user, 50)
    Score.handle_new_score(s3)
    arr = scores(@hs_board, @user)
    assert_equal 200, arr.first.value
    assert_equal 1, arr.count
  end

  test "low score overwriting" do
    s1 = score_helper(@ls_board, @user, 100)
    Score.handle_new_score(s1)
    arr = scores(@ls_board, @user)
    assert_equal 100, arr.first.value

    # Now post a score of 200 and make sure it does not overwrite previous score
    s2 = score_helper(@ls_board, @user, 200)
    Score.handle_new_score(s2)
    arr = scores(@ls_board, @user)
    assert_equal 100, arr.first.value

    # Now post a score of 50 and make sure old score is overwritten
    s3 = score_helper(@ls_board, @user, 50)
    Score.handle_new_score(s3)
    arr = scores(@ls_board, @user)
    assert_equal 50, arr.first.value
    assert_equal 1, arr.count
  end

end
