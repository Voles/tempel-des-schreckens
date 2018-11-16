package be.socrates.tempeldesschreckens.domain.game;

import be.socrates.tempeldesschreckens.domain.Room;
import be.socrates.tempeldesschreckens.domain.player.Player;
import be.socrates.tempeldesschreckens.domain.player.PlayerId;
import be.socrates.tempeldesschreckens.domain.player.Role;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.stream.IntStream;

import static be.socrates.tempeldesschreckens.domain.player.Player.PlayerBuilder.player;

public class Game {

    private PlayerIds playerIds = new PlayerIds();
    private List<Room> rooms;
    private Integer playerCount;

    private Game(final int playerCount) {
        this.playerCount = playerCount;
        final List<Room> emptyRooms = Collections.nCopies(8, Room.EMPTY);
        final List<Room> treasureRooms = Collections.nCopies(5, Room.TREASURE);
        final List<Room> trapRooms = Collections.nCopies(2, Room.TRAP);
        rooms = new ArrayList<>();
        rooms.addAll(emptyRooms);
        rooms.addAll(treasureRooms);
        rooms.addAll(trapRooms);
    }

    public static Game newGame(final int playerCount) {
        validatePlayerCount(playerCount);
        return new Game(playerCount);
    }

    private static void validatePlayerCount(final int playerCount) {
        if (playerCount > 10){
            throw new IllegalArgumentException("Tempel des Schreckens can only be played with max. 10 players");
        }
    }

    public Role randomRole() {
        return Role.ADVENTURER;
    }

    public List<Room> rooms() {
        return rooms;
    }

    public Player newPlayer(final String playerName) {
        return player()
                .withPlayerId(nextPlayerId())
                .withCards(rooms())
                .withRole(randomRole())
                .build();
    }

    private PlayerId nextPlayerId() {
        return playerIds.next();
    }

}
