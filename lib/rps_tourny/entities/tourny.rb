module RPS
  class Tourny < ActiveRecord::Base
    belongs_to :player
    belongs_to :active

    def self.move(params)
      @player = RPS::Tourny.find_by(active_id: params[:id], player_id: params[:player_id])
      if @player.status == 'waiting'
        @player1 = RPS::Tourny.update(@player.id , move: params[:move], status: 'played')
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
            @winner = RPS::Player.find_by(name: @winner_name.name)
            RPS::Player.update(@winner.id, wins: @winner.wins.to_i + 1)
            @player = RPS::Tourny.find_by(active_id: params[:id], player_id: @winner.id)
            if @player.round <= 2
              RPS::Tourny.update(@player.id, status: 'waiting', round: 5)
            elsif @player.round <= 4
              RPS::Tourny.update(@player.id, status: 'waiting', round: 6)
            else
              RPS::Tourny.update(@player.id, status: 'waiting', round: 7)
            end
            @player = RPS::Tourny.find_by(active_id: params[:id], round: @player1.round, status: 'played')
            @loser = RPS::Player.find(@player.player_id)
            RPS::Player.update(@loser.id, loss: @loser.loss.to_i + 1)
            RPS::Tourny.update(@player.id, status: 'eliminated')
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
  end
end