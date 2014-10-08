module RPS
  class Tourny < ActiveRecord::Base
    belongs_to :player
    belongs_to :active

    def self.move(params)
      t = RPS::Tourny
      a = RPS::Active
      p = RPS::Player
      @player1 = t.find_by(active_id: params[:id], player_id: params[:player_id])
      @active = a.find(params[:id])
      if @player1.status == 'waiting'
        @player1 = t.update(@player1.id , move: params[:move], status: 'played')
        @players = t.where(active_id: params[:id], round: @player1.round, status: 'played')
        if @players.length == 2
          @winner_name = RockPaperScissors.play(
            {name: p.find(@players.first.player_id),
              move: @players.first.move},
            {name: p.find(@players.last.player_id),
              move: @players.last.move}
          )
          if @winner_name == :tie
            @players.each do |player|
              t.update(player.id, status: 'waiting')
            end
          else
            @winner = p.find_by(name: @winner_name.name)
            p.update(@winner.id, wins: @winner.wins + 1)
            @player = t.find_by(active_id: params[:id], player_id: @winner.id)
            @player = t.update(@player.id, wins: @player.wins + 1)
            if @player.wins == @active.option
              if @player.round <= 2
                t.update(@player.id, status: 'waiting', round: 5, wins: 0)
              elsif @player.round <= 4
                t.update(@player.id, status: 'waiting', round: 6, wins: 0)
              else
                t.update(@player.id, status: 'waiting', round: 7, wins: 0)
              end
              @player = t.find_by(active_id: params[:id], round: @player1.round, status: 'played')
              @loser = p.find(@player.player_id)
              p.update(@loser.id, loss: @loser.loss + 1)
              t.update(@player.id, status: 'eliminated')
            else
              @players.each do |player|
                t.update(player.id, status: 'waiting')
              end
            end
          end
        end
      end
      @elim = t.where(active_id: params[:id], status: 'eliminated')
      if @elim.length == 7
        @pl = t.find_by(active_id: params[:id], status: 'waiting')
        a.update(@pl.active.id, status: 'finished')
        t.update(@pl.id, status: 'champion')
      end
    end

    def self.create_tourny(params)
      new_tourny = a.create(status: 'active', option: params[:options].to_i)
      players = params[:players]
      init_round = 0
      players.each_index do |i|
        init_round += 1 if i % 2 == 0
        pl = p.find_by(name: players[i])
        if pl
          t.create(
            active_id: new_tourny.id,
            player_id: pl.id,
            status: 'waiting',
            round: init_round,
            slot_number: i + 1,
            wins: 0
          )
        else
          pl = p.create(name: players[i], wins: 0, loss: 0)
          t.create(
            active_id: new_tourny.id,
            player_id: pl.id,
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