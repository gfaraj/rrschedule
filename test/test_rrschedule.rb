require 'helper'

class TestRrschedule < Test::Unit::TestCase
  context "A Schedule instance" do  
    should "have default values for every options" do
      schedule = RRSchedule::Schedule.new
      
      assert schedule.teams.size > 2
      assert_equal 1, schedule.cycles
      assert schedule.game_times.respond_to?(:to_ary)
      assert schedule.playing_surfaces.respond_to?(:to_ary)
      assert schedule.start_date.respond_to?(:to_date)
      assert schedule.shuffle_initial_order
      assert schedule.wdays.select{|w| (0..6).member? w} == schedule.wdays
      assert schedule.exclude_dates.empty?
    end
    
    should "have a dummy team when team number is odd" do
      schedule = RRSchedule::Schedule.new(
        :teams => Array(1..9)
      )
      
      assert schedule.teams.size == 10
      assert schedule.teams.member?(:dummy), "There should always be a :dummy team when the nbr of teams is odd"
    end
    
    should "not have a dummy team when team number is even" do
      schedule = RRSchedule::Schedule.new(
        :teams => Array(1..6)
      )
      
      assert schedule.teams.size == 6
      assert !schedule.teams.member?(:dummy), "There should never be a :dummy team when the nbr of teams is even"
    end
    
    should "not have a team named :dummy in the initial array" do
      assert_raise RuntimeError do
        schedule = RRSchedule::Schedule.new(
          :teams => Array(1..4) << :dummy
        )
      end
    end
    
    should "not have game times that cannot convert to valid DateTime objects" do
      assert_raise RuntimeError do
        schedule = RRSchedule::Schedule.new(
          :teams => Array(1..4),
          :game_times => ["10:00 AM", "13:00", "bonjour"]
        )
      end      
    end
    
    should "not have wdays that are not between 0 and 6" do
      assert_raise RuntimeError do
        schedule = RRSchedule::Schedule.new(
          :wdays => [2,7]
        )
      end      
    end
    
    should "automatically convert game times and playing surface to arrays" do
      schedule = RRSchedule::Schedule.new(
        :teams => Array(1..4),
        :game_times => "10:00 AM",
        :playing_surfaces => "the only one"
      )
      
      assert_equal [DateTime.parse("10:00 AM")], schedule.game_times
      assert_equal ["the only one"], schedule.playing_surfaces
    end
    
    should "have at least one team specified" do
      assert_raise RuntimeError do
        schedule = RRSchedule::Schedule.new(:teams => [1])      
      end
    end
    
    should "have default teams if non was specified" do
      schedule = RRSchedule::Schedule.new
      assert schedule.teams.size > 1
    end    
  end
  
  context "A generated schedule with an odd number of teams" do
    setup do
      @s = RRSchedule::Schedule.new(
        :teams => %w(a b c d e f g h i j l),
        :playing_surfaces => %w(one two),
        :game_times => ["10:00 AM", "13:00 PM"]
      ).generate
    end  
    
    should "be a valid round-robin" do
      assert @s.round_robin?
    end
    
    should "not have any :dummy teams in the schedule" do
      assert @s.gamedays.collect{|gd,games| games}.flatten.select{
        |g| [g.team_a,g.team_b].include?(:dummy)
      }.size == 0
    end
  end
  
  context "A generated schedule with an even number of teams" do
    setup do
      @s = RRSchedule::Schedule.new(
        :teams => %w(a b c d e f g h i j l m),
        :playing_surfaces => %w(one two),
        :game_times => ["10:00 AM", "13:00 PM"]
      ).generate
    end  
    
    should "be a valid round-robin" do
      assert @s.round_robin?
    end
    
    should "not have any :dummy teams in the schedule" do
      assert @s.gamedays.collect{|gd,games| games}.flatten.select{
        |g| [g.team_a,g.team_b].include?(:dummy)
      }.size == 0
    end
  end  
end
