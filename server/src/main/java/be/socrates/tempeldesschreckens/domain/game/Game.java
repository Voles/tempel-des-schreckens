package be.socrates.tempeldesschreckens.domain.game;

import be.socrates.tempeldesschreckens.domain.Room;
import be.socrates.tempeldesschreckens.domain.player.Player;
import be.socrates.tempeldesschreckens.domain.player.PlayerId;
import be.socrates.tempeldesschreckens.domain.player.Role;
import org.springframework.stereotype.Component;

import java.util.Arrays;
import java.util.List;

import static be.socrates.tempeldesschreckens.domain.player.Player.PlayerBuilder.player;

@Component
public class Game {

    private PlayerIds playerIds = new PlayerIds();
    private Cards cards = new Cards();
    private Integer playerCount;

    public Role randomRole() {
        return Role.ADVENTURER;
    }

    public List<Room> cards() {
        return Arrays.asList();
    }

    public Player newPlayer(final String playerName) {
        return player()
                .withPlayerId(nextPlayerId())
                .withCards(cards())
                .withRole(randomRole())
                .build();
    }

    private PlayerId nextPlayerId() {
        return playerIds.next();
    }

    public GameId newGame(final Integer playerCount) {
        this.playerCount = playerCount;
        return GameId.gameId();
    }
}
