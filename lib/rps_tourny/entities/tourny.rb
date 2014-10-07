module RPS
  class Tourny < ActiveRecord::Base
    belongs_to :player
    belongs_to :active

    def self.move(params)
      @player1 = RPS::Tourny.find_by(active_id: params[:id], player_id: params[:player_id])
      @active = RPS::Active.find(params[:id])
      if @player1.status == 'waiting'
        @player1 = RPS::Tourny.update(@player1.id , move: params[:move], status: 'played')
        @players = RPS::Tourny.where(active_id: params[:id], round: @player1.round, status: 'played')
        if @players.length == 2
          @winner_name = RockPaperScissors.play(
            {name: RPS::Player.find(@players.first.player_id),
              move: @players.first.move},
            {name: RPS::Player.find(@players.last.player_id),
              move: @players.last.move}
          )
          if @winner_name == :tie
            @players.each do |player|
              RPS::Tourny.update(player.id, status: 'waiting')
            end
          else
            @winner = RPS::Player.find_by(name: @winner_name)
            RPS::Player.update(@winner.id, wins: @winner.wins + 1)
            @player = RPS::Tourny.find_by(active_id: params[:id], player_id: @winner.id)
            @player = RPS::Tourny.update(@player.id, wins: @player.wins + 1)
            if @player.wins == @active.option
              if @player.round <= 2
                RPS::Tourny.update(@player.id, status: 'waiting', round: 5, wins: 0)
              elsif @player.round <= 4
                RPS::Tourny.update(@player.id, status: 'waiting', round: 6, wins: 0)
              else
                RPS::Tourny.update(@player.id, status: 'waiting', round: 7, wins: 0)
              end
              @player = RPS::Tourny.find_by(active_id: params[:id], round: @player1.round, status: 'played')
              @loser = RPS::Player.find(@player.player_id)
              RPS::Player.update(@loser.id, loss: @loser.loss + 1)
              RPS::Tourny.update(@player.id, status: 'eliminated')
            else
              @players.each do |player|
                RPS::Tourny.update(player.id, status: 'waiting')
              end
            end
          end
        end
      end
      @elim = RPS::Tourny.where(active_id: params[:id], status: 'eliminated')
      if @elim.length == 7
        @pl = RPS::Tourny.find_by(active_id: params[:id], status: 'waiting')
        RPS::Active.update(@pl.active.id, status: 'finished')
        RPS::Tourny.update(@pl.id, status: 'champion')
      end
    end

    def self.create_tourny(params)
      new_tourny = RPS::Active.create(status: 'active', option: params[:options].to_i)
      players = params[:players]
      init_round = 0
      players.each_index do |i|
        init_round += 1 if i % 2 == 0
        p = RPS::Player.find_by(name: players[i])
        if p
          RPS::Tourny.create(
            active_id: new_tourny.id,
            player_id: p.id,
            status: 'waiting',
            round: init_round,
            slot_number: i + 1,
            wins: 0
          )
        else
          p = RPS::Player.create(name: players[i], wins: 0, loss: 0)
          RPS::Tourny.create(
            active_id: new_tourny.id,
            player_id: p.id,
            status: 'waiting',
            round: init_round,
            slot_number: i + 1,
            wins: 0
          )
        end
      end
    end
  end
end