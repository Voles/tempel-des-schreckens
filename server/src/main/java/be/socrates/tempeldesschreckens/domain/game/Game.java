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
    private List<Role> roles;
    private Integer playerCount;
    private List<Player> players;

    private Game(final int playerCount) {
        this.playerCount = playerCount;
        initializeRooms();
        initializeRoles();
        initializePlayers();
    }

    private void initializePlayers() {
        final PlayerIds playerIds = new PlayerIds();
        Collections.shuffle(roles);
        roles.subList(0, playerCount)
                .stream()
                .map(role -> player().withRole(role).withPlayerId(playerIds.next()).build());
        players = new ArrayList<>();
    }

    private void initializeRoles() {
        roles = new ArrayList<>();
        final List<Role> adventurers = Collections.nCopies(2, Role.ADVENTURER);
        final List<Role> guardians = Collections.nCopies(2, Role.GUARDIAN);
        roles.addAll(adventurers);
        roles.addAll(guardians);
    }

    private void initializeRooms() {
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

    List<Room> rooms() {
        return rooms;
    }

    List<Role> getRoles() {
        return roles;
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

    public List<Player> getPlayers() {
        return players;
    }
}
